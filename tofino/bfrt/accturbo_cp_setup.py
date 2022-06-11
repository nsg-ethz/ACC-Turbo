import sys

# -----------------
# Ingress setup
# -----------------
ingress = bfrt.accturbo.pipe.MyIngress

# Table: tbl_compute_distance_cluster{1,2,3,4}_{dst0,dst1,dst2,dst3}_{min,max}
# Action: compute_distance_cluster{1,2,3,4}_{dst0,dst1,dst2,dst3}_{min,max}
# Key: ig_tm_md.ucast_egress_port (exact);
# Parameter: PortId_t, port

for port in range(512): # In fact we just use port 140, but this way we have accturbo configured for all ports

    # For the clusters' initialization
    ingress.init_counter.add(port)
    ingress.init_counter.mod(port, 1) # we initialize to 1 because cluster ids go from 1 to 4
    ingress.tbl_do_init_counter.add_with_do_init_counter(port, port)

    # For the resubmit configuration
    ingress.updateclusters_counter.add(port)
    ingress.updateclusters_counter.mod(port, 0)
    ingress.tbl_do_updateclusters_counter.add_with_do_updateclusters_counter(port, port)

    # Rest of configuration:
    ingress.cluster1_dst0_min.add(port)
    ingress.cluster2_dst0_min.add(port)
    ingress.cluster3_dst0_min.add(port)
    ingress.cluster4_dst0_min.add(port)

    ingress.cluster1_dst0_max.add(port)
    ingress.cluster2_dst0_max.add(port)
    ingress.cluster3_dst0_max.add(port)
    ingress.cluster4_dst0_max.add(port)

    ingress.cluster1_dst1_min.add(port)
    ingress.cluster2_dst1_min.add(port)
    ingress.cluster3_dst1_min.add(port)
    ingress.cluster4_dst1_min.add(port)

    ingress.cluster1_dst1_max.add(port)
    ingress.cluster2_dst1_max.add(port)
    ingress.cluster3_dst1_max.add(port)
    ingress.cluster4_dst1_max.add(port)

    ingress.cluster1_dst2_min.add(port)
    ingress.cluster2_dst2_min.add(port)
    ingress.cluster3_dst2_min.add(port)
    ingress.cluster4_dst2_min.add(port)

    ingress.cluster1_dst2_max.add(port)
    ingress.cluster2_dst2_max.add(port)
    ingress.cluster3_dst2_max.add(port)
    ingress.cluster4_dst2_max.add(port)

    ingress.cluster1_dst3_min.add(port)
    ingress.cluster2_dst3_min.add(port)
    ingress.cluster3_dst3_min.add(port)
    ingress.cluster4_dst3_min.add(port)

    ingress.cluster1_dst3_max.add(port)
    ingress.cluster2_dst3_max.add(port)
    ingress.cluster3_dst3_max.add(port)
    ingress.cluster4_dst3_max.add(port)

    ingress.tbl_compute_distance_cluster1_dst0_min.add_with_compute_distance_cluster1_dst0_min(port, port)
    ingress.tbl_compute_distance_cluster2_dst0_min.add_with_compute_distance_cluster2_dst0_min(port, port)
    ingress.tbl_compute_distance_cluster3_dst0_min.add_with_compute_distance_cluster3_dst0_min(port, port)
    ingress.tbl_compute_distance_cluster4_dst0_min.add_with_compute_distance_cluster4_dst0_min(port, port)

    ingress.tbl_compute_distance_cluster1_dst0_max.add_with_compute_distance_cluster1_dst0_max(port, port)
    ingress.tbl_compute_distance_cluster2_dst0_max.add_with_compute_distance_cluster2_dst0_max(port, port)
    ingress.tbl_compute_distance_cluster3_dst0_max.add_with_compute_distance_cluster3_dst0_max(port, port)
    ingress.tbl_compute_distance_cluster4_dst0_max.add_with_compute_distance_cluster4_dst0_max(port, port)

    ingress.tbl_compute_distance_cluster1_dst1_min.add_with_compute_distance_cluster1_dst1_min(port, port)
    ingress.tbl_compute_distance_cluster2_dst1_min.add_with_compute_distance_cluster2_dst1_min(port, port)
    ingress.tbl_compute_distance_cluster3_dst1_min.add_with_compute_distance_cluster3_dst1_min(port, port)
    ingress.tbl_compute_distance_cluster4_dst1_min.add_with_compute_distance_cluster4_dst1_min(port, port)

    ingress.tbl_compute_distance_cluster1_dst1_max.add_with_compute_distance_cluster1_dst1_max(port, port)
    ingress.tbl_compute_distance_cluster2_dst1_max.add_with_compute_distance_cluster2_dst1_max(port, port)
    ingress.tbl_compute_distance_cluster3_dst1_max.add_with_compute_distance_cluster3_dst1_max(port, port)
    ingress.tbl_compute_distance_cluster4_dst1_max.add_with_compute_distance_cluster4_dst1_max(port, port)

    ingress.tbl_compute_distance_cluster1_dst2_min.add_with_compute_distance_cluster1_dst2_min(port, port)
    ingress.tbl_compute_distance_cluster2_dst2_min.add_with_compute_distance_cluster2_dst2_min(port, port)
    ingress.tbl_compute_distance_cluster3_dst2_min.add_with_compute_distance_cluster3_dst2_min(port, port)
    ingress.tbl_compute_distance_cluster4_dst2_min.add_with_compute_distance_cluster4_dst2_min(port, port)

    ingress.tbl_compute_distance_cluster1_dst2_max.add_with_compute_distance_cluster1_dst2_max(port, port)
    ingress.tbl_compute_distance_cluster2_dst2_max.add_with_compute_distance_cluster2_dst2_max(port, port)
    ingress.tbl_compute_distance_cluster3_dst2_max.add_with_compute_distance_cluster3_dst2_max(port, port)
    ingress.tbl_compute_distance_cluster4_dst2_max.add_with_compute_distance_cluster4_dst2_max(port, port)

    ingress.tbl_compute_distance_cluster1_dst3_min.add_with_compute_distance_cluster1_dst3_min(port, port)
    ingress.tbl_compute_distance_cluster2_dst3_min.add_with_compute_distance_cluster2_dst3_min(port, port)
    ingress.tbl_compute_distance_cluster3_dst3_min.add_with_compute_distance_cluster3_dst3_min(port, port)
    ingress.tbl_compute_distance_cluster4_dst3_min.add_with_compute_distance_cluster4_dst3_min(port, port)

    ingress.tbl_compute_distance_cluster1_dst3_max.add_with_compute_distance_cluster1_dst3_max(port, port)
    ingress.tbl_compute_distance_cluster2_dst3_max.add_with_compute_distance_cluster2_dst3_max(port, port)
    ingress.tbl_compute_distance_cluster3_dst3_max.add_with_compute_distance_cluster3_dst3_max(port, port)
    ingress.tbl_compute_distance_cluster4_dst3_max.add_with_compute_distance_cluster4_dst3_max(port, port)

    ingress.tbl_do_update_cluster1_dst0_min.add_with_do_update_cluster1_dst0_min(port, port)
    ingress.tbl_do_update_cluster2_dst0_min.add_with_do_update_cluster2_dst0_min(port, port)
    ingress.tbl_do_update_cluster3_dst0_min.add_with_do_update_cluster3_dst0_min(port, port)
    ingress.tbl_do_update_cluster4_dst0_min.add_with_do_update_cluster4_dst0_min(port, port)

    ingress.tbl_do_update_cluster1_dst0_max.add_with_do_update_cluster1_dst0_max(port, port)
    ingress.tbl_do_update_cluster2_dst0_max.add_with_do_update_cluster2_dst0_max(port, port)
    ingress.tbl_do_update_cluster3_dst0_max.add_with_do_update_cluster3_dst0_max(port, port)
    ingress.tbl_do_update_cluster4_dst0_max.add_with_do_update_cluster4_dst0_max(port, port)

    ingress.tbl_do_update_cluster1_dst1_min.add_with_do_update_cluster1_dst1_min(port, port)
    ingress.tbl_do_update_cluster2_dst1_min.add_with_do_update_cluster2_dst1_min(port, port)
    ingress.tbl_do_update_cluster3_dst1_min.add_with_do_update_cluster3_dst1_min(port, port)
    ingress.tbl_do_update_cluster4_dst1_min.add_with_do_update_cluster4_dst1_min(port, port)

    ingress.tbl_do_update_cluster1_dst1_max.add_with_do_update_cluster1_dst1_max(port, port)
    ingress.tbl_do_update_cluster2_dst1_max.add_with_do_update_cluster2_dst1_max(port, port)
    ingress.tbl_do_update_cluster3_dst1_max.add_with_do_update_cluster3_dst1_max(port, port)
    ingress.tbl_do_update_cluster4_dst1_max.add_with_do_update_cluster4_dst1_max(port, port)

    ingress.tbl_do_update_cluster1_dst2_min.add_with_do_update_cluster1_dst2_min(port, port)
    ingress.tbl_do_update_cluster2_dst2_min.add_with_do_update_cluster2_dst2_min(port, port)
    ingress.tbl_do_update_cluster3_dst2_min.add_with_do_update_cluster3_dst2_min(port, port)
    ingress.tbl_do_update_cluster4_dst2_min.add_with_do_update_cluster4_dst2_min(port, port)

    ingress.tbl_do_update_cluster1_dst2_max.add_with_do_update_cluster1_dst2_max(port, port)
    ingress.tbl_do_update_cluster2_dst2_max.add_with_do_update_cluster2_dst2_max(port, port)
    ingress.tbl_do_update_cluster3_dst2_max.add_with_do_update_cluster3_dst2_max(port, port)
    ingress.tbl_do_update_cluster4_dst2_max.add_with_do_update_cluster4_dst2_max(port, port)

    ingress.tbl_do_update_cluster1_dst3_min.add_with_do_update_cluster1_dst3_min(port, port)
    ingress.tbl_do_update_cluster2_dst3_min.add_with_do_update_cluster2_dst3_min(port, port)
    ingress.tbl_do_update_cluster3_dst3_min.add_with_do_update_cluster3_dst3_min(port, port)
    ingress.tbl_do_update_cluster4_dst3_min.add_with_do_update_cluster4_dst3_min(port, port)

    ingress.tbl_do_update_cluster1_dst3_max.add_with_do_update_cluster1_dst3_max(port, port)
    ingress.tbl_do_update_cluster2_dst3_max.add_with_do_update_cluster2_dst3_max(port, port)
    ingress.tbl_do_update_cluster3_dst3_max.add_with_do_update_cluster3_dst3_max(port, port)
    ingress.tbl_do_update_cluster4_dst3_max.add_with_do_update_cluster4_dst3_max(port, port)

# Cluster to prio table (higher qid has higher priority)
for cluster_id in [4,3,2,1]:
    ingress.cluster_to_prio.add_with_set_qid(cluster_id, cluster_id-1) #qids = [0,1,2,3]

# Counters
for queue_id in range(4):
    ingress.do_bytes_count.add_with_bytes_count(queue_id)

# -----------------
# Egress setup
# -----------------
egress = bfrt.accturbo.pipe.MyEgress

# We initialize the timer
egress.timestamp.add(0)
egress.timestamp.mod(0, 0)

# We initialize the counters
if len(sys.argv) > 1 and "carpetbombing" in sys.argv:
    egress.do_bytes_count_malicious_egress.add_with_bytes_count_malicious_egress("10.0.0.50")   
else:
    egress.do_bytes_count_malicious_egress.add_with_bytes_count_malicious_egress("5.5.5.5")

egress.do_bytes_count_benign_egress.add_with_bytes_count_benign_egress(140)    


bfrt.complete_operations()
print("Finished setting up the control plane interfaces")


# -----------------
# Verify the initialization
# -----------------
#ingress.do_bytes_count.dump(from_hw=True, table=True)
#ingress.cluster_to_prio.dump(from_hw=True, table=True)

#ingress.cluster1_dst0_min.get(140, from_hw=True)
#ingress.cluster2_dst0_min.get(140, from_hw=True)
#ingress.cluster3_dst0_min.get(140, from_hw=True)
#ingress.cluster4_dst0_min.get(140, from_hw=True)

#ingress.cluster1_dst0_max.get(140, from_hw=True)
#ingress.cluster2_dst0_max.get(140, from_hw=True)
#ingress.cluster3_dst0_max.get(140, from_hw=True)
#ingress.cluster4_dst0_max.get(140, from_hw=True)

#ingress.cluster1_dst1_min.get(140, from_hw=True)
#ingress.cluster2_dst1_min.get(140, from_hw=True)
#ingress.cluster3_dst1_min.get(140, from_hw=True)
#ingress.cluster4_dst1_min.get(140, from_hw=True)

#ingress.cluster1_dst1_max.get(140, from_hw=True)
#ingress.cluster2_dst1_max.get(140, from_hw=True)
#ingress.cluster3_dst1_max.get(140, from_hw=True)
#ingress.cluster4_dst1_max.get(140, from_hw=True)

#ingress.cluster1_dst2_min.get(140, from_hw=True)
#ingress.cluster2_dst2_min.get(140, from_hw=True)
#ingress.cluster3_dst2_min.get(140, from_hw=True)
#ingress.cluster4_dst2_min.get(140, from_hw=True)

#ingress.cluster1_dst2_max.get(140, from_hw=True)
#ingress.cluster2_dst2_max.get(140, from_hw=True)
#ingress.cluster3_dst2_max.get(140, from_hw=True)
#ingress.cluster4_dst2_max.get(140, from_hw=True)

#ingress.cluster1_dst3_min.get(140, from_hw=True)
#ingress.cluster2_dst3_min.get(140, from_hw=True)
#ingress.cluster3_dst3_min.get(140, from_hw=True)
#ingress.cluster4_dst3_min.get(140, from_hw=True)

#ingress.cluster1_dst3_max.get(140, from_hw=True)
#ingress.cluster2_dst3_max.get(140, from_hw=True)
#ingress.cluster3_dst3_max.get(140, from_hw=True)
#ingress.cluster4_dst3_max.get(140, from_hw=True)

# Important: dump(from_hw=True) to read the value from the switch, otherwise it would show the latest one cached