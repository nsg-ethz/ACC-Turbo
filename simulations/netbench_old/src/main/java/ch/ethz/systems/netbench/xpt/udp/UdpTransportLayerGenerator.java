package ch.ethz.systems.netbench.xpt.udp;

import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.core.run.infrastructure.TransportLayerGenerator;

public class UdpTransportLayerGenerator extends TransportLayerGenerator {

    public UdpTransportLayerGenerator() {
        // No parameters needed
        SimulationLogger.logInfo("Transport layer", "UDP");
    }

    @Override
    public TransportLayer generate(int identifier) {
        return new UdpTransportLayer(identifier);
    }

}
