package ch.ethz.systems.netbench.xpt.ports.RateLimiter;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.Packet;

public class TokenBucketRateLimiter extends RateLimiter {

    //the static parameters
    public double tokenBucketDepthBytes;             //depth of the token bucket in bytes

    //the dynamic state
    public double numTokensInBucketInBytes;                 //number of tokens in the bucket; in bytes
    public double timeLastToken;

    public TokenBucketRateLimiter(int defaultBucketDepth) {
        this.tokenBucketDepthBytes = defaultBucketDepth;
        this.numTokensInBucketInBytes = tokenBucketDepthBytes;
        this.timeLastToken = Simulator.getCurrentTime();
    }

    @Override
    public int rateLimit(Packet p, double targetRate) {

        double now = Simulator.getCurrentTime();
        double timeElapsed = now - this.timeLastToken;

        //System.out.print(Simulator.getCurrentTime()/1000000000 + "s: Rate limiting packet from the Token Bucket");
        //System.out.println(" target rate: " + targetRate);

        double timeElapsedSeconds = timeElapsed/1000000000;
        numTokensInBucketInBytes += (timeElapsedSeconds * targetRate)/8.0;
        this.timeLastToken = now;

        if (numTokensInBucketInBytes > tokenBucketDepthBytes) {
            numTokensInBucketInBytes = tokenBucketDepthBytes;      /* never overflow */
        }

        //System.out.println("Token Bucket: numTokensInBucketInBytes = " + numTokensInBucketInBytes + " pktSize = " + p.getSizeBit()/8);
        if ((double)(p.getSizeBit()/8) < numTokensInBucketInBytes) {
            numTokensInBucketInBytes -= (double)(p.getSizeBit()/8);
            //System.out.println("Packet Not-dropped in Rate Limiter");
            return 0;
        }
        else {
            //System.out.println("Packet Dropped in Rate Limiter");
            return 1;
        }
    }
}
