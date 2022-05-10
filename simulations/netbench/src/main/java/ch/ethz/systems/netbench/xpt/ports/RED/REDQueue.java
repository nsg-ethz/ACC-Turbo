package ch.ethz.systems.netbench.xpt.ports.RED;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.Link;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.ext.basic.IpHeader;
import ch.ethz.systems.netbench.xpt.tcpextended.lstftcp.RandomNumberGenerator;
import java.util.Queue;
import java.util.Random;
import java.util.concurrent.LinkedBlockingQueue;

public class REDQueue extends LinkedBlockingQueue implements Queue {

    /*
     * Static state.
     */
    protected REDParameters redParams;
    protected double bandwidthBitPerNs; // The bandwidth of the link in bits per nanosecond (1 bit/ns = 1 Gbit/s)

    /*
     * Dynamic state.
     */
    protected REDVariables redVars;  /* early-drop variables */
    protected double idleTime;	        /* Since when has the queue been idle */
    protected boolean isIdle;
    protected int currentQueueSize;  // current queue size

    public REDQueue(Link link, double q_weight, int th_min, int th_max, boolean enable_gentle, int averagePacketSize, boolean wait){

        // Configurable
        this.redParams = new REDParameters();
        this.redParams.th_min = th_min;// minthresh in packets
        this.redParams.th_max = th_max; // maxthresh in packets
        assert (th_min < th_max);

        this.bandwidthBitPerNs = link.getBandwidthBitPerNs();
        this.redParams.averagePacketSize = averagePacketSize; // avg pkt size to estimate num packets arrived during idle times. Contains only the data and is in bits
        this.redParams.q_weight = q_weight; // q_weight for the exponential weighted moving average
        this.redParams.gentle = enable_gentle;  // increase the packet drop prob. slowly when ave queue exceeds maxthresh
        this.redParams.wait = wait; // True for waiting between dropped packets
        this.redParams.invAvgPacketTime = 0.0; // Computed from the bw and averagePacketsize in initializeParameters()

        // RED variables
        this.redVars = new REDVariables();
        redVars.v_ave = 0.0;   // average queue size
        redVars.v_prob1 = 0.0;  // dropping probability
        redVars.v_prob = 0.0;
        redVars.v_a = 0.0;
        redVars.v_b = 0.0;
        redVars.v_c = 0.0;
        redVars.v_d = 0.0;
        redVars.count = 0;
        redVars.old = 0;
        redVars.cur_max_p = 1.0;    // current max_p

        this.initializeParameters();
    }


    public void initializeParameters() {
        System.out.println("Initializing RED params.");

        redParams.invAvgPacketTime = bandwidthBitPerNs / (redParams.averagePacketSize); // In nanoseconds

        redVars.v_ave = 0.0;
        redVars.count = 0;
        redVars.old = 0;
        isIdle = true;

        double th_diff = (redParams.th_max - redParams.th_min);
        if (th_diff == 0) {
            System.out.println("The two thresholds are the same, no RED taking place");
            System.exit(-1);
        }
        redVars.v_a = 1.0 / th_diff;
        redVars.v_b = - redParams.th_min / th_diff;
        if (redParams.gentle) {
            redVars.v_c = ( 1.0 - redVars.cur_max_p ) / redParams.th_max;
            redVars.v_d = 2.0 * redVars.cur_max_p - 1.0;
        }
        idleTime = Simulator.getCurrentTime();
    }

    /* Compute the average queue size */
    double estimate_average_queue_size(int enqueued, int m, double ave, double q_weight)
    {
        double new_ave;

        new_ave = ave;
        while (--m >= 1) {
            new_ave *= 1.0 - q_weight;
        }
        new_ave *= 1.0 - q_weight;
        new_ave += q_weight * enqueued;
        return new_ave;
    }

    /* Calculate the drop probability */
    double calculate_p_new(double v_ave, double th_max, boolean gentle, double v_a,
                           double v_b, double v_c, double v_d, double max_p) {
        double p;
        if (gentle && v_ave >= th_max) {
            // p ranges from max_p to 1 as the average queue
            // size ranges from th_max to twice th_max
            p = v_c * v_ave + v_d;
        } else if (!gentle && v_ave >= th_max) {
            // OLD: p continues to range linearly above max_p as
            // the average queue size ranges above th_max.
            // NEW: p is set to 1.0
            p = 1.0;
        } else {
            // p ranges from 0 to max_p as the average queue
            // size ranges from th_min to th_max
            p = v_a * v_ave + v_b;
            // p = (v_ave - th_min) / (th_max - th_min)
            p *= max_p;
        }
        if (p > 1.0)
            p = 1.0;
        return p;
    }

    /* Make uniform instead of geometric interdrop periods */
    double modify_p(double p, int count, boolean wait) {
        double count1 = count;
        if (wait) {
            if (count1 * p < 1.0)
                p = 0.0;
            else if (count1 * p < 2.0)
                p /= (2.0 - count1 * p);
            else
                p = 1.0;
        } else {
            if (count1 * p < 1.0)
                p /= (1.0 - count1 * p);
            else
                p = 1.0;
        }
        if (p > 1.0)
            p = 1.0;
        return p;
    }

    /* Should the packet be dropped due to a probabilistic drop? */
    boolean drop_early() {
        redVars.v_prob1 = calculate_p_new(redVars.v_ave, redParams.th_max, redParams.gentle, redVars.v_a, redVars.v_b, redVars.v_c, redVars.v_d, redVars.cur_max_p);
        redVars.v_prob = modify_p(redVars.v_prob1, redVars.count, redParams.wait);

        Random independentRng = new Random();
        double u = independentRng.nextDouble();
        if (u <= redVars.v_prob) {
            // DROP
            redVars.count = 0;
            return true; // drop
        }
        return false; // no drop
    }

    /* Returns the dropped packet, if any. Otherwise, returns null. */
    public Packet offerPacket(Object o) {

        Packet pkt = (Packet) o;

        /*
         * Once a new packet arrives at the queue:
         * the average queue size is computed.  If the average size
         * exceeds the threshold, then the dropping probability is computed,
         * and the newly-arriving packet is dropped with that probability.
         *
         * "Forced" drops mean a packet arrived when the underlying queue was
         * full, or when the average queue size exceeded some threshold and no
         * randomization was used in selecting the packet to be dropped.
         * "Unforced" means a RED random drop.
         */

        // First, simulate number of packets arrival during idle period
        int m = 0;
        if (isIdle) {
            double now = Simulator.getCurrentTime();
            /* To account for the period when the queue was empty. */
            m = (int)(redParams.invAvgPacketTime * (now - idleTime));
            isIdle = false;
        }

        /* Estimate the average queue size with either 1 new packet arrival, or with the scaled version above [scaled by m due to idle time] */
        redVars.v_ave = this.estimate_average_queue_size(this.size(), m + 1, redVars.v_ave, redParams.q_weight);

        redVars.count = redVars.count + 1; // Count packets that have not been dropped since the last early drop

        double qavg = redVars.v_ave;
        currentQueueSize = this.size();	// helps to trace queue during arrival, if enabled

        int droptype = 0;
        int DROPTYPE_FORCED = 1;	/* a "forced" drop */
        int DROPTYPE_UNFORCED = 2;	/* an "unforced" (random) drop */

        // If qavg > th_max, this is a FORCED drop
        if (qavg >= redParams.th_min && currentQueueSize > 1) {
            if (((redParams.gentle == false && qavg >= redParams.th_max) || (redParams.gentle == true && qavg >= 2 * redParams.th_max))) {
                droptype = DROPTYPE_FORCED;
            } else if (redVars.old == 0) {
                /*
                 * The average queue size has just crossed the
                 * threshold from below to above "minthresh", or
                 * from above "minthresh" with an empty queue to
                 * above "minthresh" with a nonempty queue.
                 */
                redVars.count = 1;
                redVars.old = 1;

            // If minthresh < qavg < maxthresh, this may be an UNFORCED drop
            } else if (drop_early()) {
                droptype = DROPTYPE_UNFORCED;
            }
        } else {
            /* No packets are being dropped.  */
            redVars.v_prob = 0.0;
            redVars.old = 0;
        }

        // Execute the drop if needed
        if (droptype == DROPTYPE_UNFORCED) {
            //System.out.println("Unforced drop. FlowId: " + pkt.getFlowId());
            reportDrop(pkt); // For pushback queue
            return pkt;
        } else if (droptype == DROPTYPE_FORCED) {
            //System.out.println("Forced drop. FlowId: " + pkt.getFlowId());
            reportDrop(pkt); // For pushback queue
            return pkt;
        } else {
            //System.out.println("Packet added to the RED queue");
            /* forced drop, or not a drop: first enqueue pkt */
            this.add(pkt);
            return null;
        }
    }

    @Override
    public Object poll() {
        Packet p = (Packet)super.poll();

        if (p != null) {
            isIdle = false;
        } else {
            isIdle = true;
            idleTime = Simulator.getCurrentTime();
        }
        return (p);
    }

    @Override // In packets
    public int size() {
        return super.size();
    }

    @Override
    public boolean isEmpty() {
        return super.isEmpty();
    }

    public double getBandwidthBitPerNs() {
        return bandwidthBitPerNs;
    }

    public void reportDrop(Packet p) {} // Will be overwritten by pushback queue
}
