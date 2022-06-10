package ch.ethz.systems.netbench.xpt.ddos;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Event;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;

/**
 * Event for the creation of a new packet. Called to replay pcap traces.
 */
public class PacketCreationEvent extends Event {

    private final Packet packet;
    private final TransportLayer transportLayer;

    /**
     * Packet creation event constructor.
     *
     * @param timeFromNowNs             Time in simulation nanoseconds from now
     * @param packet                    Packet instance which will be created
     */
    PacketCreationEvent(long timeFromNowNs, Packet packet, TransportLayer transportLayer) {
        super(timeFromNowNs);
        this.packet = packet;
        this.transportLayer = transportLayer;
    }

    @Override
    public void trigger() {
        // We extract the maliciousness from the packet, which is carried in the URG flag
        FullExtTcpPacket fullpkt = (FullExtTcpPacket)packet;

        if (fullpkt.isURG()) {
            SimulationLogger.increaseStatisticCounter("MALICIOUS_PACKETS_SENT"); // This just does + 1 (since length not added)
        } else {
            SimulationLogger.increaseStatisticCounter("BENIGN_PACKETS_SENT");
        }
        SimulationLogger.increaseStatisticCounter("PACKETS_SENT");
        transportLayer.send(packet);

        // Here we will log the input throughput (generated packets sent to the network device)
        if (SimulationLogger.hasInputThroughputTrackingEnabled()){
            SimulationLogger.logInputThroughput(Simulator.getCurrentTime(), packet.getSizeBit(), fullpkt.isURG());
        }
    }

    @Override
    public String toString() {
        return "PacketCreationEvent<" + this.getTime() + ", " + this.packet + ">";
    }
}
