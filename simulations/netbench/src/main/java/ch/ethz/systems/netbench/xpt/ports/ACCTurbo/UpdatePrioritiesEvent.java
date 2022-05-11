package ch.ethz.systems.netbench.xpt.ports.ACCTurbo;

import ch.ethz.systems.netbench.core.network.Event;

public class UpdatePrioritiesEvent extends Event {

    ACCTurboOutputPort accr;

    UpdatePrioritiesEvent(long timeFromNowNs, ACCTurboOutputPort accr) {
        super(timeFromNowNs);
        this.accr = accr;
    }

    @Override
    public void trigger() {
        // We call the queue timeout when the Event is triggered
        this.accr.update_priorities();
    }
}
