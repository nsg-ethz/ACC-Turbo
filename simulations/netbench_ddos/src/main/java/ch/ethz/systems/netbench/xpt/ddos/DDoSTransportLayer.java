package ch.ethz.systems.netbench.xpt.ddos;

import ch.ethz.systems.netbench.core.network.Socket;
import ch.ethz.systems.netbench.core.network.TransportLayer;

public class DDoSTransportLayer extends TransportLayer {

    private String input;
    private int num_priorities;
    private double tp_rate, tn_rate;
    private boolean ground_truth_pifo;

    public DDoSTransportLayer(int identifier, String input, int num_priorities, boolean ground_truth_pifo, double tp_rate, double tn_rate) {
        super(identifier);
        this.input = input;
        this.num_priorities = num_priorities;
        this.ground_truth_pifo = ground_truth_pifo;
        this.tp_rate = tp_rate;
        this.tn_rate = tn_rate;
    }

    @Override
    protected Socket createSocket(long flowId, int destinationId, long flowSizeByte) {
        return new DDoSSocket(this, flowId, this.identifier, destinationId, flowSizeByte, this.input, this.num_priorities, this.ground_truth_pifo, this.tp_rate, this.tn_rate);
    }

}
