package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Link;
import ch.ethz.systems.netbench.core.network.NetworkDevice;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.xpt.ports.RED.REDQueue;

import java.util.Queue;

public class ACCQueue extends REDQueue implements Queue {

    public NetworkDevice ownNetworkDevice;
    public ACCAgent pushbackAgent;
    public RateEstimator rateEstimator;
    public RateLimitSessionList rlsList;

    protected boolean enableRateLimiting; // if rate limiting not enabled, it performs as a normal RED queue I guess
    protected double sustainedCongestionPeriod;
    protected int totalBitArrivals; // bit arrivals to the queue
    protected int totalBitDrops ; // bit drops
    protected int rateLimiterBitDrops; // early bit drops


    public ACCQueue(NetworkDevice ownNetworkDevice, Link link, boolean enableRateLimiting, double sustainedCongestionPeriod, double q_weight, int th_min, int th_max, boolean enable_gentle, int averagePacketSize, boolean wait){

        super(link, q_weight, th_min, th_max, enable_gentle, averagePacketSize, wait);

        this.ownNetworkDevice = ownNetworkDevice;
        this.pushbackAgent = new ACCAgent(this); // We create a new agent for the queue
        this.rateEstimator = new RateEstimator();
        this.rlsList = new RateLimitSessionList();

        this.enableRateLimiting = enableRateLimiting;
        this.sustainedCongestionPeriod = sustainedCongestionPeriod;

        this.totalBitArrivals = 0;
        this.totalBitDrops = 0;
        this.rateLimiterBitDrops = 0;

        // We schedule the first call to the timeout function that executes the pushback function
        ACCQueueEvent pushbackQueueEvent = new ACCQueueEvent((long)(sustainedCongestionPeriod*1000000000), this);
        Simulator.registerEvent(pushbackQueueEvent);
    }

    void timeout() { // Called every sustainedCongestionPeriod

        // An alternative way of calculating this is using the arrivals and drops
        // but the below is more accurate as RED avg queue takes time to come down and
        // hence drop rate goes down much slower.
        double dropRate1 = getDropRate();
        double dropRate2 = 0;

        if ((this.totalBitArrivals - this.rateLimiterBitDrops) > 0) {
            dropRate2 = ((double)(this.totalBitDrops - this.rateLimiterBitDrops)/(double)(this.totalBitArrivals - this.rateLimiterBitDrops)); //bits dropped divided by bit arrived
        }

        /*if(this.ownNetworkDevice.getIdentifier() == 0) {
            System.out.println(Simulator.getCurrentTime()/1000000000 + "s: Pushback Queue: New drop rates computed: " + dropRate1 + ", and " + dropRate2);
        }*/

        if (enableRateLimiting &&
                // dropRate1 >= PushbackConstants.SUSTAINED_CONGESTION_DROPRATE &&
                dropRate2 >= ACCConstants.SUSTAINED_CONGESTION_DROPRATE
        ) {

            // this function call would
            //  1) start a rate limiting session,
            //  2) insert it in the queues rate limiting session list.
            //  3) will also set up appropriate timers.

            this.pushbackAgent.identifyAggregate(this.rateEstimator.estimatedRate, this.bandwidthBitPerNs*1000000000);
        }

        // Reset the drop history at the agent
        this.pushbackAgent.resetDropLog();
        this.totalBitArrivals = 0;
        this.totalBitDrops = 0;
        this.rateLimiterBitDrops = 0;

        // When the processing is finished, we schedule it again for sustainedCongestionPeriod ns from now
        ACCQueueEvent pushbackQueueEvent = new ACCQueueEvent((long)(sustainedCongestionPeriod*1000000000), this);
        Simulator.registerEvent(pushbackQueueEvent);
    }

    public Packet offerPacket(Object o) {
        Packet p = (Packet) o;
        this.totalBitArrivals += p.getSizeBit();

        // 1. checks if a packet belongs to any of the aggregate being rate-limited
        // 2. if yes, log the packet and
        // 3. drop it if necessary (based on rate-limiting dynamics).
        // 4. dropped = 1, if dropped.

        int droppedByRateLimiter = 0;
        if (this.rlsList.numSessions != 0) {
            droppedByRateLimiter = rlsList.filter(p);
        }

        if (droppedByRateLimiter == 1) {
            this.rateLimiterBitDrops += p.getSizeBit();
            this.totalBitDrops += p.getSizeBit();
            return p;
        }

        // Estimate rate only for enqueued packets
        rateEstimator.estimateRate(p);
        Packet droppedPacket = super.offerPacket(p); // RED enqueue
        if (droppedPacket != null){
            this.totalBitDrops += droppedPacket.getSizeBit();
        }

        // Log the packet drop (if it is not by the rate limiter)
        if(droppedPacket != null && droppedByRateLimiter == 0 && SimulationLogger.hasAggregateDropsTrackingEnabled()){
            SimulationLogger.logAggregateDrops(Simulator.getCurrentTime(), droppedPacket.getSizeBit(), droppedPacket.getFlowId());
        }
        return droppedPacket;
    }

    double getRate() {
        return rateEstimator.estimatedRate;
    }

    double getDropRate() {
        double bandwidthBitPerSec = this.bandwidthBitPerNs*1000000000;
        if (rateEstimator.estimatedRate < bandwidthBitPerSec) {
            return 0;
        } else {
            return 1 - bandwidthBitPerSec/rateEstimator.estimatedRate;
        }
    }

    @Override
    public void reportDrop(Packet p) {
        if (enableRateLimiting){
            pushbackAgent.registerDrop(p);
        }
    }

    @Override
    public Object poll() {
        Packet packet = (Packet) super.poll();
        return packet;
    }

    @Override
    public int size() {
        return super.size();
    }

    @Override
    public boolean isEmpty() {
        return super.isEmpty();
    }
}
