package ch.ethz.systems.netbench.xpt.ports.ACCTurbo;

import ch.ethz.systems.netbench.core.network.Event;

public class UpdatePrioritiesEvent extends Event {

    ACCTurboOutputPort accturbo;

    UpdatePrioritiesEvent(long timeFromNowNs, ACCTurboOutputPort accturbo) {
        super(timeFromNowNs);
        this.accturbo = accturbo;
    }

    @Override
    public void trigger() {
        // We call the queue timeout when the Event is triggered
        this.accturbo.updatePriorities();
    }
}
