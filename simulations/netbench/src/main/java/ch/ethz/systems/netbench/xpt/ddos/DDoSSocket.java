package ch.ethz.systems.netbench.xpt.ddos;

import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Packet;
import io.pkts.PacketHandler;
import ch.ethz.systems.netbench.core.network.Socket;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;import java.io.IOException;

// Replays a PCAP, feeding its data into TCP packets. Full traffic blast (UDP style), no handshake, no congestion control.
public class DDoSSocket extends Socket {

    // Maximum flow size allowed in bytes (1 terabyte)
    private static final long MAXIMUM_FLOW_SIZE = 1000000000000L;

    private String input;
    private int num_priorities;
    private double tp_rate, tn_rate;
    private boolean ground_truth_pifo;

    /**
     * Create a DDoS socket. It reads a pcap file of packets and sends them
     * without ACKs nor congestion control. Just pcap replay (just time and packet sizes from pcap).
     * The receiver just extracts statistics of packet drops.
     * By default, it is the receiver.
     */
    public DDoSSocket(TransportLayer transportLayer, long flowId, int sourceId, int destinationId, long flowSizeByte, String input, int num_priorities, boolean ground_truth_pifo, double tp_rate, double tn_rate) {
        super(transportLayer, flowId, sourceId, destinationId, flowSizeByte);

        // Too large flow size
        if (flowSizeByte > MAXIMUM_FLOW_SIZE) {
            throw new IllegalArgumentException("The maximum flow size is 1TB, it is not allowed to exceed this maximum by starting a flow of size " + flowSizeByte + " bytes.");
        }

        this.input = input;
        this.num_priorities = num_priorities;
        this.ground_truth_pifo = ground_truth_pifo;
        this.tp_rate = tp_rate;
        this.tn_rate = tn_rate;
    }

    /**
     * Use the {@link #start() start} method to make the socket a
     * sender and initiate the communication.
     */
    @Override
    public void start() {

        try {
            io.pkts.Pcap pcap = io.pkts.Pcap.openStream(this.input);

            PacketHandler pktHandler = new ExtendedPacketHandler(transportLayer, this, this.num_priorities, this.ground_truth_pifo, this.tp_rate, this.tn_rate);
            pcap.loop(pktHandler);

        } catch (IOException ex) {
            System.out.println(ex.getMessage());
        }
    }

    /**
     * Used by the receiver to process packets. The sender should not receive any packet. Is unidirectional flow.
     */
    @Override
    public void handle(Packet genericPacket) {

        FullExtTcpPacket packet = (FullExtTcpPacket) genericPacket;

        // Logging of benign and malicious packets
        if (packet.isURG()) {
            SimulationLogger.increaseStatisticCounter("MALICIOUS_PACKETS_RECEIVED"); // This just does + 1 (since length not added)
        } else {
            SimulationLogger.increaseStatisticCounter("BENIGN_PACKETS_RECEIVED");
        }
    }

    // We set seq. number, ack number, and all flags to zero
    // Important, we use URG flag to carry maliciousness
    public FullExtTcpPacket createPacket(
            long dataSizeByte, long priority, boolean malicious
    ) {
        return new FullExtTcpPacket(
                this.flowId, dataSizeByte, this.sourceId, this.destinationId,
                100, 80, 80, // TTL, source port, destination port
                0, 0, // Seq number, Ack number
                false, false, false, // NS, CWR, ECE
                malicious, false, false, // URG, ACK, PSH
                false, false, false, // RST, SYN, FIN
                0, priority // Window size, Priority
        );
    }
}