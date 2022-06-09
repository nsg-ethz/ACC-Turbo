/* -*- P4_16 -*- */
#include <core.p4>
#include <tna.p4>

/*************************************************************************
 ************* C O N S T A N T S    A N D   T Y P E S  *******************
*************************************************************************/

#define NUM_EGRESS_PORTS    512
#define NUM_CLUSTERS        4

/*************************************************************************
 ***********************  H E A D E R S  *********************************
 *************************************************************************/

header ethernet_h {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> ether_type;
}

header ipv4_h {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> len;
    bit<16> id;
    bit<3>  flags;
    bit<13> frag_offset;
    bit<8>  ttl;
    bit<8>  proto;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<8> dst0;
    bit<8> dst1;
    bit<8> dst2;
    bit<8> dst3;
}

header transport_h {
    bit<16> sport;
    bit<16> dport;
}

header resubmit_h {
    bit<8> cluster_id;
    bit<8> update_activated;
}

@pa_container_size("ingress", "meta.rs.cluster_id", 8)
@pa_container_size("ingress", "meta.rs.update_activated", 8)

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

/* All the headers we plan to process in the ingress */
struct my_ingress_headers_t {
    ethernet_h ethernet;
    ipv4_h ipv4;
    transport_h  transport;
}

/* All intermediate results that need to be available 
 * to all P4-programmable components in ingress
 */
struct my_ingress_metadata_t { // We will have to initialize them
    resubmit_h rs;

    /* Cluster 1 */
    bit<32> cluster1_dst0_distance;  
    bit<32> cluster1_dst1_distance;
    bit<32> cluster1_dst2_distance;
    bit<32> cluster1_dst3_distance;

    /* Cluster 2 */
    bit<32> cluster2_dst0_distance;  
    bit<32> cluster2_dst1_distance;
    bit<32> cluster2_dst2_distance;
    bit<32> cluster2_dst3_distance;

    /* Cluster 3 */
    bit<32> cluster3_dst0_distance;  
    bit<32> cluster3_dst1_distance;
    bit<32> cluster3_dst2_distance;
    bit<32> cluster3_dst3_distance;

    /* Cluster 4 */
    bit<32> cluster4_dst0_distance;  
    bit<32> cluster4_dst1_distance;
    bit<32> cluster4_dst2_distance;
    bit<32> cluster4_dst3_distance;

    // Distance helpers
    bit<32> min_d1_d2;
    bit<32> min_d3_d4;
    bit<32> min_d1_d2_d3_d4;
    
    // Initialization
    bit<8> init_counter_value;
}

parser MyIngressParser(packet_in                pkt,
    out my_ingress_headers_t                    hdr, 
    out my_ingress_metadata_t                   meta, 
    out ingress_intrinsic_metadata_t            ig_intr_md,
    out ingress_intrinsic_metadata_for_tm_t     ig_tm_md) {

    state start {
        
        /* Mandatory code required by Tofino Architecture */
        pkt.extract(ig_intr_md);

        /* We hardcode the egress port (all packets towards port 140) */
        ig_tm_md.ucast_egress_port = 140;

        /* Cluster 1 */
        meta.cluster1_dst0_distance = 0;
        meta.cluster1_dst1_distance = 0;
        meta.cluster1_dst2_distance = 0;
        meta.cluster1_dst3_distance = 0;

        /* Cluster 2 */
        meta.cluster2_dst0_distance = 0;
        meta.cluster2_dst1_distance = 0;
        meta.cluster2_dst2_distance = 0;
        meta.cluster2_dst3_distance = 0;

        /* Cluster 3 */
        meta.cluster3_dst0_distance = 0;
        meta.cluster3_dst1_distance = 0;
        meta.cluster3_dst2_distance = 0;
        meta.cluster3_dst3_distance = 0;

        /* Cluster 4 */
        meta.cluster4_dst0_distance = 0;
        meta.cluster4_dst1_distance = 0;
        meta.cluster4_dst2_distance = 0;
        meta.cluster4_dst3_distance = 0;

        // Distance helpers
        meta.min_d1_d2 = 0;
        meta.min_d3_d4 = 0;
        meta.min_d1_d2_d3_d4 = 0;

        /* Parser start point */
        transition select(ig_intr_md.resubmit_flag) {
            0: parse_port_metadata;
            1: parse_resubmit;
        }
    }

    state parse_port_metadata {
        pkt.advance(PORT_METADATA_SIZE);
        transition parse_ethernet;
    }

    state parse_resubmit {
        pkt.extract(meta.rs);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            0x0800:  parse_ipv4;
            default: accept;
        }
    }

    /* We only parse layer 4 if the packet is a first fragment (frag_offset == 0) and if ipv4 header contains no options (ihl == 5) */
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.frag_offset, hdr.ipv4.proto, hdr.ipv4.ihl) {
            (0, 6, 5)  : parse_transport;
            (0, 17, 5) : parse_transport;
            default : accept;
        }
    }

    state parse_transport {
        pkt.extract(hdr.transport);
        transition accept;
    }
}

control MyIngress(
    inout my_ingress_headers_t                       hdr,
    inout my_ingress_metadata_t                      meta,
    in    ingress_intrinsic_metadata_t               ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t   ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md) {   

    /* Define variables, actions and tables here */
    action set_qid(QueueId_t qid) {
        ig_tm_md.qid = qid;
    }

    table cluster_to_prio {
        key = {
            meta.rs.cluster_id : exact;
        }
        actions = {
            set_qid;
        }
        default_action = set_qid(0); // Lowest-priority queue.
        size = NUM_CLUSTERS;
    }

    /****/
    /**** Clustering control registers */
    /****/

    /* Cluster 1 */
    /* IP dst0 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dst0_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst0_min) 
    distance_cluster1_dst0_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst0 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst0;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<16>>(cluster1_dst0_min) 
    update_cluster1_dst0_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst0 < data) {
                    data = (bit<32>)hdr.ipv4.dst0;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dst0_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst0_max) 
    distance_cluster1_dst0_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst0 > data) {
                distance = (bit<32>)hdr.ipv4.dst0 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst0_max) 
    update_cluster1_dst0_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst0 > data) {
                    data = (bit<32>)hdr.ipv4.dst0;
                }
            }
        }
    };

    /* IP dst1 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dst1_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst1_min) 
    distance_cluster1_dst1_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst1 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst1;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst1_min) 
    update_cluster1_dst1_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst1 < data) {
                    data = (bit<32>)hdr.ipv4.dst1;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dst1_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst1_max) 
    distance_cluster1_dst1_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst1 > data) {
                distance = (bit<32>)hdr.ipv4.dst1 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst1_max) 
    update_cluster1_dst1_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst1 > data) {
                    data = (bit<32>)hdr.ipv4.dst1;
                }
            }
        }
    };

    /* IP dst2 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dst2_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst2_min) 
    distance_cluster1_dst2_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst2 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst2;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst2_min) 
    update_cluster1_dst2_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst2 < data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dst2_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst2_max) 
    distance_cluster1_dst2_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst2 > data) {
                distance = (bit<32>)hdr.ipv4.dst2 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst2_max) 
    update_cluster1_dst2_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst2 > data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    /* IP dst3 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dst3_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst3_min) 
    distance_cluster1_dst3_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst3 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst3;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst3_min) 
    update_cluster1_dst3_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst3 < data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dst3_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst3_max) 
    distance_cluster1_dst3_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst3 > data) {
                distance = (bit<32>)hdr.ipv4.dst3 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dst3_max) 
    update_cluster1_dst3_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst3 > data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    /* Cluster 2 */
    /* IP dst0 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dst0_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst0_min) 
    distance_cluster2_dst0_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst0 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst0;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst0_min) 
    update_cluster2_dst0_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst0 < data) {
                    data = (bit<32>)hdr.ipv4.dst0;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dst0_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst0_max) 
    distance_cluster2_dst0_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst0 > data) {
                distance = (bit<32>)hdr.ipv4.dst0 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst0_max) 
    update_cluster2_dst0_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst0 > data) {
                    data = (bit<32>)hdr.ipv4.dst0;
                }
            }
        }
    };

    /* IP dst1 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dst1_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst1_min) 
    distance_cluster2_dst1_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst1 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst1;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst1_min) 
    update_cluster2_dst1_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst1 < data) {
                    data = (bit<32>)hdr.ipv4.dst1;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dst1_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst1_max) 
    distance_cluster2_dst1_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst1 > data) {
                distance = (bit<32>)hdr.ipv4.dst1 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst1_max) 
    update_cluster2_dst1_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst1 > data) {
                    data = (bit<32>)hdr.ipv4.dst1;
                }
            }
        }
    };

    /* IP dst2 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dst2_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst2_min) 
    distance_cluster2_dst2_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst2 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst2;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst2_min) 
    update_cluster2_dst2_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst2 < data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dst2_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst2_max) 
    distance_cluster2_dst2_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst2 > data) {
                distance = (bit<32>)hdr.ipv4.dst2 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst2_max) 
    update_cluster2_dst2_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst2 > data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    /* IP dst3 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dst3_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst3_min) 
    distance_cluster2_dst3_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst3 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst3;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst3_min) 
    update_cluster2_dst3_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst3 < data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dst3_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst3_max) 
    distance_cluster2_dst3_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst3 > data) {
                distance = (bit<32>)hdr.ipv4.dst3 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dst3_max) 
    update_cluster2_dst3_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst3 > data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    /* Cluster 3 */
    /* IP dst0 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dst0_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst0_min) 
    distance_cluster3_dst0_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst0 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst0;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst0_min) 
    update_cluster3_dst0_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst0 < data) {
                    data = (bit<32>)hdr.ipv4.dst0;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dst0_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst0_max) 
    distance_cluster3_dst0_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst0 > data) {
                distance = (bit<32>)hdr.ipv4.dst0 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst0_max) 
    update_cluster3_dst0_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst0 > data) {
                    data = (bit<32>)hdr.ipv4.dst0;
                }
            }
        }
    };

    /* IP dst1 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dst1_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst1_min) 
    distance_cluster3_dst1_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst1 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst1;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst1_min) 
    update_cluster3_dst1_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst1 < data) {
                    data = (bit<32>)hdr.ipv4.dst1;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dst1_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst1_max) 
    distance_cluster3_dst1_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst1 > data) {
                distance = (bit<32>)hdr.ipv4.dst1 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst1_max) 
    update_cluster3_dst1_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst1 > data) {
                    data = (bit<32>)hdr.ipv4.dst1;
                }
            }
        }
    };

    /* IP dst2 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dst2_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst2_min) 
    distance_cluster3_dst2_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst2 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst2;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst2_min) 
    update_cluster3_dst2_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst2 < data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dst2_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst2_max) 
    distance_cluster3_dst2_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst2 > data) {
                distance = (bit<32>)hdr.ipv4.dst2 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst2_max) 
    update_cluster3_dst2_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst2 > data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    /* IP dst3 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dst3_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst3_min) 
    distance_cluster3_dst3_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst3 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst3;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst3_min) 
    update_cluster3_dst3_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst3 < data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dst3_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst3_max) 
    distance_cluster3_dst3_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst3 > data) {
                distance = (bit<32>)hdr.ipv4.dst3 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dst3_max) 
    update_cluster3_dst3_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst3 > data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    /* Cluster 4 */
    /* IP dst0  */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dst0_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst0_min) 
    distance_cluster4_dst0_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst0 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst0;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst0_min) 
    update_cluster4_dst0_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst0 < data) {
                    data = (bit<32>)hdr.ipv4.dst0;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dst0_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst0_max) 
    distance_cluster4_dst0_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst0 > data) {
                distance = (bit<32>)hdr.ipv4.dst0 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst0_max) 
    update_cluster4_dst0_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst0 > data) {
                    data = (bit<32>)hdr.ipv4.dst0;
                }
            }
        }
    };

    /* IP dst1 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dst1_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst1_min) 
    distance_cluster4_dst1_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst1 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst1;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst1_min) 
    update_cluster4_dst1_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst1 < data) {
                    data = (bit<32>)hdr.ipv4.dst1;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dst1_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst1_max) 
    distance_cluster4_dst1_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst1 > data) {
                distance = (bit<32>)hdr.ipv4.dst1 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst1_max) 
    update_cluster4_dst1_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst1 > data) {
                    data = (bit<32>)hdr.ipv4.dst1;
                }
            }
        }
    };

    /* IP dst2 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dst2_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst2_min) 
    distance_cluster4_dst2_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst2 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst2;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst2_min) 
    update_cluster4_dst2_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst2 < data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dst2_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst2_max) 
    distance_cluster4_dst2_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst2 > data) {
                distance = (bit<32>)hdr.ipv4.dst2 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst2_max) 
    update_cluster4_dst2_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst2 > data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    /* IP dst3 */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dst3_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst3_min) 
    distance_cluster4_dst3_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst3 < data) {
                distance = data - (bit<32>)hdr.ipv4.dst3;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst3_min) 
    update_cluster4_dst3_min = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst3 < data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dst3_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst3_max) 
    distance_cluster4_dst3_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.ipv4.dst3 > data) {
                distance = (bit<32>)hdr.ipv4.dst3 - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dst3_max) 
    update_cluster4_dst3_max = {
        void apply(inout bit<32> data) {
            if (meta.rs.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst3 > data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    /****/
    /**** Actions to compute distances */
    /****/

    /* Cluster 1 */
    action compute_distance_cluster1_dst0_min(PortId_t port) {
        meta.cluster1_dst0_distance   = distance_cluster1_dst0_min.execute(port);
    }
    action compute_distance_cluster1_dst0_max(PortId_t port) {
        meta.cluster1_dst0_distance   = distance_cluster1_dst0_max.execute(port);
    }

    action compute_distance_cluster1_dst1_min(PortId_t port) {
        meta.cluster1_dst1_distance   = distance_cluster1_dst1_min.execute(port);
    }
    action compute_distance_cluster1_dst1_max(PortId_t port) {
        meta.cluster1_dst1_distance   = distance_cluster1_dst1_max.execute(port);
    }

    action compute_distance_cluster1_dst2_min(PortId_t port) {
        meta.cluster1_dst2_distance   = distance_cluster1_dst2_min.execute(port);
    }
    action compute_distance_cluster1_dst2_max(PortId_t port) {
        meta.cluster1_dst2_distance   = distance_cluster1_dst2_max.execute(port);
    }

    action compute_distance_cluster1_dst3_min(PortId_t port) {
        meta.cluster1_dst3_distance   = distance_cluster1_dst3_min.execute(port);
    }
    action compute_distance_cluster1_dst3_max(PortId_t port) {
        meta.cluster1_dst3_distance   = distance_cluster1_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_compute_distance_cluster1_dst0_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dst0_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_compute_distance_cluster1_dst0_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dst0_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
    table tbl_compute_distance_cluster1_dst1_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dst1_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    @pragma stage 5
    table tbl_compute_distance_cluster1_dst1_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dst1_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 2
    table tbl_compute_distance_cluster1_dst2_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dst2_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    @pragma stage 6
    table tbl_compute_distance_cluster1_dst2_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dst2_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 3
    table tbl_compute_distance_cluster1_dst3_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dst3_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    @pragma stage 7
    table tbl_compute_distance_cluster1_dst3_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dst3_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    /* Cluster 2 */
    action compute_distance_cluster2_dst0_min(PortId_t port) {
        meta.cluster2_dst0_distance   = distance_cluster2_dst0_min.execute(port);
    }
    action compute_distance_cluster2_dst0_max(PortId_t port) {
        meta.cluster2_dst0_distance   = distance_cluster2_dst0_max.execute(port);
    }

    action compute_distance_cluster2_dst1_min(PortId_t port) {
        meta.cluster2_dst1_distance   = distance_cluster2_dst1_min.execute(port);
    }
    action compute_distance_cluster2_dst1_max(PortId_t port) {
        meta.cluster2_dst1_distance   = distance_cluster2_dst1_max.execute(port);
    }

    action compute_distance_cluster2_dst2_min(PortId_t port) {
        meta.cluster2_dst2_distance   = distance_cluster2_dst2_min.execute(port);
    }
    action compute_distance_cluster2_dst2_max(PortId_t port) {
        meta.cluster2_dst2_distance   = distance_cluster2_dst2_max.execute(port);
    }

    action compute_distance_cluster2_dst3_min(PortId_t port) {
        meta.cluster2_dst3_distance   = distance_cluster2_dst3_min.execute(port);
    }
    action compute_distance_cluster2_dst3_max(PortId_t port) {
        meta.cluster2_dst3_distance   = distance_cluster2_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_compute_distance_cluster2_dst0_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dst0_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    @pragma stage 4
    table tbl_compute_distance_cluster2_dst0_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dst0_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
    table tbl_compute_distance_cluster2_dst1_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dst1_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 5
    table tbl_compute_distance_cluster2_dst1_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dst1_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 2
    table tbl_compute_distance_cluster2_dst2_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dst2_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_compute_distance_cluster2_dst2_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dst2_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 3
    table tbl_compute_distance_cluster2_dst3_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dst3_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    @pragma stage 7
    table tbl_compute_distance_cluster2_dst3_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dst3_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    /* Cluster 3 */
    action compute_distance_cluster3_dst0_min(PortId_t port) {
        meta.cluster3_dst0_distance   = distance_cluster3_dst0_min.execute(port);
    }
    action compute_distance_cluster3_dst0_max(PortId_t port) {
        meta.cluster3_dst0_distance   = distance_cluster3_dst0_max.execute(port);
    }

    action compute_distance_cluster3_dst1_min(PortId_t port) {
        meta.cluster3_dst1_distance   = distance_cluster3_dst1_min.execute(port);
    }
    action compute_distance_cluster3_dst1_max(PortId_t port) {
        meta.cluster3_dst1_distance   = distance_cluster3_dst1_max.execute(port);
    }

    action compute_distance_cluster3_dst2_min(PortId_t port) {
        meta.cluster3_dst2_distance   = distance_cluster3_dst2_min.execute(port);
    }
    action compute_distance_cluster3_dst2_max(PortId_t port) {
        meta.cluster3_dst2_distance   = distance_cluster3_dst2_max.execute(port);
    }

    action compute_distance_cluster3_dst3_min(PortId_t port) {
        meta.cluster3_dst3_distance   = distance_cluster3_dst3_min.execute(port);
    }
    action compute_distance_cluster3_dst3_max(PortId_t port) {
        meta.cluster3_dst3_distance   = distance_cluster3_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_compute_distance_cluster3_dst0_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dst0_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_compute_distance_cluster3_dst0_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dst0_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
    table tbl_compute_distance_cluster3_dst1_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dst1_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 5
    table tbl_compute_distance_cluster3_dst1_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dst1_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 2
    table tbl_compute_distance_cluster3_dst2_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dst2_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_compute_distance_cluster3_dst2_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dst2_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 3
    table tbl_compute_distance_cluster3_dst3_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dst3_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 7
    table tbl_compute_distance_cluster3_dst3_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dst3_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    /* Cluster 4 */
    action compute_distance_cluster4_dst0_min(PortId_t port) {
        meta.cluster4_dst0_distance   = distance_cluster4_dst0_min.execute(port);
    }
    action compute_distance_cluster4_dst0_max(PortId_t port) {
        meta.cluster4_dst0_distance   = distance_cluster4_dst0_max.execute(port);
    }

    action compute_distance_cluster4_dst1_min(PortId_t port) {
        meta.cluster4_dst1_distance   = distance_cluster4_dst1_min.execute(port);
    }
    action compute_distance_cluster4_dst1_max(PortId_t port) {
        meta.cluster4_dst1_distance   = distance_cluster4_dst1_max.execute(port);
    }

    action compute_distance_cluster4_dst2_min(PortId_t port) {
        meta.cluster4_dst2_distance   = distance_cluster4_dst2_min.execute(port);
    }
    action compute_distance_cluster4_dst2_max(PortId_t port) {
        meta.cluster4_dst2_distance   = distance_cluster4_dst2_max.execute(port);
    }

    action compute_distance_cluster4_dst3_min(PortId_t port) {
        meta.cluster4_dst3_distance   = distance_cluster4_dst3_min.execute(port);
    }
    action compute_distance_cluster4_dst3_max(PortId_t port) {
        meta.cluster4_dst3_distance   = distance_cluster4_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_compute_distance_cluster4_dst0_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dst0_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_compute_distance_cluster4_dst0_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dst0_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
    table tbl_compute_distance_cluster4_dst1_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dst1_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 5
    table tbl_compute_distance_cluster4_dst1_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dst1_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 2
    table tbl_compute_distance_cluster4_dst2_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dst2_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_compute_distance_cluster4_dst2_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dst2_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 3
    table tbl_compute_distance_cluster4_dst3_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dst3_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 7
    table tbl_compute_distance_cluster4_dst3_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dst3_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    /****/
    /**** Actions to merge distances and compute min distance */
    /****/

    // If we wanted to put dst1 in another PHV group to free PHV space
    //Hash<bit<32>>(HashAlgorithm_t.IDENTITY) copy_1;
    //Hash<bit<32>>(HashAlgorithm_t.IDENTITY) copy_2;
    //Hash<bit<32>>(HashAlgorithm_t.IDENTITY) copy_3;
    //Hash<bit<32>>(HashAlgorithm_t.IDENTITY) copy_4;

    //action merge_dst1_to_dst0_1_2() {
    //    meta.cluster1_dst0_distance = meta.cluster1_dst0_distance + copy_1.get(meta.cluster1_dst1_distance);
    //    meta.cluster2_dst0_distance = meta.cluster2_dst0_distance + copy_2.get(meta.cluster2_dst1_distance);
    //}

    //action merge_dst1_to_dst0_3_4() {
    //    meta.cluster3_dst0_distance = meta.cluster3_dst0_distance + copy_3.get(meta.cluster3_dst1_distance);
    //    meta.cluster4_dst0_distance = meta.cluster4_dst0_distance + copy_4.get(meta.cluster4_dst1_distance);
    //}

    action merge_dst1_to_dst0() {
        meta.cluster1_dst0_distance = meta.cluster1_dst0_distance + meta.cluster1_dst1_distance;
        meta.cluster2_dst0_distance = meta.cluster2_dst0_distance + meta.cluster2_dst1_distance;
        meta.cluster3_dst0_distance = meta.cluster3_dst0_distance + meta.cluster3_dst1_distance;
        meta.cluster4_dst0_distance = meta.cluster4_dst0_distance + meta.cluster4_dst1_distance;
    }

    action merge_dst2_to_dst0() {
        meta.cluster1_dst0_distance = meta.cluster1_dst0_distance + meta.cluster1_dst2_distance;
        meta.cluster2_dst0_distance = meta.cluster2_dst0_distance + meta.cluster2_dst2_distance;
        meta.cluster3_dst0_distance = meta.cluster3_dst0_distance + meta.cluster3_dst2_distance;
        meta.cluster4_dst0_distance = meta.cluster4_dst0_distance + meta.cluster4_dst2_distance;
    }

    action merge_dst3_to_dst0() {
        meta.cluster1_dst0_distance = meta.cluster1_dst0_distance + meta.cluster1_dst3_distance;
        meta.cluster2_dst0_distance = meta.cluster2_dst0_distance + meta.cluster2_dst3_distance;
        meta.cluster3_dst0_distance = meta.cluster3_dst0_distance + meta.cluster3_dst3_distance;
        meta.cluster4_dst0_distance = meta.cluster4_dst0_distance + meta.cluster4_dst3_distance;
    }

    action compute_min_first() {
        meta.min_d1_d2 = min(meta.cluster1_dst0_distance, meta.cluster2_dst0_distance);
        meta.min_d3_d4 = min(meta.cluster3_dst0_distance, meta.cluster4_dst0_distance);
    }

    action compute_min_second() {
        meta.min_d1_d2_d3_d4 = min(meta.min_d1_d2, meta.min_d3_d4);
    }

    /****/
    /**** Actions to update ranges */
    /****/

    /* Cluster 1 */
    action do_update_cluster1_dst0_min(PortId_t port) {
        update_cluster1_dst0_min.execute(port);
    }
    action do_update_cluster1_dst0_max(PortId_t port) {
        update_cluster1_dst0_max.execute(port);
    }

    action do_update_cluster1_dst1_min(PortId_t port) {
        update_cluster1_dst1_min.execute(port);
    }
    action do_update_cluster1_dst1_max(PortId_t port) {
        update_cluster1_dst1_max.execute(port);
    }

    action do_update_cluster1_dst2_min(PortId_t port) {
        update_cluster1_dst2_min.execute(port);
    }
    action do_update_cluster1_dst2_max(PortId_t port) {
        update_cluster1_dst2_max.execute(port);
    }

    action do_update_cluster1_dst3_min(PortId_t port) {
        update_cluster1_dst3_min.execute(port);
    }
    action do_update_cluster1_dst3_max(PortId_t port) {
        update_cluster1_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_do_update_cluster1_dst0_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dst0_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_do_update_cluster1_dst0_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dst0_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
    table tbl_do_update_cluster1_dst1_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dst1_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 5
    table tbl_do_update_cluster1_dst1_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dst1_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 2
    table tbl_do_update_cluster1_dst2_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dst2_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_do_update_cluster1_dst2_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dst2_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 3
    table tbl_do_update_cluster1_dst3_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dst3_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 7
    table tbl_do_update_cluster1_dst3_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dst3_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    /* Cluster 2 */
    action do_update_cluster2_dst0_min(PortId_t port) {
        update_cluster2_dst0_min.execute(port);
    }
    action do_update_cluster2_dst0_max(PortId_t port) {
        update_cluster2_dst0_max.execute(port);
    }

    action do_update_cluster2_dst1_min(PortId_t port) {
        update_cluster2_dst1_min.execute(port);
    }
    action do_update_cluster2_dst1_max(PortId_t port) {
        update_cluster2_dst1_max.execute(port);
    }

    action do_update_cluster2_dst2_min(PortId_t port) {
        update_cluster2_dst2_min.execute(port);
    }
    action do_update_cluster2_dst2_max(PortId_t port) {
        update_cluster2_dst2_max.execute(port);
    }

    action do_update_cluster2_dst3_min(PortId_t port) {
        update_cluster2_dst3_min.execute(port);
    }
    action do_update_cluster2_dst3_max(PortId_t port) {
        update_cluster2_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_do_update_cluster2_dst0_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dst0_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_do_update_cluster2_dst0_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dst0_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
    table tbl_do_update_cluster2_dst1_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dst1_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 5
    table tbl_do_update_cluster2_dst1_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dst1_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 2
    table tbl_do_update_cluster2_dst2_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dst2_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_do_update_cluster2_dst2_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dst2_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 3
    table tbl_do_update_cluster2_dst3_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dst3_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 7
    table tbl_do_update_cluster2_dst3_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dst3_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    /* Cluster 3 */
    action do_update_cluster3_dst0_min(PortId_t port) {
        update_cluster3_dst0_min.execute(port);
    }
    action do_update_cluster3_dst0_max(PortId_t port) {
        update_cluster3_dst0_max.execute(port);
    }

    action do_update_cluster3_dst1_min(PortId_t port) {
        update_cluster3_dst1_min.execute(port);
    }
    action do_update_cluster3_dst1_max(PortId_t port) {
        update_cluster3_dst1_max.execute(port);
    }

    action do_update_cluster3_dst2_min(PortId_t port) {
        update_cluster3_dst2_min.execute(port);
    }
    action do_update_cluster3_dst2_max(PortId_t port) {
        update_cluster3_dst2_max.execute(port);
    }

    action do_update_cluster3_dst3_min(PortId_t port) {
        update_cluster3_dst3_min.execute(port);
    }
    action do_update_cluster3_dst3_max(PortId_t port) {
        update_cluster3_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_do_update_cluster3_dst0_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dst0_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_do_update_cluster3_dst0_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dst0_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
    table tbl_do_update_cluster3_dst1_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dst1_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 5
    table tbl_do_update_cluster3_dst1_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dst1_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 2
    table tbl_do_update_cluster3_dst2_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dst2_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_do_update_cluster3_dst2_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dst2_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 3
    table tbl_do_update_cluster3_dst3_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dst3_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 7
    table tbl_do_update_cluster3_dst3_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dst3_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    /* Cluster 4 */
    action do_update_cluster4_dst0_min(PortId_t port) {
        update_cluster4_dst0_min.execute(port);
    }
    action do_update_cluster4_dst0_max(PortId_t port) {
        update_cluster4_dst0_max.execute(port);
    }

    action do_update_cluster4_dst1_min(PortId_t port) {
        update_cluster4_dst1_min.execute(port);
    }
    action do_update_cluster4_dst1_max(PortId_t port) {
        update_cluster4_dst1_max.execute(port);
    }

    action do_update_cluster4_dst2_min(PortId_t port) {
        update_cluster4_dst2_min.execute(port);
    }
    action do_update_cluster4_dst2_max(PortId_t port) {
        update_cluster4_dst2_max.execute(port);
    }

    action do_update_cluster4_dst3_min(PortId_t port) {
        update_cluster4_dst3_min.execute(port);
    }
    action do_update_cluster4_dst3_max(PortId_t port) {
        update_cluster4_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_do_update_cluster4_dst0_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dst0_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_do_update_cluster4_dst0_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dst0_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
    table tbl_do_update_cluster4_dst1_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dst1_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 5
    table tbl_do_update_cluster4_dst1_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dst1_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 2
    table tbl_do_update_cluster4_dst2_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dst2_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_do_update_cluster4_dst2_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dst2_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 3
    table tbl_do_update_cluster4_dst3_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dst3_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 7
    table tbl_do_update_cluster4_dst3_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dst3_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    /* Tables and actions to count the traffic of each cluster */
    DirectCounter<bit<32>>(CounterType_t.BYTES) bytes_counter;

    action bytes_count() {
        bytes_counter.count();
    }

    table do_bytes_count {
        key = {
            ig_tm_md.qid: exact @name("queue_id");
        }
        actions = { 
            bytes_count; 
        }
        counters = bytes_counter;
        default_action = bytes_count();
        size = 32;
    }

    /* Register to be used as counter for cluster initialization */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) init_counter;
    RegisterAction<bit<32>, PortId_t, bit<8>>(init_counter)  
    init_count = {
        void apply(inout bit<32> data, out bit<8> current_value) {
            current_value = 0;
            if (data < (bit<32>)5){
                current_value = (bit<8>)data;
            }
            data = data + 1;
        }
    };    

    action do_init_counter(PortId_t port) {
        meta.init_counter_value = init_count.execute(port);
    }

    table tbl_do_init_counter {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_init_counter;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    /* Register to be used as counter to determine when to update clusters */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) updateclusters_counter;
    RegisterAction<bit<32>, PortId_t, bit<8>>(updateclusters_counter)  
    updateclusters_count = {
        void apply(inout bit<32> data, out bit<8> current_value) {
            current_value = 0;
            if (data < (bit<32>)10000000){
                data = data + 1;
                current_value = (bit<8>)0;
            } else {
                data = 0;
                current_value = (bit<8>)1;
            }
        }
    };

    action do_updateclusters_counter(PortId_t port) {
        meta.rs.update_activated = updateclusters_count.execute(port);
    }

    table tbl_do_updateclusters_counter {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_updateclusters_counter;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    /* Define the processing algorithm here */
    apply {

        // If all headers are valid and metadata ready, we run the clustering algorithm
        if (hdr.ipv4.isValid()) {

            if (ig_intr_md.resubmit_flag == 0){ 
                
                // Initial (non-resubmitted) packet

                /* Stage 0 */
                tbl_compute_distance_cluster1_dst0_min.apply();
                tbl_compute_distance_cluster2_dst0_min.apply();
                tbl_compute_distance_cluster3_dst0_min.apply();
                tbl_compute_distance_cluster4_dst0_min.apply();

                /* Stage 1 */
                tbl_compute_distance_cluster1_dst1_min.apply();
                tbl_compute_distance_cluster2_dst1_min.apply();
                tbl_compute_distance_cluster3_dst1_min.apply();
                tbl_compute_distance_cluster4_dst1_min.apply();

                /* Stage 2 */
                tbl_compute_distance_cluster1_dst2_min.apply();
                tbl_compute_distance_cluster2_dst2_min.apply();
                tbl_compute_distance_cluster3_dst2_min.apply();
                tbl_compute_distance_cluster4_dst2_min.apply();

                /* Stage 3 */
                tbl_compute_distance_cluster1_dst3_min.apply();
                tbl_compute_distance_cluster2_dst3_min.apply();
                tbl_compute_distance_cluster3_dst3_min.apply();
                tbl_compute_distance_cluster4_dst3_min.apply();

                /* Stage 4 */
                if (meta.cluster1_dst0_distance == 0) {
                    tbl_compute_distance_cluster1_dst0_max.apply();
                }
                if (meta.cluster2_dst0_distance == 0) {
                    tbl_compute_distance_cluster2_dst0_max.apply();
                }
                if (meta.cluster3_dst0_distance == 0) {
                    tbl_compute_distance_cluster3_dst0_max.apply();
                }
                if (meta.cluster4_dst0_distance == 0) {
                    tbl_compute_distance_cluster4_dst0_max.apply();
                }

                /* Stage 5 */
                if (meta.cluster1_dst1_distance == 0) {
                    tbl_compute_distance_cluster1_dst1_max.apply();
                }
                if (meta.cluster2_dst1_distance == 0) {
                    tbl_compute_distance_cluster2_dst1_max.apply();
                }
                if (meta.cluster3_dst1_distance == 0) {
                    tbl_compute_distance_cluster3_dst1_max.apply();
                }
                if (meta.cluster4_dst1_distance == 0) {
                    tbl_compute_distance_cluster4_dst1_max.apply();
                }

                /* Stage 6 */
                if (meta.cluster1_dst2_distance == 0) {
                    tbl_compute_distance_cluster1_dst2_max.apply();
                }            
                if (meta.cluster2_dst2_distance == 0) {
                    tbl_compute_distance_cluster2_dst2_max.apply();
                }
                if (meta.cluster3_dst2_distance == 0) {
                    tbl_compute_distance_cluster3_dst2_max.apply();
                }
                if (meta.cluster4_dst2_distance == 0) {
                    tbl_compute_distance_cluster4_dst2_max.apply();
                }
                //merge_dst1_to_dst0_1_2();
                //merge_dst1_to_dst0_3_4();
                merge_dst1_to_dst0();

                /* Stage 7 */
                if (meta.cluster1_dst3_distance == 0) {
                    tbl_compute_distance_cluster1_dst3_max.apply();
                }
                if (meta.cluster2_dst3_distance == 0) {
                    tbl_compute_distance_cluster2_dst3_max.apply();
                }
                if (meta.cluster3_dst3_distance == 0) {
                    tbl_compute_distance_cluster3_dst3_max.apply();
                }
                if (meta.cluster4_dst3_distance == 0) {
                    tbl_compute_distance_cluster4_dst3_max.apply();
                }
                merge_dst2_to_dst0();

                /* Stage 8 */
                merge_dst3_to_dst0();

                /* Stage 9 */
                compute_min_first();

                /* Stage 10 */
                compute_min_second();

                // We check if it is one of the first 4 packets, if it is, we initialize the cluster
                tbl_do_init_counter.apply();

                // We check if we need to update the clusters
                tbl_do_updateclusters_counter.apply();

                /* Stage 11 */
                if (meta.min_d1_d2_d3_d4 == meta.cluster1_dst0_distance && meta.init_counter_value == 0) {
                    /* We select cluster 1. Get prio from cluster 1 */
                    meta.rs.cluster_id = 1;
                } else if (meta.min_d1_d2_d3_d4 == meta.cluster2_dst0_distance && meta.init_counter_value == 0) {
                    /* We select cluster 2. Get prio from cluster 2 */
                    meta.rs.cluster_id = 2;
                } else if (meta.min_d1_d2_d3_d4 ==  meta.cluster3_dst0_distance && meta.init_counter_value == 0) {
                    /* We select cluster 3. Get prio from cluster 3 */
                    meta.rs.cluster_id = 3;
                } else if (meta.min_d1_d2_d3_d4 ==  meta.cluster4_dst0_distance && meta.init_counter_value == 0) {
                    /* We select cluster 4. Get prio from cluster 4 */
                    meta.rs.cluster_id = 4;
                } else {
                    meta.rs.cluster_id = meta.init_counter_value;
                    meta.rs.update_activated = 1;
                }
                ig_dprsr_md.resubmit_type = 1;

            } else {

                // Resubmitted packet
                if (meta.rs.update_activated == 1) {

                    /* Stage 0 */
                    tbl_do_update_cluster1_dst0_min.apply();
                    tbl_do_update_cluster2_dst0_min.apply();
                    tbl_do_update_cluster3_dst0_min.apply();
                    tbl_do_update_cluster4_dst0_min.apply();

                    /* Stage 1 */
                    tbl_do_update_cluster1_dst1_min.apply();
                    tbl_do_update_cluster2_dst1_min.apply();
                    tbl_do_update_cluster3_dst1_min.apply();
                    tbl_do_update_cluster4_dst1_min.apply();

                    /* Stage 2 */
                    tbl_do_update_cluster1_dst2_min.apply();
                    tbl_do_update_cluster2_dst2_min.apply();
                    tbl_do_update_cluster3_dst2_min.apply();
                    tbl_do_update_cluster4_dst2_min.apply();

                    /* Stage 3 */
                    tbl_do_update_cluster1_dst3_min.apply();
                    tbl_do_update_cluster2_dst3_min.apply();
                    tbl_do_update_cluster3_dst3_min.apply();
                    tbl_do_update_cluster4_dst3_min.apply();

                    /* Stage 4 */
                    tbl_do_update_cluster1_dst0_max.apply();
                    tbl_do_update_cluster2_dst0_max.apply();
                    tbl_do_update_cluster3_dst0_max.apply();
                    tbl_do_update_cluster4_dst0_max.apply();

                    /* Stage 5 */
                    tbl_do_update_cluster1_dst1_max.apply();
                    tbl_do_update_cluster2_dst1_max.apply();
                    tbl_do_update_cluster3_dst1_max.apply();
                    tbl_do_update_cluster4_dst1_max.apply();

                    /* Stage 6 */
                    tbl_do_update_cluster1_dst2_max.apply();
                    tbl_do_update_cluster2_dst2_max.apply();
                    tbl_do_update_cluster3_dst2_max.apply();
                    tbl_do_update_cluster4_dst2_max.apply();

                    /* Stage 7 */
                    tbl_do_update_cluster1_dst3_max.apply();
                    tbl_do_update_cluster2_dst3_max.apply();
                    tbl_do_update_cluster3_dst3_max.apply();
                    tbl_do_update_cluster4_dst3_max.apply();
                }

                /* Stage 8: Get the priority and forward the resubmitted packet */
                cluster_to_prio.apply();

                /* Stage 9: Compute the amount of traffic mapped to each cluster */
                do_bytes_count.apply();

            }
        }
    }
}

control MyIngressDeparser(packet_out                 pkt,    
    inout my_ingress_headers_t                       hdr,
    in    my_ingress_metadata_t                      meta,
    in    ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md) {

        Resubmit() do_resubmit;
        apply {
            if (ig_dprsr_md.resubmit_type == 1) {
                do_resubmit.emit(meta.rs);
            }
            pkt.emit(hdr); // If the header is valid, will emit it. If not valid, will just jump to the next one.
        }
    }



/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

// Is the same as ipv4_h but with the destination address bytes altogether
header ipv4_egress_h {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> len;
    bit<16> id;
    bit<3>  flags;
    bit<13> frag_offset;
    bit<8>  ttl;
    bit<8>  proto;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<32> dst_addr;
}


struct my_egress_headers_t {
    ethernet_h ethernet;
    ipv4_egress_h ipv4_egress;
}

struct my_egress_metadata_t {}

struct pair {
    bit<32>     first;
    bit<32>     second;
}

parser MyEgressParser(packet_in      pkt,
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    out egress_intrinsic_metadata_t  eg_intr_md) {

        state start {
            pkt.extract(eg_intr_md);
            transition parse_ethernet;
        }

        state parse_ethernet {
            pkt.extract(hdr.ethernet);
            transition select(hdr.ethernet.ether_type) {
                0x0800:  parse_ipv4_egress;
                default: accept;
            }
        }

        state parse_ipv4_egress {
            pkt.extract(hdr.ipv4_egress);
            transition accept;
        }
    }

control MyEgress(
    inout my_egress_headers_t                          hdr,
    inout my_egress_metadata_t                         meta,
    in    egress_intrinsic_metadata_t                  eg_intr_md,
    in    egress_intrinsic_metadata_from_parser_t      eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t     eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t  eg_dport_md) {


    /* We measure throughput of benign and malicious traffic for evaluation */
    DirectCounter<bit<32>>(CounterType_t.BYTES) bytes_counter_malicious_egress;
    DirectCounter<bit<32>>(CounterType_t.BYTES) bytes_counter_benign_egress;

    action bytes_count_malicious_egress() {
         bytes_counter_malicious_egress.count();
    }

    action nop() {
    }

    action bytes_count_benign_egress() {
         bytes_counter_benign_egress.count();
    }

    table do_bytes_count_malicious_egress {
        key = {
            hdr.ipv4_egress.dst_addr : exact;
            //hdr.ipv4_egress.src_addr : exact; // carpet bombing        
        }
        actions = { 
            bytes_count_malicious_egress; 
            @defaultonly nop;
        }
        counters = bytes_counter_malicious_egress;
        const default_action = nop;
        size = 1024;
    }

    table do_bytes_count_benign_egress {
        key = {
            eg_intr_md.egress_port: exact;
        }
        actions = { 
            bytes_count_benign_egress; 
        }
        counters = bytes_counter_benign_egress;
        const default_action = bytes_count_benign_egress;
        size = 1024;
    }

    Register<bit<32>, bit<1>>(1) timestamp;
    RegisterAction<bit<32>, bit<1>, bit<32>>(timestamp) 
    add_timestamp = {
        void apply(inout bit<32> data) {
            data = eg_prsr_md.global_tstamp[47:16]; // The original timestamp is bit<48>
        }
    };

    action do_add_timestamp() {
        add_timestamp.execute(0);
    }

    table tbl_do_add_timestamp {
        actions = {
            do_add_timestamp;
        }
        const default_action = do_add_timestamp;
        size = 1;
    }

    apply {

        /* Stages 10 - 11 */      
        if (hdr.ipv4_egress.isValid()) {

            // We store the latest timestamp
            tbl_do_add_timestamp.apply();

            // If it is malicious:
            if (!do_bytes_count_malicious_egress.apply().hit){

                // If it is benign
                do_bytes_count_benign_egress.apply();
            
            }
        }
    }

}

control MyEgressDeparser(packet_out pkt,
    inout my_egress_headers_t                       hdr, 
    in    my_egress_metadata_t                      meta,
    in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md) {

        apply {
            pkt.emit(hdr); // We do not emit eg_intr_md so that it does not go into the wire
        }
    }

/*************************************************************************
 ****************  F I N A L  P A C K A G E    ***************************
 *************************************************************************/
 
Pipeline(
    MyIngressParser(), MyIngress(), MyIngressDeparser(),
    MyEgressParser(), MyEgress(), MyEgressDeparser()
 ) pipe;

Switch(pipe) main; 