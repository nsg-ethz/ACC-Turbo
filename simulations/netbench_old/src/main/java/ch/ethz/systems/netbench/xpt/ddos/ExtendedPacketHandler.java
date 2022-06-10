package ch.ethz.systems.netbench.xpt.ddos;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;
import io.pkts.PacketHandler;
import io.pkts.protocol.Protocol;

import java.io.IOException;
import java.util.Random;

public class ExtendedPacketHandler implements PacketHandler {

    private long timeFromNowNs;
    private long originTimeNs;
    private boolean firstPacket;
    private TransportLayer transportLayer;
    private DDoSSocket socket;
    private int num_priorities;
    private double tp_rate, tn_rate;
    private boolean ground_truth_pifo;
    private Random independentRng;

    public  ExtendedPacketHandler(TransportLayer transportLayer, DDoSSocket socket, int num_priorities, boolean ground_truth_pifo, double tp_rate, double tn_rate){
        this.timeFromNowNs = 0;
        this.originTimeNs = 0;
        this.firstPacket = true;
        this.transportLayer = transportLayer;
        this.socket = socket;
        this.num_priorities = num_priorities;
        this.ground_truth_pifo = ground_truth_pifo;
        this.tp_rate = tp_rate;
        this.tn_rate = tn_rate;
        this.independentRng = new Random();
    }

    @Override
    public boolean nextPacket(final io.pkts.packet.Packet packet) throws IOException {
        if (packet.hasProtocol(Protocol.ETHERNET_II)) {
            int priority = 0;

            if(this.num_priorities != -1) {

                // We extract the priority from the ethernet header
                io.pkts.packet.MACPacket eth = (io.pkts.packet.MACPacket) packet.getPacket(Protocol.ETHERNET_II);
                String[] macBytes = eth.getSourceMacAddress().split(":");
                priority = Integer.parseInt(macBytes[macBytes.length-1], 16);

                // We convert the priority (higher better) to rank (lower better)
                priority = (this.num_priorities - 1) - priority;
            }

            if (packet.hasProtocol(io.pkts.protocol.Protocol.IPv4)) {
                io.pkts.packet.IPPacket ip = (io.pkts.packet.IPPacket) packet.getPacket(io.pkts.protocol.Protocol.IPv4);

                // The arrival time of this packet in microseconds relative to epoch (midnight UTC of January 1, 1970)
                long packetTime = ip.getArrivalTime();

                //The IP addresses involved
                String dstip = ip.getDestinationIP();
                String srcip = ip.getSourceIP();

                // This 16-bit field defines the entire packet (fragment) size, including header and data, in bytes.
                int length = ip.getTotalIPLength();

                // Netbench will convert the amountToSendByte to bits, and will add a TCP header and IP header of 60 bytes each
                // Therefore, we decrease the packet size 120 bytes not to modify the core program
                Long amountToSendByte = new Long(length - 120);

                // For each packet that we read from the pcap file, we generate a packet in the simulator and send it.
                // We just send all packets as the same flow
                if (firstPacket) {
                    timeFromNowNs = 0;
                    firstPacket = false;
                    originTimeNs = packetTime * 1000; // Microseconds to nanoseconds
                } else {
                    timeFromNowNs = (packetTime * 1000) - originTimeNs;
                }

                // It can be that we send just headers
                if (length > 0) {
                    boolean malicious = false;
                    if (srcip.equals("172.16.0.5")){ // Canadian dataset
                    //if (srcip.equals("192.168.0.5")) { // Morphing attack
                        malicious = true;
                    }
                    
                    if (this.ground_truth_pifo) {
                        if (malicious) {
                            // tp_rate (0 to 1) defines the rate of positives (malicious packets) that are classified as such
                            // tp_rate = 1 means that all malicious packets are classified as such (and are mapped into the low priority queue)
                            priority = 0;
                            double rand = this.independentRng.nextDouble(); // Random between 0 and 1
                            if (rand < tp_rate) {
                                priority = 1;
                            }
                        } else {
                            // tn_rate = 1 means that all benign packets are classified as such (and are mapped into the high priority queue)
                            priority = 1;
                            double rand = this.independentRng.nextDouble();
                            if (rand < tn_rate) {
                                priority = 0;
                            }
                        }
                    }
                    FullExtTcpPacket pkt = socket.createPacket(amountToSendByte, (long) priority, malicious);

                    // We don't perform any rate limiting in the traffic generation, we just replay the pcap.
                    // The rate limiting will come in the output port.
                    // Add event when sending is finished
                    Simulator.registerEvent(new PacketCreationEvent(this.timeFromNowNs, pkt, this.transportLayer));
                }
            }
        }
        return true;
    }
}