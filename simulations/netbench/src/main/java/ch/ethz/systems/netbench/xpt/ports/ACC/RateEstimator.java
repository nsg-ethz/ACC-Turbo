package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.Packet;

public class RateEstimator {

    public double k; /* averaging interval for rate estimation in seconds */
    public double estimatedRate; /* current flow's estimated rate in bps */
    protected int tempSize; /* keep track of packets that arrive at the same time */

    protected double previousTime;  /* time of last packet arrival (seconds) */
    protected double resetTime; // seconds

    public RateEstimator() {
        this.k = 0.1;
        this.estimatedRate = 0.0;
        this.tempSize = 0;

        this.previousTime= Simulator.getCurrentTime()/1000000000;  // seconds
        this.resetTime = Simulator.getCurrentTime()/1000000000;  // seconds
    }

    public RateEstimator(double estimate) {
        this.k = 0.1;
        this.estimatedRate = estimate;
        this.tempSize = 0;

        this.previousTime = Simulator.getCurrentTime()/1000000000;  // seconds
        this.resetTime = Simulator.getCurrentTime()/1000000000;  // seconds
    }

    // Returns bit per seconds
    public void estimateRate(Packet pkt) {
        long pktSize = pkt.getSizeBit();

        double now = Simulator.getCurrentTime()/1000000000;  // seconds
        double timeGap = (now - this.previousTime);  // seconds

        // I guess this is just to account for multiple packets that arrive together
        if (timeGap == 0) {
            this.tempSize += pktSize;
            return;
        } else {
            pktSize += this.tempSize;
            this.tempSize = 0;
        }
        this.previousTime = now;
        estimatedRate = ((1 - Math.exp(-timeGap/k)) * ((double)pktSize)/timeGap)  +  (Math.exp(-timeGap/k) * estimatedRate);
    }

}
