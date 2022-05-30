
# Tofino Model Configuration
ingress = bfrt.ddos_aid_4x4_singlepipe_p4_16.pipe.MyIngress

# Table: tbl_compute_distance_cluster{1,2,3,4}_{len,proto,id,ttl}_{min,max}
# Action: compute_distance_cluster{1,2,3,4}_{len,proto,id,ttl}_{min,max}
# Key: ig_tm_md.ucast_egress_port (exact);
# Parameter: PortId_t, port

for port in range(512):

    ingress.cluster1_len_min.add(port)
    ingress.cluster2_len_min.add(port)
    ingress.cluster3_len_min.add(port)
    ingress.cluster4_len_min.add(port)

    ingress.cluster1_len_max.add(port)
    ingress.cluster2_len_max.add(port)
    ingress.cluster3_len_max.add(port)
    ingress.cluster4_len_max.add(port)

    ingress.cluster1_ttl_min.add(port)
    ingress.cluster2_ttl_min.add(port)
    ingress.cluster3_ttl_min.add(port)
    ingress.cluster4_ttl_min.add(port)

    ingress.cluster1_ttl_max.add(port)
    ingress.cluster2_ttl_max.add(port)
    ingress.cluster3_ttl_max.add(port)
    ingress.cluster4_ttl_max.add(port)

    ingress.cluster1_proto_min.add(port)
    ingress.cluster2_proto_min.add(port)
    ingress.cluster3_proto_min.add(port)
    ingress.cluster4_proto_min.add(port)

    ingress.cluster1_proto_max.add(port)
    ingress.cluster2_proto_max.add(port)
    ingress.cluster3_proto_max.add(port)
    ingress.cluster4_proto_max.add(port)

    ingress.cluster1_id_min.add(port)
    ingress.cluster2_id_min.add(port)
    ingress.cluster3_id_min.add(port)
    ingress.cluster4_id_min.add(port)

    ingress.cluster1_id_max.add(port)
    ingress.cluster2_id_max.add(port)
    ingress.cluster3_id_max.add(port)
    ingress.cluster4_id_max.add(port)
    
    ingress.tbl_compute_distance_cluster1_len_min.add_with_compute_distance_cluster1_len_min(port, port)
    ingress.tbl_compute_distance_cluster2_len_min.add_with_compute_distance_cluster2_len_min(port, port)
    ingress.tbl_compute_distance_cluster3_len_min.add_with_compute_distance_cluster3_len_min(port, port)
    ingress.tbl_compute_distance_cluster4_len_min.add_with_compute_distance_cluster4_len_min(port, port)

    ingress.tbl_compute_distance_cluster1_len_max.add_with_compute_distance_cluster1_len_max(port, port)
    ingress.tbl_compute_distance_cluster2_len_max.add_with_compute_distance_cluster2_len_max(port, port)
    ingress.tbl_compute_distance_cluster3_len_max.add_with_compute_distance_cluster3_len_max(port, port)
    ingress.tbl_compute_distance_cluster4_len_max.add_with_compute_distance_cluster4_len_max(port, port)

    ingress.tbl_compute_distance_cluster1_ttl_min.add_with_compute_distance_cluster1_ttl_min(port, port)
    ingress.tbl_compute_distance_cluster2_ttl_min.add_with_compute_distance_cluster2_ttl_min(port, port)
    ingress.tbl_compute_distance_cluster3_ttl_min.add_with_compute_distance_cluster3_ttl_min(port, port)
    ingress.tbl_compute_distance_cluster4_ttl_min.add_with_compute_distance_cluster4_ttl_min(port, port)

    ingress.tbl_compute_distance_cluster1_ttl_max.add_with_compute_distance_cluster1_ttl_max(port, port)
    ingress.tbl_compute_distance_cluster2_ttl_max.add_with_compute_distance_cluster2_ttl_max(port, port)
    ingress.tbl_compute_distance_cluster3_ttl_max.add_with_compute_distance_cluster3_ttl_max(port, port)
    ingress.tbl_compute_distance_cluster4_ttl_max.add_with_compute_distance_cluster4_ttl_max(port, port)

    ingress.tbl_compute_distance_cluster1_proto_min.add_with_compute_distance_cluster1_proto_min(port, port)
    ingress.tbl_compute_distance_cluster2_proto_min.add_with_compute_distance_cluster2_proto_min(port, port)
    ingress.tbl_compute_distance_cluster3_proto_min.add_with_compute_distance_cluster3_proto_min(port, port)
    ingress.tbl_compute_distance_cluster4_proto_min.add_with_compute_distance_cluster4_proto_min(port, port)

    ingress.tbl_compute_distance_cluster1_proto_max.add_with_compute_distance_cluster1_proto_max(port, port)
    ingress.tbl_compute_distance_cluster2_proto_max.add_with_compute_distance_cluster2_proto_max(port, port)
    ingress.tbl_compute_distance_cluster3_proto_max.add_with_compute_distance_cluster3_proto_max(port, port)
    ingress.tbl_compute_distance_cluster4_proto_max.add_with_compute_distance_cluster4_proto_max(port, port)

    ingress.tbl_compute_distance_cluster1_id_min.add_with_compute_distance_cluster1_id_min(port, port)
    ingress.tbl_compute_distance_cluster2_id_min.add_with_compute_distance_cluster2_id_min(port, port)
    ingress.tbl_compute_distance_cluster3_id_min.add_with_compute_distance_cluster3_id_min(port, port)
    ingress.tbl_compute_distance_cluster4_id_min.add_with_compute_distance_cluster4_id_min(port, port)

    ingress.tbl_compute_distance_cluster1_id_max.add_with_compute_distance_cluster1_id_max(port, port)
    ingress.tbl_compute_distance_cluster2_id_max.add_with_compute_distance_cluster2_id_max(port, port)
    ingress.tbl_compute_distance_cluster3_id_max.add_with_compute_distance_cluster3_id_max(port, port)
    ingress.tbl_compute_distance_cluster4_id_max.add_with_compute_distance_cluster4_id_max(port, port)

    ingress.tbl_do_update_cluster1_len_min.add_with_do_update_cluster1_len_min(port, port)
    ingress.tbl_do_update_cluster2_len_min.add_with_do_update_cluster2_len_min(port, port)
    ingress.tbl_do_update_cluster3_len_min.add_with_do_update_cluster3_len_min(port, port)
    ingress.tbl_do_update_cluster4_len_min.add_with_do_update_cluster4_len_min(port, port)

    ingress.tbl_do_update_cluster1_len_max.add_with_do_update_cluster1_len_max(port, port)
    ingress.tbl_do_update_cluster2_len_max.add_with_do_update_cluster2_len_max(port, port)
    ingress.tbl_do_update_cluster3_len_max.add_with_do_update_cluster3_len_max(port, port)
    ingress.tbl_do_update_cluster4_len_max.add_with_do_update_cluster4_len_max(port, port)

    ingress.tbl_do_update_cluster1_ttl_min.add_with_do_update_cluster1_ttl_min(port, port)
    ingress.tbl_do_update_cluster2_ttl_min.add_with_do_update_cluster2_ttl_min(port, port)
    ingress.tbl_do_update_cluster3_ttl_min.add_with_do_update_cluster3_ttl_min(port, port)
    ingress.tbl_do_update_cluster4_ttl_min.add_with_do_update_cluster4_ttl_min(port, port)

    ingress.tbl_do_update_cluster1_ttl_max.add_with_do_update_cluster1_ttl_max(port, port)
    ingress.tbl_do_update_cluster2_ttl_max.add_with_do_update_cluster2_ttl_max(port, port)
    ingress.tbl_do_update_cluster3_ttl_max.add_with_do_update_cluster3_ttl_max(port, port)
    ingress.tbl_do_update_cluster4_ttl_max.add_with_do_update_cluster4_ttl_max(port, port)

    ingress.tbl_do_update_cluster1_proto_min.add_with_do_update_cluster1_proto_min(port, port)
    ingress.tbl_do_update_cluster2_proto_min.add_with_do_update_cluster2_proto_min(port, port)
    ingress.tbl_do_update_cluster3_proto_min.add_with_do_update_cluster3_proto_min(port, port)
    ingress.tbl_do_update_cluster4_proto_min.add_with_do_update_cluster4_proto_min(port, port)

    ingress.tbl_do_update_cluster1_proto_max.add_with_do_update_cluster1_proto_max(port, port)
    ingress.tbl_do_update_cluster2_proto_max.add_with_do_update_cluster2_proto_max(port, port)
    ingress.tbl_do_update_cluster3_proto_max.add_with_do_update_cluster3_proto_max(port, port)
    ingress.tbl_do_update_cluster4_proto_max.add_with_do_update_cluster4_proto_max(port, port)

    ingress.tbl_do_update_cluster1_id_min.add_with_do_update_cluster1_id_min(port, port)
    ingress.tbl_do_update_cluster2_id_min.add_with_do_update_cluster2_id_min(port, port)
    ingress.tbl_do_update_cluster3_id_min.add_with_do_update_cluster3_id_min(port, port)
    ingress.tbl_do_update_cluster4_id_min.add_with_do_update_cluster4_id_min(port, port)

    ingress.tbl_do_update_cluster1_id_max.add_with_do_update_cluster1_id_max(port, port)
    ingress.tbl_do_update_cluster2_id_max.add_with_do_update_cluster2_id_max(port, port)
    ingress.tbl_do_update_cluster3_id_max.add_with_do_update_cluster3_id_max(port, port)
    ingress.tbl_do_update_cluster4_id_max.add_with_do_update_cluster4_id_max(port, port)

# Cluster to prio table (higher qid has higher priority)
for cluster_id in [4,3,2,1]:
    ingress.cluster_to_prio.add_with_set_qid(cluster_id, cluster_id-1) #qids = [0,1,2,3]

# Egress tables
egress = bfrt.ddos_aid_4x4_singlepipe_p4_16.pipe.MyEgress

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