package ch.ethz.systems.netbench.xpt.cbr;

import ch.ethz.systems.netbench.core.network.Event;

public class CBRSendEvent extends Event {

    protected CBRSocket cbrSocket;

    CBRSendEvent(long timeFromNowNs, CBRSocket cbrSocket) {
        super(timeFromNowNs);
        this.cbrSocket = cbrSocket;
    }

    @Override
    public void trigger() {
        // We call the socket timeout when the Event is triggered
        this.cbrSocket.timeout();
    }

}
