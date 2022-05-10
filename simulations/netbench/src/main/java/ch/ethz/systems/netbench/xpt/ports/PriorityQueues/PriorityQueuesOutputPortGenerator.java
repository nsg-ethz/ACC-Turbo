package ch.ethz.systems.netbench.xpt.ports.PriorityQueues;

import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Link;
import ch.ethz.systems.netbench.core.network.NetworkDevice;
import ch.ethz.systems.netbench.core.network.OutputPort;
import ch.ethz.systems.netbench.core.run.infrastructure.OutputPortGenerator;

public class PriorityQueuesOutputPortGenerator extends OutputPortGenerator {

    private final long numberQueues;
    private final long sizePerQueuePackets;

    public PriorityQueuesOutputPortGenerator(long numberQueues, long sizePerQueuePackets) {
        this.numberQueues = numberQueues;
        this.sizePerQueuePackets = sizePerQueuePackets;
        SimulationLogger.logInfo("Port", "PriorityQueues(numberQueues=" + numberQueues + ", sizePerQueuePackets=" + sizePerQueuePackets + ")");
    }

    @Override
    public OutputPort generate(NetworkDevice ownNetworkDevice, NetworkDevice towardsNetworkDevice, Link link) {
        return new PriorityQueuesOutputPort(ownNetworkDevice, towardsNetworkDevice, link, numberQueues, sizePerQueuePackets);
    }

}
