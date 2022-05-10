package ch.ethz.systems.netbench.xpt.ports.Pushback;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Event;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;

/**
 * Event for the creation of a new packet. Called to replay pcap traces.
 */
public class PushbackAgentEvent extends Event {

    protected PushbackAgent pushbackAgent;
    protected int eventType;
    protected RateLimitSession rls;

    PushbackAgentEvent(long timeFromNowNs, int eventType, PushbackAgent pushbackAgent) {
        super(timeFromNowNs);
        this.pushbackAgent = pushbackAgent;
        this.eventType = eventType;
        this.rls = null;
    }

    PushbackAgentEvent(long timeFromNowNs, int eventType, RateLimitSession rls, PushbackAgent pushbackAgent) {
        super(timeFromNowNs);
        this.pushbackAgent = pushbackAgent;
        this.eventType = eventType;
        this.rls = rls;
    }

    @Override
    public void trigger() {
        if (this.eventType == PushbackConstants.PUSHBACK_REFRESH_EVENT) {
            pushbackAgent.pushbackRefresh();
        } else if (this.eventType == PushbackConstants.INITIAL_UPDATE_EVENT) {
            pushbackAgent.initialUpdate(this.rls);
        } else {
            System.out.println("Unrecognized event " + this.eventType + "\n");
        }

    }
}
