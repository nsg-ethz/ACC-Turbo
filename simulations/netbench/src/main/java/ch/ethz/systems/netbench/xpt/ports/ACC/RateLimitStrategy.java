package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.xpt.ports.RateLimiter.RateLimiter;
import ch.ethz.systems.netbench.xpt.ports.RateLimiter.TokenBucketRateLimiter;

public class RateLimitStrategy {

    public double targetRate; //predefined flow rate in bps
    public double resetTime; //time since the aggregate stats are being collected

    public RateEstimator rateEstimator;
    public RateLimiter rateLimiter;

    public RateLimitStrategy(double limit, double estimateArrivalRateAggregate) {

        this.targetRate = limit;
        this.resetTime = Simulator.getCurrentTime()/1000000000;

        this.rateEstimator = new RateEstimator(estimateArrivalRateAggregate);
        this.rateLimiter = new TokenBucketRateLimiter(ACCConstants.DEFAULT_BUCKET_DEPTH);
        //System.out.println("Rate-Limit Strategy: Started a token bucket at time: " + this.resetTime + "s");
    }

    public double process(Packet p) {
        this.rateEstimator.estimateRate(p);
        int dropped = 0;
        dropped = this.rateLimiter.rateLimit(p, this.targetRate);
        return dropped;
    }

    public double getDropRate(){
        double inRate = this.rateEstimator.estimatedRate;
        double dropRate = 0;
        if (inRate > 0) {
            dropRate = (inRate - targetRate)/inRate;
        }
        if (dropRate < 0) dropRate=0;
        return dropRate;
    }

    public double getArrivalRate() {
        return this.rateEstimator.estimatedRate;
    }

}
