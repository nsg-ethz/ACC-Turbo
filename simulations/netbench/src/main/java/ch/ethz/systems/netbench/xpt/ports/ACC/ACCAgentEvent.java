package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.network.Event;

/**
 * Event for the creation of a new packet. Called to replay pcap traces.
 */
public class ACCAgentEvent extends Event {

    protected ACCAgent pushbackAgent;
    protected int eventType;
    protected RateLimitSession rls;

    ACCAgentEvent(long timeFromNowNs, int eventType, ACCAgent pushbackAgent) {
        super(timeFromNowNs);
        this.pushbackAgent = pushbackAgent;
        this.eventType = eventType;
        this.rls = null;
    }

    ACCAgentEvent(long timeFromNowNs, int eventType, RateLimitSession rls, ACCAgent pushbackAgent) {
        super(timeFromNowNs);
        this.pushbackAgent = pushbackAgent;
        this.eventType = eventType;
        this.rls = rls;
    }

    @Override
    public void trigger() {
        if (this.eventType == ACCConstants.PUSHBACK_REFRESH_EVENT) {
            pushbackAgent.pushbackRefresh();
        } else if (this.eventType == ACCConstants.INITIAL_UPDATE_EVENT) {
            pushbackAgent.initialUpdate(this.rls);
        } else {
            System.out.println("Unrecognized event " + this.eventType + "\n");
        }

    }
}
