package ch.ethz.systems.netbench.xpt.cbr;

import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.core.run.infrastructure.TransportLayerGenerator;

public class CBRTransportLayerGenerator extends TransportLayerGenerator {

    private boolean randomEnabled;

    public CBRTransportLayerGenerator(boolean randomEnabled) {
        SimulationLogger.logInfo("Transport layer", "CBR");
        this.randomEnabled = randomEnabled;
    }

    @Override
    public TransportLayer generate(int identifier) {
        return new CBRTransportLayer(identifier, this.randomEnabled);
    }

}
