package ch.ethz.systems.netbench.core.network;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;
import ch.ethz.systems.netbench.xpt.udp.UdpPacket;
import io.pkts.packet.UDPPacket;

/**
 * Event for the complete arrival of a packet in its entirety.
 */
public class PacketArrivalEvent extends Event {

    private final NetworkDevice arrivalNetworkDevice;
    private final Packet packet;

    /**
     * Packet arrival event constructor.
     *
     * @param timeFromNowNs             Time in simulation nanoseconds from now
     * @param packet                    Packet instance which will arrive
     * @param arrivalNetworkDevice      Network device at which the packet arrives
     */
    PacketArrivalEvent(long timeFromNowNs, Packet packet, NetworkDevice arrivalNetworkDevice) {
        super(timeFromNowNs);
        this.packet = packet;
        this.arrivalNetworkDevice = arrivalNetworkDevice;
    }

    @Override
    public void trigger() {
        arrivalNetworkDevice.receive(packet);

        // Here we will log the output throughput (received packets in the other side of the link)
        if (SimulationLogger.hasOutputThroughputTrackingEnabled()){
            // We extract the maliciousness from the packet, which is carried in the URG flag
            FullExtTcpPacket fullpkt = (FullExtTcpPacket)packet;
            SimulationLogger.logOutputThroughput(Simulator.getCurrentTime(), packet.getSizeBit(), fullpkt.isURG());
        }

        if (SimulationLogger.hasAggregateOutputThroughputTrackingEnabled()){
            UdpPacket p = (UdpPacket)packet;
            SimulationLogger.logAggregateOutputThroughput(Simulator.getCurrentTime(), packet.getSizeBit(), p.getFlowId());
        }

    }

    @Override
    public String toString() {
        return "PacketArrivalEvent<" + arrivalNetworkDevice.getIdentifier() + ", " + this.getTime() + ", " + this.packet + ">";
    }

}
