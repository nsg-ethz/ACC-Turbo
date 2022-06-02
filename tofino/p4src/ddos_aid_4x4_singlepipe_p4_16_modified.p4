/* -*- P4_16 -*- */
/* In this code, we select dst2 (8 bits), dst3 (8 bits), sport (16 bits), and dport (16 bits) as features */
/* Usually we have len (16 bits) ttl (8 bits) proto(8 bits) id (16 bits) */
/* We replace (dst2 to ttl), (dst3 to proto), (sport to len), and (dport to id) */

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
    bit<16> cluster_id;
}

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

    // Clustering
    bit<16> cluster_id;

    /* Cluster 1 */
    bit<32> cluster1_sport_distance;  
    bit<32> cluster1_dst2_distance;
    bit<32> cluster1_dport_distance;
    bit<32> cluster1_dst3_distance;

    /* Cluster 2 */
    bit<32> cluster2_sport_distance;  
    bit<32> cluster2_dst2_distance;
    bit<32> cluster2_dport_distance;
    bit<32> cluster2_dst3_distance;

    /* Cluster 3 */
    bit<32> cluster3_sport_distance;  
    bit<32> cluster3_dst2_distance;
    bit<32> cluster3_dport_distance;
    bit<32> cluster3_dst3_distance;

    /* Cluster 4 */
    bit<32> cluster4_sport_distance;  
    bit<32> cluster4_dst2_distance;
    bit<32> cluster4_dport_distance;
    bit<32> cluster4_dst3_distance;

    // Distance helpers
    bit<32> min_d1_d2;
    bit<32> min_d3_d4;
    bit<32> min_d1_d2_d3_d4;
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

        /* Metadata initialization */
        meta.cluster_id = 0;

        /* Cluster 1 */
        meta.cluster1_sport_distance = 0;
        meta.cluster1_dst2_distance = 0;
        meta.cluster1_dport_distance = 0;
        meta.cluster1_dst3_distance = 0;

        /* Cluster 2 */
        meta.cluster2_sport_distance = 0;
        meta.cluster2_dst2_distance = 0;
        meta.cluster2_dport_distance = 0;
        meta.cluster2_dst3_distance = 0;

        /* Cluster 3 */
        meta.cluster3_sport_distance = 0;
        meta.cluster3_dst2_distance = 0;
        meta.cluster3_dport_distance = 0;
        meta.cluster3_dst3_distance = 0;

        /* Cluster 4 */
        meta.cluster4_sport_distance = 0;
        meta.cluster4_dst2_distance = 0;
        meta.cluster4_dport_distance = 0;
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
        /* Mandatory code required by Tofino Architecture */
        pkt.advance(PORT_METADATA_SIZE);
        transition parse_ethernet;
    }

    state parse_resubmit {
        resubmit_h rh;
        pkt.extract(rh); // Extracted 16 bits into metadata
        meta.cluster_id = rh.cluster_id;
        //pkt.advance(PORT_METADATA_SIZE - 16); // For the tofino model we have to remove it
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
    action send(PortId_t port) {
        ig_tm_md.ucast_egress_port = port;
    }

    action set_qid(QueueId_t qid) {
        ig_tm_md.qid = qid;
    }

    table cluster_to_prio {
        key = {
            meta.cluster_id : exact;
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
    /* Transport sport */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_sport_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_sport_min) 
    distance_cluster1_sport_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.sport < data) {
                distance = data - (bit<32>)hdr.transport.sport;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<16>>(cluster1_sport_min) 
    update_cluster1_sport_min = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 1) {
                if ((bit<32>)hdr.transport.sport < data) {
                    data = (bit<32>)hdr.transport.sport;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_sport_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_sport_max) 
    distance_cluster1_sport_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.sport > data) {
                distance = (bit<32>)hdr.transport.sport - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_sport_max) 
    update_cluster1_sport_max = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 1) {
                if ((bit<32>)hdr.transport.sport > data) {
                    data = (bit<32>)hdr.transport.sport;
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
            if (meta.cluster_id == 1) {
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
            if (meta.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst2 > data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    /* Transport dport */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dport_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dport_min) 
    distance_cluster1_dport_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.dport < data) {
                distance = data - (bit<32>)hdr.transport.dport;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dport_min) 
    update_cluster1_dport_min = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 1) {
                if ((bit<32>)hdr.transport.dport < data) {
                    data = (bit<32>)hdr.transport.dport;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster1_dport_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dport_max) 
    distance_cluster1_dport_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.dport > data) {
                distance = (bit<32>)hdr.transport.dport - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster1_dport_max) 
    update_cluster1_dport_max = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 1) {
                if ((bit<32>)hdr.transport.dport > data) {
                    data = (bit<32>)hdr.transport.dport;
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
            if (meta.cluster_id == 1) {
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
            if (meta.cluster_id == 1) {
                if ((bit<32>)hdr.ipv4.dst3 > data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    /* Cluster 2 */
    /* Transport sport */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_sport_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_sport_min) 
    distance_cluster2_sport_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.sport < data) {
                distance = data - (bit<32>)hdr.transport.sport;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_sport_min) 
    update_cluster2_sport_min = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 2) {
                if ((bit<32>)hdr.transport.sport < data) {
                    data = (bit<32>)hdr.transport.sport;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_sport_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_sport_max) 
    distance_cluster2_sport_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.sport > data) {
                distance = (bit<32>)hdr.transport.sport - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_sport_max) 
    update_cluster2_sport_max = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 2) {
                if ((bit<32>)hdr.transport.sport > data) {
                    data = (bit<32>)hdr.transport.sport;
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
            if (meta.cluster_id == 2) {
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
            if (meta.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst2 > data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    /* Transport dport */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dport_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dport_min) 
    distance_cluster2_dport_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.dport < data) {
                distance = data - (bit<32>)hdr.transport.dport;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dport_min) 
    update_cluster2_dport_min = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 2) {
                if ((bit<32>)hdr.transport.dport < data) {
                    data = (bit<32>)hdr.transport.dport;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster2_dport_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dport_max) 
    distance_cluster2_dport_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.dport > data) {
                distance = (bit<32>)hdr.transport.dport - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster2_dport_max) 
    update_cluster2_dport_max = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 2) {
                if ((bit<32>)hdr.transport.dport > data) {
                    data = (bit<32>)hdr.transport.dport;
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
            if (meta.cluster_id == 2) {
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
            if (meta.cluster_id == 2) {
                if ((bit<32>)hdr.ipv4.dst3 > data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    /* Cluster 3 */
    /* Transport sport */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_sport_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_sport_min) 
    distance_cluster3_sport_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.sport < data) {
                distance = data - (bit<32>)hdr.transport.sport;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_sport_min) 
    update_cluster3_sport_min = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 3) {
                if ((bit<32>)hdr.transport.sport < data) {
                    data = (bit<32>)hdr.transport.sport;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_sport_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_sport_max) 
    distance_cluster3_sport_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.sport > data) {
                distance = (bit<32>)hdr.transport.sport - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_sport_max) 
    update_cluster3_sport_max = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 3) {
                if ((bit<32>)hdr.transport.sport > data) {
                    data = (bit<32>)hdr.transport.sport;
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
            if (meta.cluster_id == 3) {
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
            if (meta.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst2 > data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    /* Transport dport */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dport_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dport_min) 
    distance_cluster3_dport_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.dport < data) {
                distance = data - (bit<32>)hdr.transport.dport;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dport_min) 
    update_cluster3_dport_min = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 3) {
                if ((bit<32>)hdr.transport.dport < data) {
                    data = (bit<32>)hdr.transport.dport;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster3_dport_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dport_max) 
    distance_cluster3_dport_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.dport > data) {
                distance = (bit<32>)hdr.transport.dport - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster3_dport_max) 
    update_cluster3_dport_max = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 3) {
                if ((bit<32>)hdr.transport.dport > data) {
                    data = (bit<32>)hdr.transport.dport;
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
            if (meta.cluster_id == 3) {
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
            if (meta.cluster_id == 3) {
                if ((bit<32>)hdr.ipv4.dst3 > data) {
                    data = (bit<32>)hdr.ipv4.dst3;
                }
            }
        }
    };

    /* Cluster 4 */
    /* Transport sport */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_sport_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_sport_min) 
    distance_cluster4_sport_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.sport < data) {
                distance = data - (bit<32>)hdr.transport.sport;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_sport_min) 
    update_cluster4_sport_min = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 4) {
                if ((bit<32>)hdr.transport.sport < data) {
                    data = (bit<32>)hdr.transport.sport;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_sport_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_sport_max) 
    distance_cluster4_sport_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.sport > data) {
                distance = (bit<32>)hdr.transport.sport - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_sport_max) 
    update_cluster4_sport_max = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 4) {
                if ((bit<32>)hdr.transport.sport > data) {
                    data = (bit<32>)hdr.transport.sport;
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
            if (meta.cluster_id == 4) {
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
            if (meta.cluster_id == 4) {
                if ((bit<32>)hdr.ipv4.dst2 > data) {
                    data = (bit<32>)hdr.ipv4.dst2;
                }
            }
        }
    };

    /* Transport dport */
    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dport_min;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dport_min) 
    distance_cluster4_dport_min = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.dport < data) {
                distance = data - (bit<32>)hdr.transport.dport;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dport_min) 
    update_cluster4_dport_min = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 4) {
                if ((bit<32>)hdr.transport.dport < data) {
                    data = (bit<32>)hdr.transport.dport;
                }
            }
        }
    };

    Register<bit<32>, PortId_t>(NUM_EGRESS_PORTS) cluster4_dport_max;
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dport_max) 
    distance_cluster4_dport_max = {
        void apply(inout bit<32> data, out bit<32> distance) {
            distance = 0;
            if ((bit<32>)hdr.transport.dport > data) {
                distance = (bit<32>)hdr.transport.dport - data;
            }
        }
    };
    RegisterAction<bit<32>, PortId_t, bit<32>>(cluster4_dport_max) 
    update_cluster4_dport_max = {
        void apply(inout bit<32> data) {
            if (meta.cluster_id == 4) {
                if ((bit<32>)hdr.transport.dport > data) {
                    data = (bit<32>)hdr.transport.dport;
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
            if (meta.cluster_id == 4) {
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
            if (meta.cluster_id == 4) {
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
    action compute_distance_cluster1_sport_min(PortId_t port) {
        meta.cluster1_sport_distance   = distance_cluster1_sport_min.execute(port);
    }
    action compute_distance_cluster1_sport_max(PortId_t port) {
        meta.cluster1_sport_distance   = distance_cluster1_sport_max.execute(port);
    }

    action compute_distance_cluster1_dst2_min(PortId_t port) {
        meta.cluster1_dst2_distance   = distance_cluster1_dst2_min.execute(port);
    }
    action compute_distance_cluster1_dst2_max(PortId_t port) {
        meta.cluster1_dst2_distance   = distance_cluster1_dst2_max.execute(port);
    }

    action compute_distance_cluster1_dport_min(PortId_t port) {
        meta.cluster1_dport_distance   = distance_cluster1_dport_min.execute(port);
    }
    action compute_distance_cluster1_dport_max(PortId_t port) {
        meta.cluster1_dport_distance   = distance_cluster1_dport_max.execute(port);
    }

    action compute_distance_cluster1_dst3_min(PortId_t port) {
        meta.cluster1_dst3_distance   = distance_cluster1_dst3_min.execute(port);
    }
    action compute_distance_cluster1_dst3_max(PortId_t port) {
        meta.cluster1_dst3_distance   = distance_cluster1_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_compute_distance_cluster1_sport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_sport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_compute_distance_cluster1_sport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_sport_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
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

    @pragma stage 5
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

    @pragma stage 2
    table tbl_compute_distance_cluster1_dport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    @pragma stage 6
    table tbl_compute_distance_cluster1_dport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster1_dport_max;
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
    action compute_distance_cluster2_sport_min(PortId_t port) {
        meta.cluster2_sport_distance   = distance_cluster2_sport_min.execute(port);
    }
    action compute_distance_cluster2_sport_max(PortId_t port) {
        meta.cluster2_sport_distance   = distance_cluster2_sport_max.execute(port);
    }

    action compute_distance_cluster2_dst2_min(PortId_t port) {
        meta.cluster2_dst2_distance   = distance_cluster2_dst2_min.execute(port);
    }
    action compute_distance_cluster2_dst2_max(PortId_t port) {
        meta.cluster2_dst2_distance   = distance_cluster2_dst2_max.execute(port);
    }

    action compute_distance_cluster2_dport_min(PortId_t port) {
        meta.cluster2_dport_distance   = distance_cluster2_dport_min.execute(port);
    }
    action compute_distance_cluster2_dport_max(PortId_t port) {
        meta.cluster2_dport_distance   = distance_cluster2_dport_max.execute(port);
    }

    action compute_distance_cluster2_dst3_min(PortId_t port) {
        meta.cluster2_dst3_distance   = distance_cluster2_dst3_min.execute(port);
    }
    action compute_distance_cluster2_dst3_max(PortId_t port) {
        meta.cluster2_dst3_distance   = distance_cluster2_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_compute_distance_cluster2_sport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_sport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    } 

    @pragma stage 4
    table tbl_compute_distance_cluster2_sport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_sport_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
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

    @pragma stage 5
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

    @pragma stage 2
    table tbl_compute_distance_cluster2_dport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_compute_distance_cluster2_dport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster2_dport_max;
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
    action compute_distance_cluster3_sport_min(PortId_t port) {
        meta.cluster3_sport_distance   = distance_cluster3_sport_min.execute(port);
    }
    action compute_distance_cluster3_sport_max(PortId_t port) {
        meta.cluster3_sport_distance   = distance_cluster3_sport_max.execute(port);
    }

    action compute_distance_cluster3_dst2_min(PortId_t port) {
        meta.cluster3_dst2_distance   = distance_cluster3_dst2_min.execute(port);
    }
    action compute_distance_cluster3_dst2_max(PortId_t port) {
        meta.cluster3_dst2_distance   = distance_cluster3_dst2_max.execute(port);
    }

    action compute_distance_cluster3_dport_min(PortId_t port) {
        meta.cluster3_dport_distance   = distance_cluster3_dport_min.execute(port);
    }
    action compute_distance_cluster3_dport_max(PortId_t port) {
        meta.cluster3_dport_distance   = distance_cluster3_dport_max.execute(port);
    }

    action compute_distance_cluster3_dst3_min(PortId_t port) {
        meta.cluster3_dst3_distance   = distance_cluster3_dst3_min.execute(port);
    }
    action compute_distance_cluster3_dst3_max(PortId_t port) {
        meta.cluster3_dst3_distance   = distance_cluster3_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_compute_distance_cluster3_sport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_sport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_compute_distance_cluster3_sport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_sport_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
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

    @pragma stage 5
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

    @pragma stage 2
    table tbl_compute_distance_cluster3_dport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_compute_distance_cluster3_dport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster3_dport_max;
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
    action compute_distance_cluster4_sport_min(PortId_t port) {
        meta.cluster4_sport_distance   = distance_cluster4_sport_min.execute(port);
    }
    action compute_distance_cluster4_sport_max(PortId_t port) {
        meta.cluster4_sport_distance   = distance_cluster4_sport_max.execute(port);
    }

    action compute_distance_cluster4_dst2_min(PortId_t port) {
        meta.cluster4_dst2_distance   = distance_cluster4_dst2_min.execute(port);
    }
    action compute_distance_cluster4_dst2_max(PortId_t port) {
        meta.cluster4_dst2_distance   = distance_cluster4_dst2_max.execute(port);
    }

    action compute_distance_cluster4_dport_min(PortId_t port) {
        meta.cluster4_dport_distance   = distance_cluster4_dport_min.execute(port);
    }
    action compute_distance_cluster4_dport_max(PortId_t port) {
        meta.cluster4_dport_distance   = distance_cluster4_dport_max.execute(port);
    }

    action compute_distance_cluster4_dst3_min(PortId_t port) {
        meta.cluster4_dst3_distance   = distance_cluster4_dst3_min.execute(port);
    }
    action compute_distance_cluster4_dst3_max(PortId_t port) {
        meta.cluster4_dst3_distance   = distance_cluster4_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_compute_distance_cluster4_sport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_sport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_compute_distance_cluster4_sport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_sport_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
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

    @pragma stage 5
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

    @pragma stage 2
    table tbl_compute_distance_cluster4_dport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_compute_distance_cluster4_dport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            compute_distance_cluster4_dport_max;
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

    // If we wanted to put dst2 in another PHV group to free PHV space
    //Hash<bit<32>>(HashAlgorithm_t.IDENTITY) copy_1;
    //Hash<bit<32>>(HashAlgorithm_t.IDENTITY) copy_2;
    //Hash<bit<32>>(HashAlgorithm_t.IDENTITY) copy_3;
    //Hash<bit<32>>(HashAlgorithm_t.IDENTITY) copy_4;

    //action merge_dst2_to_sport_1_2() {
    //    meta.cluster1_sport_distance = meta.cluster1_sport_distance + copy_1.get(meta.cluster1_dst2_distance);
    //    meta.cluster2_sport_distance = meta.cluster2_sport_distance + copy_2.get(meta.cluster2_dst2_distance);
    //}

    //action merge_dst2_to_sport_3_4() {
    //    meta.cluster3_sport_distance = meta.cluster3_sport_distance + copy_3.get(meta.cluster3_dst2_distance);
    //    meta.cluster4_sport_distance = meta.cluster4_sport_distance + copy_4.get(meta.cluster4_dst2_distance);
    //}

    action merge_dst2_to_sport() {
        meta.cluster1_sport_distance = meta.cluster1_sport_distance + meta.cluster1_dst2_distance;
        meta.cluster2_sport_distance = meta.cluster2_sport_distance + meta.cluster2_dst2_distance;
        meta.cluster3_sport_distance = meta.cluster3_sport_distance + meta.cluster3_dst2_distance;
        meta.cluster4_sport_distance = meta.cluster4_sport_distance + meta.cluster4_dst2_distance;
    }

    action merge_dport_to_sport() {
        meta.cluster1_sport_distance = meta.cluster1_sport_distance + meta.cluster1_dport_distance;
        meta.cluster2_sport_distance = meta.cluster2_sport_distance + meta.cluster2_dport_distance;
        meta.cluster3_sport_distance = meta.cluster3_sport_distance + meta.cluster3_dport_distance;
        meta.cluster4_sport_distance = meta.cluster4_sport_distance + meta.cluster4_dport_distance;
    }

    action merge_dst3_to_sport() {
        meta.cluster1_sport_distance = meta.cluster1_sport_distance + meta.cluster1_dst3_distance;
        meta.cluster2_sport_distance = meta.cluster2_sport_distance + meta.cluster2_dst3_distance;
        meta.cluster3_sport_distance = meta.cluster3_sport_distance + meta.cluster3_dst3_distance;
        meta.cluster4_sport_distance = meta.cluster4_sport_distance + meta.cluster4_dst3_distance;
    }

    action compute_min_first() {
        meta.min_d1_d2 = min(meta.cluster1_sport_distance, meta.cluster2_sport_distance);
        meta.min_d3_d4 = min(meta.cluster3_sport_distance, meta.cluster4_sport_distance);
    }

    action compute_min_second() {
        meta.min_d1_d2_d3_d4 = min(meta.min_d1_d2, meta.min_d3_d4);
    }

    /****/
    /**** Actions to update ranges */
    /****/

    /* Cluster 1 */
    action do_update_cluster1_sport_min(PortId_t port) {
        update_cluster1_sport_min.execute(port);
    }
    action do_update_cluster1_sport_max(PortId_t port) {
        update_cluster1_sport_max.execute(port);
    }

    action do_update_cluster1_dst2_min(PortId_t port) {
        update_cluster1_dst2_min.execute(port);
    }
    action do_update_cluster1_dst2_max(PortId_t port) {
        update_cluster1_dst2_max.execute(port);
    }

    action do_update_cluster1_dport_min(PortId_t port) {
        update_cluster1_dport_min.execute(port);
    }
    action do_update_cluster1_dport_max(PortId_t port) {
        update_cluster1_dport_max.execute(port);
    }

    action do_update_cluster1_dst3_min(PortId_t port) {
        update_cluster1_dst3_min.execute(port);
    }
    action do_update_cluster1_dst3_max(PortId_t port) {
        update_cluster1_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_do_update_cluster1_sport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_sport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_do_update_cluster1_sport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_sport_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
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

    @pragma stage 5
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

    @pragma stage 2
    table tbl_do_update_cluster1_dport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_do_update_cluster1_dport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster1_dport_max;
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
    action do_update_cluster2_sport_min(PortId_t port) {
        update_cluster2_sport_min.execute(port);
    }
    action do_update_cluster2_sport_max(PortId_t port) {
        update_cluster2_sport_max.execute(port);
    }

    action do_update_cluster2_dst2_min(PortId_t port) {
        update_cluster2_dst2_min.execute(port);
    }
    action do_update_cluster2_dst2_max(PortId_t port) {
        update_cluster2_dst2_max.execute(port);
    }

    action do_update_cluster2_dport_min(PortId_t port) {
        update_cluster2_dport_min.execute(port);
    }
    action do_update_cluster2_dport_max(PortId_t port) {
        update_cluster2_dport_max.execute(port);
    }

    action do_update_cluster2_dst3_min(PortId_t port) {
        update_cluster2_dst3_min.execute(port);
    }
    action do_update_cluster2_dst3_max(PortId_t port) {
        update_cluster2_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_do_update_cluster2_sport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_sport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_do_update_cluster2_sport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_sport_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
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

    @pragma stage 5
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

    @pragma stage 2
    table tbl_do_update_cluster2_dport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_do_update_cluster2_dport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster2_dport_max;
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
    action do_update_cluster3_sport_min(PortId_t port) {
        update_cluster3_sport_min.execute(port);
    }
    action do_update_cluster3_sport_max(PortId_t port) {
        update_cluster3_sport_max.execute(port);
    }

    action do_update_cluster3_dst2_min(PortId_t port) {
        update_cluster3_dst2_min.execute(port);
    }
    action do_update_cluster3_dst2_max(PortId_t port) {
        update_cluster3_dst2_max.execute(port);
    }

    action do_update_cluster3_dport_min(PortId_t port) {
        update_cluster3_dport_min.execute(port);
    }
    action do_update_cluster3_dport_max(PortId_t port) {
        update_cluster3_dport_max.execute(port);
    }

    action do_update_cluster3_dst3_min(PortId_t port) {
        update_cluster3_dst3_min.execute(port);
    }
    action do_update_cluster3_dst3_max(PortId_t port) {
        update_cluster3_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_do_update_cluster3_sport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_sport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_do_update_cluster3_sport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_sport_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
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

    @pragma stage 5
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

    @pragma stage 2
    table tbl_do_update_cluster3_dport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_do_update_cluster3_dport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster3_dport_max;
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
    action do_update_cluster4_sport_min(PortId_t port) {
        update_cluster4_sport_min.execute(port);
    }
    action do_update_cluster4_sport_max(PortId_t port) {
        update_cluster4_sport_max.execute(port);
    }

    action do_update_cluster4_dst2_min(PortId_t port) {
        update_cluster4_dst2_min.execute(port);
    }
    action do_update_cluster4_dst2_max(PortId_t port) {
        update_cluster4_dst2_max.execute(port);
    }

    action do_update_cluster4_dport_min(PortId_t port) {
        update_cluster4_dport_min.execute(port);
    }
    action do_update_cluster4_dport_max(PortId_t port) {
        update_cluster4_dport_max.execute(port);
    }

    action do_update_cluster4_dst3_min(PortId_t port) {
        update_cluster4_dst3_min.execute(port);
    }
    action do_update_cluster4_dst3_max(PortId_t port) {
        update_cluster4_dst3_max.execute(port);
    }

    @pragma stage 0
    table tbl_do_update_cluster4_sport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_sport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 4
    table tbl_do_update_cluster4_sport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_sport_max;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 1
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

    @pragma stage 5
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

    @pragma stage 2
    table tbl_do_update_cluster4_dport_min {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dport_min;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 512;
    }

    @pragma stage 6
    table tbl_do_update_cluster4_dport_max {
        key = {
            ig_tm_md.ucast_egress_port : exact;
        }
        actions = {
            do_update_cluster4_dport_max;
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

    /* Define the processing algorithm here */
    apply {

        // If all headers are valid and metadata ready, we run the clustering algorithm
        if (hdr.ipv4.isValid()) {

            if (ig_intr_md.resubmit_flag == 0){ 
                
                // Initial (non-resubmitted) packet

                /* Stage 0 */
                tbl_compute_distance_cluster1_sport_min.apply();
                tbl_compute_distance_cluster2_sport_min.apply();
                tbl_compute_distance_cluster3_sport_min.apply();
                tbl_compute_distance_cluster4_sport_min.apply();

                /* Stage 1 */
                tbl_compute_distance_cluster1_dst2_min.apply();
                tbl_compute_distance_cluster2_dst2_min.apply();
                tbl_compute_distance_cluster3_dst2_min.apply();
                tbl_compute_distance_cluster4_dst2_min.apply();

                /* Stage 2 */
                tbl_compute_distance_cluster1_dport_min.apply();
                tbl_compute_distance_cluster2_dport_min.apply();
                tbl_compute_distance_cluster3_dport_min.apply();
                tbl_compute_distance_cluster4_dport_min.apply();

                /* Stage 3 */
                tbl_compute_distance_cluster1_dst3_min.apply();
                tbl_compute_distance_cluster2_dst3_min.apply();
                tbl_compute_distance_cluster3_dst3_min.apply();
                tbl_compute_distance_cluster4_dst3_min.apply();

                /* Stage 4 */
                if (meta.cluster1_sport_distance == 0) {
                    tbl_compute_distance_cluster1_sport_max.apply();
                }
                if (meta.cluster2_sport_distance == 0) {
                    tbl_compute_distance_cluster2_sport_max.apply();
                }
                if (meta.cluster3_sport_distance == 0) {
                    tbl_compute_distance_cluster3_sport_max.apply();
                }
                if (meta.cluster4_sport_distance == 0) {
                    tbl_compute_distance_cluster4_sport_max.apply();
                }

                /* Stage 5 */
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

                /* Stage 6 */
                if (meta.cluster1_dport_distance == 0) {
                    tbl_compute_distance_cluster1_dport_max.apply();
                }            
                if (meta.cluster2_dport_distance == 0) {
                    tbl_compute_distance_cluster2_dport_max.apply();
                }
                if (meta.cluster3_dport_distance == 0) {
                    tbl_compute_distance_cluster3_dport_max.apply();
                }
                if (meta.cluster4_dport_distance == 0) {
                    tbl_compute_distance_cluster4_dport_max.apply();
                }
                //merge_dst2_to_sport_1_2();
                //merge_dst2_to_sport_3_4();
                merge_dst2_to_sport();

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
                merge_dport_to_sport();

                /* Stage 8 */
                merge_dst3_to_sport();

                /* Stage 9 */
                compute_min_first();

                /* Stage 10 */
                compute_min_second();

                /* Stage 11 */
                if (meta.min_d1_d2_d3_d4 == meta.cluster1_sport_distance) {
                    /* We select cluster 1. Get prio from cluster 1 */
                    meta.cluster_id = 1;
                } else if (meta.min_d1_d2_d3_d4 == meta.cluster2_sport_distance) {
                    /* We select cluster 2. Get prio from cluster 2 */
                    meta.cluster_id = 2;
                } else if (meta.min_d1_d2_d3_d4 ==  meta.cluster3_sport_distance) {
                    /* We select cluster 3. Get prio from cluster 3 */
                    meta.cluster_id = 3;
                } else if (meta.min_d1_d2_d3_d4 ==  meta.cluster4_sport_distance) {
                    /* We select cluster 4. Get prio from cluster 4 */
                    meta.cluster_id = 4;
                }
                ig_dprsr_md.resubmit_type = 1;

            } else {

                // Resubmitted packet

                /* Stage 0 */
                tbl_do_update_cluster1_sport_min.apply();
                tbl_do_update_cluster2_sport_min.apply();
                tbl_do_update_cluster3_sport_min.apply();
                tbl_do_update_cluster4_sport_min.apply();

                /* Stage 1 */
                tbl_do_update_cluster1_dst2_min.apply();
                tbl_do_update_cluster2_dst2_min.apply();
                tbl_do_update_cluster3_dst2_min.apply();
                tbl_do_update_cluster4_dst2_min.apply();

                /* Stage 2 */
                tbl_do_update_cluster1_dport_min.apply();
                tbl_do_update_cluster2_dport_min.apply();
                tbl_do_update_cluster3_dport_min.apply();
                tbl_do_update_cluster4_dport_min.apply();

                /* Stage 3 */
                tbl_do_update_cluster1_dst3_min.apply();
                tbl_do_update_cluster2_dst3_min.apply();
                tbl_do_update_cluster3_dst3_min.apply();
                tbl_do_update_cluster4_dst3_min.apply();      

                /* Stage 4 */
                tbl_do_update_cluster1_sport_max.apply();
                tbl_do_update_cluster2_sport_max.apply();
                tbl_do_update_cluster3_sport_max.apply();
                tbl_do_update_cluster4_sport_max.apply();

                /* Stage 5 */
                tbl_do_update_cluster1_dst2_max.apply();
                tbl_do_update_cluster2_dst2_max.apply();
                tbl_do_update_cluster3_dst2_max.apply();
                tbl_do_update_cluster4_dst2_max.apply();

                /* Stage 6 */
                tbl_do_update_cluster1_dport_max.apply();
                tbl_do_update_cluster2_dport_max.apply();
                tbl_do_update_cluster3_dport_max.apply();
                tbl_do_update_cluster4_dport_max.apply();

                /* Stage 7 */
                tbl_do_update_cluster1_dst3_max.apply();
                tbl_do_update_cluster2_dst3_max.apply();
                tbl_do_update_cluster3_dst3_max.apply();
                tbl_do_update_cluster4_dst3_max.apply();

                /* Stage 8: Get the priority and forward the resubmitted packet */
                cluster_to_prio.apply();

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
                do_resubmit.emit<resubmit_h>({meta.cluster_id});
            }
            pkt.emit(hdr); // If the header is valid, will emit it. If not valid, will just jump to the next one.
        }
    }



/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

/* Since we don't want to do any egress processing, we keep the egress headers and metadata empty */
struct my_egress_headers_t {
    ethernet_h ethernet;
    ipv4_h ipv4;
    transport_h  transport;
}

struct my_egress_metadata_t {}

parser MyEgressParser(packet_in      pkt,
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    out egress_intrinsic_metadata_t  eg_intr_md) {

        state start {
            pkt.extract(eg_intr_md);
            //transition accept;
            transition parse_ethernet;
        }

        state parse_ethernet {
            pkt.extract(hdr.ethernet);
            transition select(hdr.ethernet.ether_type) {
                0x0800:  parse_ipv4;
                default: accept;
            }
        }

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

control MyEgress(
    inout my_egress_headers_t                          hdr,
    inout my_egress_metadata_t                         meta,
    in    egress_intrinsic_metadata_t                  eg_intr_md,
    in    egress_intrinsic_metadata_from_parser_t      eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t     eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t  eg_dport_md) {


    DirectCounter<bit<32>>(CounterType_t.PACKETS) packet_counter;
    DirectCounter<bit<32>>(CounterType_t.BYTES) bytes_counter;

    action packet_count() {
        packet_counter.count();
    }
    action bytes_count() {
        bytes_counter.count();
    }

    table do_packet_count {
        key = {
            eg_intr_md.egress_qid: exact @name("queue_id");
        }
        actions = { 
            packet_count; 
        }
        counters = packet_counter;
        default_action = packet_count();
        size = 32;
    }

    table do_bytes_count {
        key = {
            eg_intr_md.egress_qid: exact @name("queue_id");
        }
        actions = { 
            bytes_count; 
        }
        counters = bytes_counter;
        default_action = bytes_count();
        size = 32;
    }

    apply {

        /* Stages 8 - 11 */
        /* We can extract statistics of each cluster (e.g., throughput and pps) */
        /* These statistics will be used by the controller to allocate the priorities */
        if (hdr.ipv4.isValid()) {
            do_packet_count.apply();
            do_bytes_count.apply();

            // For debugging
            hdr.ipv4.diffserv = (bit<8>)eg_intr_md.egress_qid;

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