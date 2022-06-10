package ch.ethz.systems.netbench.xpt.sppifo.ports.FIFO;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.NetworkDevice;
import ch.ethz.systems.netbench.core.network.Link;
import ch.ethz.systems.netbench.core.network.OutputPort;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.ext.basic.IpHeader;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;

import java.util.concurrent.LinkedBlockingQueue;

public class FIFOOutputPort extends OutputPort {

    private final long maxQueueSize;

    FIFOOutputPort(NetworkDevice ownNetworkDevice, NetworkDevice targetNetworkDevice, Link link, long maxQueueSize) {
        super(ownNetworkDevice, targetNetworkDevice, link, new LinkedBlockingQueue<Packet>());
        this.maxQueueSize = maxQueueSize;
    }

    /**
     * Enqueue the given packet.
     * Drops it if the queue is full (tail drop).
     * @param packet    Packet instance
     */
    @Override
    public void enqueue(Packet packet) {

        // Convert to IP packet
        IpHeader ipHeader = (IpHeader) packet;

        // Mark congestion flag if size of the queue is too big
        //if (getBufferOccupiedBits() >= 8L*12000) {
        //    ipHeader.markCongestionEncountered();
        //}

        // Tail-drop enqueue
        if (getQueueSize() <= maxQueueSize-1) {

            // Check whether there is an inversion for the packet enqueued
            /*if (SimulationLogger.hasInversionsTrackingEnabled()){

                // Extract the packet rank
                FullExtTcpPacket p = (FullExtTcpPacket) packet;

                // We compute the perceived rank
                Object[] contentPIFO = super.getQueue().toArray();
                if (contentPIFO.length > 0){
                    Arrays.sort(contentPIFO);
                    FullExtTcpPacket packet_maxrank = (FullExtTcpPacket) contentPIFO[contentPIFO.length-1];
                    int rank_perceived = (int)packet_maxrank.getPriority();

                    // We measure the inversion
                    if (rank_perceived > p.getPriority()){
                        SimulationLogger.logInversionsPerRank(this.getOwnId(), (int) p.getPriority(), 1);
                    }
                }
            }*/
            guaranteedEnqueue(packet);

        } else {

            FullExtTcpPacket fpkt = (FullExtTcpPacket) packet;
            // Logging of benign and malicious packets
            if (fpkt.isURG()) {
                SimulationLogger.increaseStatisticCounter("MALICIOUS_PACKETS_DROPPED"); // This just does + 1 (since length not added)
            } else {
                SimulationLogger.increaseStatisticCounter("BENIGN_PACKETS_DROPPED");
            }

            SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED");
            if (ipHeader.getSourceId() == this.getOwnId()) {
                SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED_AT_SOURCE");
            }

            if (SimulationLogger.hasPacketDropsTrackingEnabled()){
                // We extract the maliciousness from the packet, which is carried in the URG flag
                FullExtTcpPacket fullpkt = (FullExtTcpPacket)packet;
                SimulationLogger.logPacketDrops(Simulator.getCurrentTime(), packet.getSizeBit(), fullpkt.isURG());
            }
        }
    }
}
