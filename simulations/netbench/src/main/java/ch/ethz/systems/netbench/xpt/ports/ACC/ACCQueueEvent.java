package ch.ethz.systems.netbench.xpt.ports.ACC;
import ch.ethz.systems.netbench.core.network.Event;


/**
 * Event for the creation of a new packet. Called to replay pcap traces.
 */
public class ACCQueueEvent extends Event {

    protected ACCQueue pushbackQueue;

    ACCQueueEvent(long timeFromNowNs, ACCQueue pushbackQueue) {
        super(timeFromNowNs);
        this.pushbackQueue = pushbackQueue;
    }

    @Override
    public void trigger() {
        // We call the queue timeout when the Event is triggered
        this.pushbackQueue.timeout();
    }
}
