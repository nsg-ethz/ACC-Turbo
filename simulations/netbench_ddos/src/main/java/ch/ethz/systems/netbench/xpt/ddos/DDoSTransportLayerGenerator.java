package ch.ethz.systems.netbench.xpt.ddos;

import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.core.run.infrastructure.TransportLayerGenerator;

public class DDoSTransportLayerGenerator extends TransportLayerGenerator {

    private String input;
    private int num_priorities;
    private double tp_rate, tn_rate;
    private boolean ground_truth_pifo;

    public DDoSTransportLayerGenerator(String input, int num_priorities, boolean ground_truth_pifo, double tp_rate, double tn_rate) {
        SimulationLogger.logInfo("Transport layer", "DDoS");
        this.input = input;
        this.num_priorities = num_priorities;
        this.ground_truth_pifo = ground_truth_pifo;
        this.tp_rate = tp_rate;
        this.tn_rate = tn_rate;
    }

    @Override
    public TransportLayer generate(int identifier) {
        return new DDoSTransportLayer(identifier, this.input, this.num_priorities, this.ground_truth_pifo, this.tp_rate, this.tn_rate);
    }

}
