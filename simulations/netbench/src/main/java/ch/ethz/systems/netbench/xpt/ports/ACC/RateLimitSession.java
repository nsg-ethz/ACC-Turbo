package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.Packet;

public class RateLimitSession {

    public RateLimitStrategy rateLimitStrategy;
    public AggSpec aggSpec;
    public double lowerBound;       // the specified lower bound for this aggregate

    public boolean merged;              // whether merged or not
    public boolean initialPhase;        // the initial probability increasing phase

    public double startTime;  //  (seconds)
    public double refreshedTime; // last time the rate-limiting computation was refreshed (seconds)


    public RateLimitSession(AggSpec aggSpec, double rateEstimate, boolean initial,
                                       double limit, double lowerBound){

        this.rateLimitStrategy = new RateLimitStrategy(limit, rateEstimate);
        this.aggSpec = aggSpec;
        this.lowerBound = lowerBound;

        this.merged = false;
        this.initialPhase=initial;

        this.startTime = Simulator.getCurrentTime()/1000000000;  // In seconds
        this.refreshedTime = this.startTime;  // In seconds

        System.out.println("Created a rate-limiting session for aggregate: " + aggSpec.dstPrefix );/*
                + ". Aggregate Estimated Arrival Rate = " + rateEstimate + ". Initial limit = " + limit + ". Lower bound: " + lowerBound);*/
    }

    double log(Packet pkt) {
        boolean isMember = this.aggSpec.isMember(pkt);
        if (!isMember) {
            //System.out.println("Rate-Limit Session: Found a non-member packet: " + pkt.getFlowId());
            return 0;
        } else {
            //System.out.println("Rate-Limit Session: Found a member packet: " + pkt.getFlowId());
        }

        double prob = this.rateLimitStrategy.process(pkt);  //rate limit it.
        return prob;
    }

    double getDropRate() {
        return this.rateLimitStrategy.getDropRate();
    }

    void refreshed() {
        this.refreshedTime = Simulator.getCurrentTime()/1000000000;
    }

    void setLimit(double limit) {
        this.rateLimitStrategy.targetRate=limit;
    }

    double getArrivalRateForStatus()  {
        // for a leaf PBA, this is the rate seen at the rateLimitStrategy;
        return this.rateLimitStrategy.getArrivalRate();
    }
}
