package ch.ethz.systems.netbench.xpt.udp;

import ch.ethz.systems.netbench.core.network.Socket;
import ch.ethz.systems.netbench.core.network.TransportLayer;

public class UdpTransportLayer extends TransportLayer {

    /**
     * Create the UDP transport layer with the given network device identifier.
     * The network device identifier is used to create unique flow identifiers.
     *
     * @param identifier        Parent network device identifier
     */
    public UdpTransportLayer(int identifier) {
        super(identifier);
    }

    @Override
    protected Socket createSocket(long flowId, int destinationId, long flowSizeByte) {
        return new UdpSocket(this, flowId, this.identifier, destinationId, flowSizeByte);
    }

}
