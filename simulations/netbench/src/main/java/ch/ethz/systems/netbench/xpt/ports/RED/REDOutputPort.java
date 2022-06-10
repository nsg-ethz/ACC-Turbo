package ch.ethz.systems.netbench.xpt.ports.RED;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.*;
import ch.ethz.systems.netbench.ext.basic.IpHeader;
import ch.ethz.systems.netbench.ext.basic.IpPacket;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;


public class REDOutputPort extends OutputPort {

    private final long maxQueueSize;

    REDOutputPort(NetworkDevice ownNetworkDevice, NetworkDevice targetNetworkDevice, Link link, long maxQueueSize, double q_weight, int th_min, int th_max, boolean enable_gentle, int averagePacketSize, boolean wait) {
        super(ownNetworkDevice, targetNetworkDevice, link, new REDQueue(link, q_weight, th_min, th_max, enable_gentle, averagePacketSize, wait));
        this.maxQueueSize = maxQueueSize;
    }

        /**
         * Enqueue the given packet.
         * There is no guarantee that the packet is actually sent.
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
                REDQueue rq = (REDQueue) getQueue();
                Packet droppedPacket = rq.offerPacket(packet);

                // Update buffer size with enqueued packet
                increaseBufferOccupiedBits(packet.getSizeBit());
                getLogger().logQueueState(rq.size(), getBufferOccupiedBits());

                if (droppedPacket != null) {

                    // Update buffer size with dropped packet
                    decreaseBufferOccupiedBits(droppedPacket.getSizeBit());
                    getLogger().logQueueState(rq.size(), getBufferOccupiedBits());

                    // The packet has been dropped because of RED. This can be because
                    // a) Avg queue size > Th Max. (forced drop)
                    // b) Th Min < Avg queue size < Th Max and the packet was probabilistically dropped

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
