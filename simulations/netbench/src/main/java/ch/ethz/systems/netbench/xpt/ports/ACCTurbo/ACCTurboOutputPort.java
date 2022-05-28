package ch.ethz.systems.netbench.xpt.ports.ACCTurbo;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.*;
import ch.ethz.systems.netbench.ext.basic.IpHeader;
import ch.ethz.systems.netbench.xpt.ports.PriorityQueues.PriorityQueues;

import java.util.*;

public class ACCTurboOutputPort extends OutputPort {

    private int currentClusterId;
    private ArrayList<ACCTurboCluster> clusterList;
    private int numClusters;

    public ACCTurboOutputPort(NetworkDevice ownNetworkDevice, NetworkDevice targetNetworkDevice, Link link, long numberQueues, long sizePerQueuePackets) {
        super(ownNetworkDevice, targetNetworkDevice, link, new PriorityQueues(numberQueues, sizePerQueuePackets, ownNetworkDevice));
        UpdatePrioritiesEvent updatePrioritiesEvent = new UpdatePrioritiesEvent(1000000000L, this); // At each second
        Simulator.registerEvent(updatePrioritiesEvent);
        this.clusterList = new ArrayList<ACCTurboCluster>();
        this.currentClusterId = 1;
        this.numClusters = (int)numberQueues;
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

            //  We cluster the packets based on their flow IDs
            long flowId = packet.getFlowId();
            ACCTurboCluster selectedCluster;
            ACCTurboSignature packetSignature = new ACCTurboSignature(flowId, flowId);

            //  Create new cluster for the packet (note that we do not update current_cluster_id straight away, since we will only use that cluster id if the new cluster is selected.
            //  If the new cluster is merged to an existing one, we don't need to update the current_cluster_id)
            ACCTurboCluster newCluster = new ACCTurboCluster(packetSignature, this.currentClusterId, this.numClusters);

            //  If the cluster list is empty, we just add the new custer to the list
            if (this.clusterList.size() == 0 && this.numClusters > 1) {

                //  Append the new cluster directly to the list
                clusterList.add(newCluster);
                this.currentClusterId = this.currentClusterId + 1;
                selectedCluster = newCluster;

            } else { //  If it is not empty, we compute the minimum distance (to the clusters in the list)

                //  Compute the distances of the new (virtual) cluster with all existing clusters
                Iterator iter = clusterList.iterator();
                long distance;
                long minDistance = 0;
                ACCTurboCluster minCluster = null;
                boolean isFirst = true;
                while (iter.hasNext()) {
                    ACCTurboCluster existingCluster = (ACCTurboCluster) iter.next();
                    distance = this.computeDistanceManhattan(existingCluster, newCluster);
                    if (isFirst) {
                        minDistance = distance;
                        minCluster = existingCluster;
                        isFirst = false;
                    } else {
                        if (distance < minDistance) {
                            minDistance = distance;
                            minCluster = existingCluster;
                        }
                    }
                }

                //  Then we decide. If the list is already full, then we merge to the closest distance
                if (this.clusterList.size() >= this.numClusters) {

                    //  Merge the new cluster to the closest one
                    this.mergeCluster(newCluster, minCluster);
                    minCluster.update_num_packets(newCluster);
                    selectedCluster = minCluster;
                } else {

                    //  If the list is not full, we decide whether we want to create a new cluster or merge to the closest one.
                    if (minDistance == 0) {
                        //  Merge the new cluster to the closest one
                        this.mergeCluster(newCluster, minCluster);
                        minCluster.update_num_packets(newCluster);
                        selectedCluster = minCluster;
                    } else {

                        //  Append the new cluster directly to the list
                        this.clusterList.add(newCluster);
                        selectedCluster = newCluster;
                        this.currentClusterId = this.currentClusterId + 1;

                        //  We append the label (cluster_id) to the list
                    }
                }
            }

            // We set the packet's priority based on its selected cluster
            int priority = selectedCluster.getPriority();

            // We enqueue the packet based on this priority
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



    // Computes the distance between two clusters. Used to decide which clusters to merge during the clustering process.
    private long computeDistanceManhattan(ACCTurboCluster cluster_a, ACCTurboCluster cluster_b) {

        long distance = 0;

        // We consider flow IDs as ordinal features. It is the only feature we use for clustering.

        // Helper: |min(cluster_a) ......max(cluster_a) |   <->   |min(cluster_b) ......max(cluster_b) |
        // if max(cluster_a) < min(cluster_b):distance = min(cluster_b) - max(cluster_a)
        if (cluster_a.getSignature().getMax() < cluster_b.getSignature().getMin()) {
            distance = cluster_b.getSignature().getMin() - cluster_a.getSignature().getMax();
        }

        // Helper: | min(cluster_b) ...... max(cluster_b) |   <->   | min(cluster_a) ...... max(cluster_a) |
        // if min(cluster_a) > max(cluster_b): distance = min(cluster_a) - max(cluster_b)
        else if (cluster_a.getSignature().getMin() > cluster_b.getSignature().getMax()) {
            distance = cluster_a.getSignature().getMin() - cluster_b.getSignature().getMax();
        }

        return distance;
    }

    // Method to merge cluster "srcCluster" into "dstCluster"
    private void mergeCluster(ACCTurboCluster srcCluster, ACCTurboCluster dstCluster) {

        // We merge the ranges of src_cluster.signature[feature] and dst_cluster.signature[feature]
        ACCTurboSignature signatureMergedCluster = new ACCTurboSignature(Math.min(dstCluster.getSignature().getMin(), srcCluster.getSignature().getMin()), Math.max(dstCluster.getSignature().getMax(), srcCluster.getSignature().getMax()));

        // We return the merged cluster
        dstCluster.setSignature(signatureMergedCluster);
    }


    void update_priorities() {

        // Compute the new priorities, sorting the clusters by throughput
        HashMap<Integer, Integer> clustersByThroughput = new HashMap<>();
        int list_position = 0;

        Iterator iterator = clusterList.iterator();
        while (iterator.hasNext()) {
            ACCTurboCluster currentCluster = (ACCTurboCluster) iterator.next();
            clustersByThroughput.put(list_position, currentCluster.getNumPackets());
            list_position = list_position + 1;
        }

        Map<Integer, Integer> sorted_counters = this.sortByValues(clustersByThroughput);
        int prio = this.numClusters - 1;
        Set set2 = sorted_counters.entrySet();
        Iterator iterator2 = set2.iterator();
        while(iterator2.hasNext()) {
            Map.Entry me = (Map.Entry)iterator2.next();
            this.clusterList.get((int) me.getKey()).setPriority(prio); // smaller throughput, bigger priority
            //System.out.print(me.getKey() + ": ");
            //System.out.print(me.getValue() + " -> priority: ");
            //System.out.println(newPriority);

            // Reset counters
            this.clusterList.get((int) me.getKey()).resetNumPackets();
        }

        // When the processing is finished, we schedule it again for SUSTAINED CONGESTION PERIOD ns from now
        UpdatePrioritiesEvent updatePrioritiesEvent = new UpdatePrioritiesEvent(100000000L, this); // At each ms
        Simulator.registerEvent(updatePrioritiesEvent);
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
