package ch.ethz.systems.netbench.xpt.ports.RateLimiter;

import ch.ethz.systems.netbench.core.network.Packet;

public abstract class RateLimiter {

    public abstract int rateLimit(Packet p, double targetRate);

}
