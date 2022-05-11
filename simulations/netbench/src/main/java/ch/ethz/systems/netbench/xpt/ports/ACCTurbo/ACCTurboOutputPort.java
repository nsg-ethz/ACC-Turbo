package ch.ethz.systems.netbench.xpt.ports.ACCTurbo;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.*;
import ch.ethz.systems.netbench.ext.basic.IpHeader;
import ch.ethz.systems.netbench.xpt.ports.PriorityQueues.PriorityQueues;

import java.util.*;

public class ACCTurboOutputPort extends OutputPort {

    private long counterFlow1;
    private long counterFlow2;
    private long counterFlow3;
    private long counterFlow4;
    private long counterFlow5;

    private int priorityFlow1;
    private int priorityFlow2;
    private int priorityFlow3;
    private int priorityFlow4;
    private int priorityFlow5;

    public ACCTurboOutputPort(NetworkDevice ownNetworkDevice, NetworkDevice targetNetworkDevice, Link link, long numberQueues, long sizePerQueuePackets) {
        super(ownNetworkDevice, targetNetworkDevice, link, new PriorityQueues(numberQueues, sizePerQueuePackets, ownNetworkDevice));
        this.counterFlow1 = 0;
        this.counterFlow2 = 0;
        this.counterFlow3 = 0;
        this.counterFlow4 = 0;
        this.counterFlow5 = 0;

        // We first map them all to the highest-priority queue (note that lowest_qid is highest_priority)
        this.priorityFlow1 = 0;
        this.priorityFlow2 = 0;
        this.priorityFlow3 = 0;
        this.priorityFlow4 = 0;
        this.priorityFlow5 = 0;

        UpdatePrioritiesEvent updatePrioritiesEvent = new UpdatePrioritiesEvent(1000000000L, this); // At each ms
        Simulator.registerEvent(updatePrioritiesEvent);
    }

    void update_priorities() {

        // Compute the new priorities, sorting the clusters by throughput
        HashMap<String, Long> counters = new HashMap<>();
        counters.put("flow1", this.counterFlow1);
        counters.put("flow2", this.counterFlow2);
        counters.put("flow3", this.counterFlow3);
        counters.put("flow4", this.counterFlow4);
        counters.put("flow5", this.counterFlow5);
        Map<String, Long> sorted_counters = this.sortByValues(counters);

        Set set2 = sorted_counters.entrySet();
        Iterator iterator2 = set2.iterator();
        int newPriority = 0;
        while(iterator2.hasNext()) {
            Map.Entry me = (Map.Entry)iterator2.next();
            //System.out.print(me.getKey() + ": ");
            //System.out.print(me.getValue() + " -> priority: ");
            //System.out.println(newPriority);

            if (me.getKey() == "flow1"){
                this.priorityFlow1 = newPriority;
            } else if (me.getKey() == "flow2"){
                this.priorityFlow2 = newPriority;
            } else if (me.getKey() == "flow3"){
                this.priorityFlow3 = newPriority;
            } else if (me.getKey() == "flow4"){
                this.priorityFlow4 = newPriority;
            } else {
                this.priorityFlow5 = newPriority;
            }

            newPriority = newPriority + 1;
        }

        // Reset the counters
        this.counterFlow1 = 0;
        this.counterFlow2 = 0;
        this.counterFlow3 = 0;
        this.counterFlow4 = 0;
        this.counterFlow5 = 0;

        // When the processing is finished, we schedule it again for SUSTAINED CONGESTION PERIOD ns from now
        UpdatePrioritiesEvent updatePrioritiesEvent = new UpdatePrioritiesEvent(100000000L, this); // At each ms
        Simulator.registerEvent(updatePrioritiesEvent);
    }

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

            //  We first compute the priority to which each packet should be enqueued
            int priority = 0;
            if (packet.getFlowId() == 1) {
                counterFlow1 = counterFlow1 + 1;
                priority = priorityFlow1;
            } else if (packet.getFlowId() == 2){
                counterFlow2 = counterFlow2 + 1;
                priority = priorityFlow2;
            } else if (packet.getFlowId() == 3){
                counterFlow3 = counterFlow3 + 1;
                priority = priorityFlow3;
            } else if (packet.getFlowId() == 4){
                counterFlow4 = counterFlow4 + 1;
                priority = priorityFlow4;
            } else if (packet.getFlowId() == 5){
                counterFlow5 = counterFlow5 + 1;
                priority = priorityFlow5;
            }
            PriorityQueues pq = (PriorityQueues)this.getQueue();
            boolean enqueued = pq.offerToPriorityQueue(packet, priority);

            if (enqueued){
                // Update buffer size with enqueued packet
                increaseBufferOccupiedBits(packet.getSizeBit());
                getLogger().logQueueState(getQueue().size(), getBufferOccupiedBits());
            } else {

                // Log the packet drop
                if(SimulationLogger.hasAggregateDropsTrackingEnabled() && packet.getFlowId() != 5){
                    SimulationLogger.logAggregateDrops(Simulator.getCurrentTime(), packet.getSizeBit(), packet.getFlowId());
                }

                // Logging dropped packet
                SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED");
                IpHeader ipHeader = (IpHeader) packet;
                if (ipHeader.getSourceId() == this.getOwnId()) {
                    SimulationLogger.increaseStatisticCounter("PACKETS_DROPPED_AT_SOURCE");
                }
            }
        }
    }

    private HashMap sortByValues(HashMap map) {
        List list = new LinkedList(map.entrySet());
        // Defined Custom Comparator here
        Collections.sort(list, new Comparator() {
            public int compare(Object o1, Object o2) {
                return ((Comparable) ((Map.Entry) (o1)).getValue())
                        .compareTo(((Map.Entry) (o2)).getValue());
            }
        });

        // Here I am copying the sorted list in HashMap
        // using LinkedHashMap to preserve the insertion order
        HashMap sortedHashMap = new LinkedHashMap();
        for (Iterator it = list.iterator(); it.hasNext();) {
            Map.Entry entry = (Map.Entry) it.next();
            sortedHashMap.put(entry.getKey(), entry.getValue());
        }
        return sortedHashMap;
    }

}
