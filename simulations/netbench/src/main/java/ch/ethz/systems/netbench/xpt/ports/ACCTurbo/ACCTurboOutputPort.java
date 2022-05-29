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
        UpdatePrioritiesEvent updatePrioritiesEvent = new UpdatePrioritiesEvent(100000000L, this); // At each second
        Simulator.registerEvent(updatePrioritiesEvent);
        this.clusterList = new ArrayList<ACCTurboCluster>();
        this.currentClusterId = 1;
        this.numClusters = (int)numberQueues;
    }

    @Override
    public void enqueue(Packet packet) {

        // -------------------------------------------------------------
        // ACC-Turbo processing
        // -------------------------------------------------------------

        //  We cluster the packets based on their flow IDs
        long flowId = packet.getFlowId();
        ACCTurboCluster selectedCluster;
        ACCTurboSignature packetSignature = new ACCTurboSignature(flowId, flowId);

        //  Create new cluster for the packet (note that we do not update current_cluster_id straight away, since we will only use that cluster id if the new cluster is selected.
        //  If the new cluster is merged to an existing one, we don't need to update the current_cluster_id)
        ACCTurboCluster newCluster = new ACCTurboCluster(packetSignature, this.numClusters);
        //System.out.println("New packet: [" + newCluster.getSignature().getMin() + ", " + newCluster.getSignature().getMax() + "]");

        //  If the cluster list is empty, we just add the new custer to the list
        if (this.clusterList.size() == 0) {

            //  Append the new cluster directly to the list
            clusterList.add(newCluster);
            System.out.println("Added new cluster: [" + newCluster.getSignature().getMin() + ", " + newCluster.getSignature().getMax() + "]");
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
                // System.out.println("Computed distance between clusters: [" + existingCluster.getSignature().getMin() + ", " + existingCluster.getSignature().getMax() + "] and ["
                //        + newCluster.getSignature().getMin() + ", " + newCluster.getSignature().getMax() + "] = " + distance);
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
            // System.out.println("Minimum distance= " + minDistance);

            //  Then we decide. If the list is already full, then we merge to the closest distance
            if (this.clusterList.size() >= this.numClusters) {

                //  Merge the new cluster to the closest one
                this.mergeCluster(newCluster, minCluster);
                //System.out.println("Packet : [" + newCluster.getSignature().getMin() + ", " + newCluster.getSignature().getMax() + "]" +
                //        " merged to cluster  [" + minCluster.getSignature().getMin() + ", " + minCluster.getSignature().getMax() + "]");

                minCluster.updateNumPackets(newCluster);
                selectedCluster = minCluster;
            } else {

                //  If the list is not full, we decide whether we want to create a new cluster or merge to the closest one.
                if (minDistance == 0) {
                    //  Merge the new cluster to the closest one
                    this.mergeCluster(newCluster, minCluster);
                    // System.out.println("Packet : [" + newCluster.getSignature().getMin() + ", " + newCluster.getSignature().getMax() + "]" +
                    //         " merged to cluster  [" + minCluster.getSignature().getMin() + ", " + minCluster.getSignature().getMax() + "]");
                    minCluster.updateNumPackets(newCluster);
                    selectedCluster = minCluster;
                } else {

                    //  Append the new cluster directly to the list
                    this.clusterList.add(newCluster);
                    System.out.println("Added new cluster: [" + newCluster.getSignature().getMin() + ", " + newCluster.getSignature().getMax() + "]");
                    selectedCluster = newCluster;
                    this.currentClusterId = this.currentClusterId + 1;
                }
            }
        }

        // We set the packet's priority based on its selected cluster
        int priority = (numClusters - 1) - selectedCluster.getPriority();

        // -------------------------------------------------------------

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


    void updatePriorities() {

        // Compute the new priorities, sorting the clusters by throughput
        HashMap<ACCTurboCluster, Integer> clustersByThroughput = new HashMap<>();

        Iterator iterator = clusterList.iterator();
        while (iterator.hasNext()) {
            ACCTurboCluster currentCluster = (ACCTurboCluster) iterator.next();
            clustersByThroughput.put(currentCluster, currentCluster.getNumPackets());
            // System.out.println("Cluster: [" + currentCluster.getSignature().getMin() + ", " + currentCluster.getSignature().getMax() + "] has numpackets " + currentCluster.getNumPackets());
        }

        Map<ACCTurboCluster, Integer> sorted_counters = this.sortByValues(clustersByThroughput);
        int prio = this.numClusters - 1;
        Set set2 = sorted_counters.entrySet();
        Iterator iterator2 = set2.iterator();
        while(iterator2.hasNext()) {
            Map.Entry me = (Map.Entry)iterator2.next();

            ACCTurboCluster c = (ACCTurboCluster) me.getKey();
            c.setPriority(prio);
            // System.out.println("Cluster: [" + c.getSignature().getMin() + ", " + c.getSignature().getMax() + "] has priority " + prio);
            prio = prio - 1;

            // Reset counters
            c.resetNumPackets();
        }

        // When the processing is finished, we schedule it again for SUSTAINED CONGESTION PERIOD ns from now
        UpdatePrioritiesEvent updatePrioritiesEvent = new UpdatePrioritiesEvent(100000000L, this);
        Simulator.registerEvent(updatePrioritiesEvent);
        // System.out.println("------------------");
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
