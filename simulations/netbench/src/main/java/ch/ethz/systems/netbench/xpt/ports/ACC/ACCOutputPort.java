package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.*;
import ch.ethz.systems.netbench.ext.basic.IpHeader;
import ch.ethz.systems.netbench.ext.basic.IpPacket;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;

// Implementation of ACC. Translated to java from the original code: https://sources.debian.org/src/ns2/2.35%2Bdfsg-3.1/pushback/
public class ACCOutputPort extends OutputPort {

    private final long maxQueueSize;

    public ACCOutputPort(NetworkDevice ownNetworkDevice, NetworkDevice targetNetworkDevice, Link link, long maxQueueSize, boolean enableRateLimiting, double sustainedCongestionPeriod, double q_weight, int th_min, int th_max, boolean enable_gentle, int averagePacketSize, boolean wait) {
        super(ownNetworkDevice, targetNetworkDevice, link, new ACCQueue(ownNetworkDevice, link, enableRateLimiting, sustainedCongestionPeriod, q_weight, th_min, th_max, enable_gentle, averagePacketSize, wait));
        this.maxQueueSize = maxQueueSize;
    }

    /**
     * Enqueue the given packet.
     * There is no guarantee that the packet is actually sent,
     * as the queue buffer's limit might be reached. If the limit is reached,
     * the packet with lower priority (higher rank) is dropped.
     * @param packet    Packet instance
     */
    @Override
    public void enqueue(Packet packet) {


        // If it is not sending, then the queue is empty at the moment,
        // so this packet can be immediately send
        if (!getIsSending()) {

            // Link is now being utilized
            getLogger().logLinkUtilized(true);

            // Add event when sending is finished
            Simulator.registerEvent(new PacketDispatchedEvent(
                    (long)((double)packet.getSizeBit() / getLink().getBandwidthBitPerNs()),
                    packet,
                    this
            ));

            // It is now sending again
            setIsSending();

            // Log packet for debugging
            if(SimulationLogger.hasPacketsTrackingEnabled()){
                FullExtTcpPacket pk = (FullExtTcpPacket)packet;
                SimulationLogger.logPacket("Time: " + Simulator.getCurrentTime() + " => Packet sent (no queue): SeqNo: " + pk.getSequenceNumber() + ", ACKNo: " + pk.getAcknowledgementNumber() + ", Priority: "+ pk.getPriority());
            }

        } else { // If it is still sending, the packet is added to the queue

            // Log packet for debugging
            if(SimulationLogger.hasPacketsTrackingEnabled()) {
                FullExtTcpPacket pk = (FullExtTcpPacket)packet;
                SimulationLogger.logPacket("Time: " + Simulator.getCurrentTime() + " => Packet enqueued: SeqNo: " + pk.getSequenceNumber() + ", ACKNo: " + pk.getAcknowledgementNumber() + ", Priority: " + pk.getPriority());
            }

            // We tag the enqueue time to the packet, before offering it to RED Queue
            packet.setEnqueueTime(Simulator.getCurrentTime());

            // Tail-drop enqueue
            if (getQueueSize() <= maxQueueSize-1) {

                // Enqueue to the RED queue
                ACCQueue pq = (ACCQueue) getQueue();
                Packet droppedPacket = pq.offerPacket(packet);

                // Update buffer size with enqueued packet
                increaseBufferOccupiedBits(packet.getSizeBit());
                getLogger().logQueueState(pq.size(), getBufferOccupiedBits());

                if (droppedPacket != null) {

                    // Update buffer size with dropped packet
                    decreaseBufferOccupiedBits(droppedPacket.getSizeBit());
                    getLogger().logQueueState(pq.size(), getBufferOccupiedBits());

                    // The packet has been dropped because of Pushback.
                    // Logging dropped packet
                    SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED");
                    IpHeader ipHeader = (IpHeader) droppedPacket;
                    if (ipHeader.getSourceId() == this.getOwnId()) {
                        SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED_AT_SOURCE");
                    }
                }

            } else {

                // We have a normal tail-drop (the queue is full, so the packet can't get in).
                // Logging dropped packet
                SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED");
                IpPacket p = (IpPacket) packet;
                if (p.getSourceId() == this.getOwnId()) {
                    SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED_AT_SOURCE");
                }
            }
        }
    }
}
