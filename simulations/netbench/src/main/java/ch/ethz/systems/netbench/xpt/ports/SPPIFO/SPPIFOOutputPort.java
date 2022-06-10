package ch.ethz.systems.netbench.xpt.ports.SPPIFO;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.*;
import ch.ethz.systems.netbench.ext.basic.IpHeader;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;


public class SPPIFOOutputPort extends OutputPort {

    public SPPIFOOutputPort(NetworkDevice ownNetworkDevice, NetworkDevice targetNetworkDevice, Link link, long numberQueues, long sizePerQueuePackets, String stepSize) {
        super(ownNetworkDevice, targetNetworkDevice, link, new SPPIFOQueue(numberQueues, sizePerQueuePackets, ownNetworkDevice, stepSize));
    }

    /**
     * Enqueue the given packet.
     * To control droppings
     * There is no guarantee that the packet is actually sent,
     * as the queue buffer's limit might be reached.
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

        } else { // If it is still sending, the packet is added to the queue, making it non-empty

            boolean enqueued = false;
            enqueued = getQueue().offer(packet);

            if (enqueued){

                // Update buffer size with enqueued packet
                increaseBufferOccupiedBits(packet.getSizeBit());
                getLogger().logQueueState(getQueue().size(), getBufferOccupiedBits());

            } else {

                // Logging dropped packet
                SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED");
                IpHeader ipHeader = (IpHeader) packet;
                if (ipHeader.getSourceId() == this.getOwnId()) {
                    SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED_AT_SOURCE");
                }

                if (packet.isTCP()){ //TODO: Add a tag such that is just the ddos logging
                    FullExtTcpPacket fpkt = (FullExtTcpPacket) packet;
                    // Logging of benign and malicious packets
                    if (fpkt.isURG()) {
                        SimulationLogger.increaseStatisticCounter("MALICIOUS_PACKETS_DROPPED"); // This just does + 1 (since length not added)
                    } else {
                        SimulationLogger.increaseStatisticCounter("BENIGN_PACKETS_DROPPED");
                    }                    
                }

            }
        }
    }


}
