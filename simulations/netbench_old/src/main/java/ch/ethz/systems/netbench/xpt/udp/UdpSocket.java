package ch.ethz.systems.netbench.xpt.udp;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.core.network.Socket;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;

public class UdpSocket extends Socket {

    // Maximum flow size allowed in bytes (1 terabyte)
    private static final long MAXIMUM_FLOW_SIZE = 1000000000000L;

    // Maximum segment size (MSS) (data carried by a UDP packet);
    private final long MAX_SEGMENT_SIZE;

    private static final long FIRST_SEQ_NUMBER = 0;
    private long sendNextNumber;         //  Next sequence number to be used

    public UdpSocket(TransportLayer transportLayer, long flowId, int sourceId, int destinationId, long flowSizeByte) {
        super(transportLayer, flowId, sourceId, destinationId, flowSizeByte);

        // Too large flow size
        if (flowSizeByte > MAXIMUM_FLOW_SIZE) {
            throw new IllegalArgumentException("The maximum flow size is 1TB, it is not allowed to exceed this maximum by starting a flow of size " + flowSizeByte + " bytes.");
        }

        // Ethernet: 1500 - 8 (UDP header) - 60 (IP header) = 1432 bytes
        this.MAX_SEGMENT_SIZE = Simulator.getConfiguration().getLongPropertyWithDefault("TCP_MAX_SEGMENT_SIZE", 1432L);
        this.sendNextNumber = FIRST_SEQ_NUMBER;
    }

    /**
     * Makes the socket a sender and initiates the communication.
     */
    @Override
    public void start() {
        // Send packets until there is no longer any flow to send
        long amountToSendByte = getFlowSizeByte(sendNextNumber);

        while (amountToSendByte > 0) {
            UdpPacket packet = sendOutDataPacket(amountToSendByte);
            amountToSendByte = getFlowSizeByte(sendNextNumber);
        }
    }

    /**
     * Determine the flow size desired for the given sequence number.
     *
     * @param seq   Sequence number
     *
     * @return Flow size in bytes
     */
    protected long getFlowSizeByte(long seq) {
        return Math.min(MAX_SEGMENT_SIZE, flowSizeByte - seq + 1);
    }

    /**
     * Send out a data packet with the particular sequence number.
     *
     * @param amountToSendByte  Amount of data to send out
     */
    protected UdpPacket sendOutDataPacket(long amountToSendByte) {
        // Send
        UdpPacket packet = createPacket(amountToSendByte);
        transportLayer.send(packet);
        SimulationLogger.increaseStatisticCounter("UDP_PACKET_SENT");

        // Here we will log the input throughput (generated packets sent to the network device)
        if (SimulationLogger.hasAggregateInputThroughputTrackingEnabled()){
            SimulationLogger.logAggregateInputThroughput(Simulator.getCurrentTime(), packet.getSizeBit(), packet.getFlowId());
        }
        return packet;
    }

    /**
     * Used by the receiver to process packets. We don't do much
     */
    @Override
    public void handle(Packet genericPacket) {
        // We don't do any processing for packets received
        SimulationLogger.increaseStatisticCounter("UDP_PACKETS_RECEIVED"); // This just does + 1 (since length not added)
    }

    private UdpPacket createPacket(
            long dataSizeByte) {
        return new UdpPacket(
                flowId, dataSizeByte, sourceId, destinationId,
                100, 80, 80, // TTL, source port, destination port
                0,0 // Length, checksum
        );
    }
}
