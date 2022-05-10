package ch.ethz.systems.netbench.xpt.cbr;

import ch.ethz.systems.netbench.core.network.Socket;
import ch.ethz.systems.netbench.core.network.TransportLayer;

public class CBRTransportLayer extends TransportLayer {

    private boolean randomEnabled;

    public CBRTransportLayer(int identifier, boolean randomEnabled) {
        super(identifier);
        this.randomEnabled = randomEnabled;
    }

    @Override // Not used
    protected Socket createSocket(long flowId, int destinationId, long flowSizeByte) {
        return null;
    }

    public void startCBRFlow(long flowId, int destinationId,
            int packetSize, Float rate, long timeStart, long timeEnd) {

        // Create new outgoing socket
        CBRSocket socket = new CBRSocket(this, flowId, this.identifier, destinationId,
             packetSize, rate,  timeStart, timeEnd, randomEnabled);

        // Start the socket off as initiator
        socket.markAsSender();
        socket.start();
    }

}
