
# Tofino Model Configuration
ingress = bfrt.ddos_aid_4x4_singlepipe_p4_16_modified.pipe.MyIngress

# Table: tbl_compute_distance_cluster{1,2,3,4}_{sport,dst3,dport,dst2}_{min,max}
# Action: compute_distance_cluster{1,2,3,4}_{sport,dst3,dport,dst2}_{min,max}
# Key: ig_tm_md.ucast_egress_port (exact);
# Parameter: PortId_t, port

for port in range(512):

    ingress.cluster1_sport_min.add(port)
    ingress.cluster2_sport_min.add(port)
    ingress.cluster3_sport_min.add(port)
    ingress.cluster4_sport_min.add(port)

    ingress.cluster1_sport_max.add(port)
    ingress.cluster2_sport_max.add(port)
    ingress.cluster3_sport_max.add(port)
    ingress.cluster4_sport_max.add(port)

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

    ingress.cluster1_dport_min.add(port)
    ingress.cluster2_dport_min.add(port)
    ingress.cluster3_dport_min.add(port)
    ingress.cluster4_dport_min.add(port)

    ingress.cluster1_dport_max.add(port)
    ingress.cluster2_dport_max.add(port)
    ingress.cluster3_dport_max.add(port)
    ingress.cluster4_dport_max.add(port)
    
    ingress.tbl_compute_distance_cluster1_sport_min.add_with_compute_distance_cluster1_sport_min(port, port)
    ingress.tbl_compute_distance_cluster2_sport_min.add_with_compute_distance_cluster2_sport_min(port, port)
    ingress.tbl_compute_distance_cluster3_sport_min.add_with_compute_distance_cluster3_sport_min(port, port)
    ingress.tbl_compute_distance_cluster4_sport_min.add_with_compute_distance_cluster4_sport_min(port, port)

    ingress.tbl_compute_distance_cluster1_sport_max.add_with_compute_distance_cluster1_sport_max(port, port)
    ingress.tbl_compute_distance_cluster2_sport_max.add_with_compute_distance_cluster2_sport_max(port, port)
    ingress.tbl_compute_distance_cluster3_sport_max.add_with_compute_distance_cluster3_sport_max(port, port)
    ingress.tbl_compute_distance_cluster4_sport_max.add_with_compute_distance_cluster4_sport_max(port, port)

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

    ingress.tbl_compute_distance_cluster1_dport_min.add_with_compute_distance_cluster1_dport_min(port, port)
    ingress.tbl_compute_distance_cluster2_dport_min.add_with_compute_distance_cluster2_dport_min(port, port)
    ingress.tbl_compute_distance_cluster3_dport_min.add_with_compute_distance_cluster3_dport_min(port, port)
    ingress.tbl_compute_distance_cluster4_dport_min.add_with_compute_distance_cluster4_dport_min(port, port)

    ingress.tbl_compute_distance_cluster1_dport_max.add_with_compute_distance_cluster1_dport_max(port, port)
    ingress.tbl_compute_distance_cluster2_dport_max.add_with_compute_distance_cluster2_dport_max(port, port)
    ingress.tbl_compute_distance_cluster3_dport_max.add_with_compute_distance_cluster3_dport_max(port, port)
    ingress.tbl_compute_distance_cluster4_dport_max.add_with_compute_distance_cluster4_dport_max(port, port)

    ingress.tbl_do_update_cluster1_sport_min.add_with_do_update_cluster1_sport_min(port, port)
    ingress.tbl_do_update_cluster2_sport_min.add_with_do_update_cluster2_sport_min(port, port)
    ingress.tbl_do_update_cluster3_sport_min.add_with_do_update_cluster3_sport_min(port, port)
    ingress.tbl_do_update_cluster4_sport_min.add_with_do_update_cluster4_sport_min(port, port)

    ingress.tbl_do_update_cluster1_sport_max.add_with_do_update_cluster1_sport_max(port, port)
    ingress.tbl_do_update_cluster2_sport_max.add_with_do_update_cluster2_sport_max(port, port)
    ingress.tbl_do_update_cluster3_sport_max.add_with_do_update_cluster3_sport_max(port, port)
    ingress.tbl_do_update_cluster4_sport_max.add_with_do_update_cluster4_sport_max(port, port)

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

    ingress.tbl_do_update_cluster1_dport_min.add_with_do_update_cluster1_dport_min(port, port)
    ingress.tbl_do_update_cluster2_dport_min.add_with_do_update_cluster2_dport_min(port, port)
    ingress.tbl_do_update_cluster3_dport_min.add_with_do_update_cluster3_dport_min(port, port)
    ingress.tbl_do_update_cluster4_dport_min.add_with_do_update_cluster4_dport_min(port, port)

    ingress.tbl_do_update_cluster1_dport_max.add_with_do_update_cluster1_dport_max(port, port)
    ingress.tbl_do_update_cluster2_dport_max.add_with_do_update_cluster2_dport_max(port, port)
    ingress.tbl_do_update_cluster3_dport_max.add_with_do_update_cluster3_dport_max(port, port)
    ingress.tbl_do_update_cluster4_dport_max.add_with_do_update_cluster4_dport_max(port, port)

# We initialize the cluster ranges
ingress.cluster1_sport_min.mod(140, 13107)
ingress.cluster2_sport_min.mod(140, 26214)
ingress.cluster3_sport_min.mod(140, 39321)
ingress.cluster4_sport_min.mod(140, 52428)

ingress.cluster1_sport_max.mod(140, 13107)
ingress.cluster2_sport_max.mod(140, 26214)
ingress.cluster3_sport_max.mod(140, 39321)
ingress.cluster4_sport_max.mod(140, 52428)

ingress.cluster1_dst2_min.mod(140, 51)
ingress.cluster2_dst2_min.mod(140, 102)
ingress.cluster3_dst2_min.mod(140, 153)
ingress.cluster4_dst2_min.mod(140, 204)

ingress.cluster1_dst2_max.mod(140, 51)
ingress.cluster2_dst2_max.mod(140, 102)
ingress.cluster3_dst2_max.mod(140, 153)
ingress.cluster4_dst2_max.mod(140, 204)

ingress.cluster1_dst3_min.mod(140, 51)
ingress.cluster2_dst3_min.mod(140, 102)
ingress.cluster3_dst3_min.mod(140, 153)
ingress.cluster4_dst3_min.mod(140, 204)

ingress.cluster1_dst3_max.mod(140, 51)
ingress.cluster2_dst3_max.mod(140, 102)
ingress.cluster3_dst3_max.mod(140, 153)
ingress.cluster4_dst3_max.mod(140, 204)

ingress.cluster1_dport_min.mod(140, 13107)
ingress.cluster2_dport_min.mod(140, 26214)
ingress.cluster3_dport_min.mod(140, 39321)
ingress.cluster4_dport_min.mod(140, 52428)

ingress.cluster1_dport_max.mod(140, 13107)
ingress.cluster2_dport_max.mod(140, 26214)
ingress.cluster3_dport_max.mod(140, 39321)
ingress.cluster4_dport_max.mod(140, 52428)

# Cluster to prio table (higher qdport has higher priority)
for cluster_id in [4,3,2,1]:
    ingress.cluster_to_prio.add_with_set_qid(cluster_id, cluster_id-1) #qids = [0,1,2,3]

# Egress tables
egress = bfrt.ddos_aid_4x4_singlepipe_p4_16_modified.pipe.MyEgress

# Counters
for queue_id in range(4):
    egress.do_packet_count.add_with_packet_count(queue_id)
    egress.do_bytes_count.add_with_bytes_count(queue_id)

bfrt.complete_operations()

# Verify the initialization
#egress.do_packet_count.dump(from_hw=True, table=True)
#egress.do_bytes_count.dump(from_hw=True, table=True)
#ingress.cluster_to_prio.dump(from_hw=True, table=True)

# Important: dump(from_hw=True) to read the value from the switch, otherwise it would show the latest one cached