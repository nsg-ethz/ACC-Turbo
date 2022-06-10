package ch.ethz.systems.netbench.xpt.ports.Pushback;
import ch.ethz.systems.netbench.core.network.Event;


/**
 * Event for the creation of a new packet. Called to replay pcap traces.
 */
public class PushbackQueueEvent extends Event {

    protected PushbackQueue pushbackQueue;

    PushbackQueueEvent(long timeFromNowNs, PushbackQueue pushbackQueue) {
        super(timeFromNowNs);
        this.pushbackQueue = pushbackQueue;
    }

    @Override
    public void trigger() {
        // We call the queue timeout when the Event is triggered
        this.pushbackQueue.timeout();
    }
}
