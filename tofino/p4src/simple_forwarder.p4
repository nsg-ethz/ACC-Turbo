/* -*- P4_16 -*- */
#include <core.p4>
#include <tna.p4>

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
    bit<16> total_len;
    bit<16> identification;
    bit<3>  flags;
    bit<13> frag_offset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<32> dst_addr;
}

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

/* All the headers we plan to process in the ingress */
struct my_ingress_headers_t {
    ethernet_h ethernet;
    ipv4_h ipv4;
}

/* All intermediate results that need to be available 
 * to all P4-programmable components in ingress
 */
struct my_ingress_metadata_t {
}

parser MyIngressParser(packet_in      pkt,
    out my_ingress_headers_t          hdr, 
    out my_ingress_metadata_t         meta, 
    out ingress_intrinsic_metadata_t  ig_intr_md) {

    state start {
        /* Mandatory code required by Tofino Architecture */
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);
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
        transition accept;
    }
}

control MyIngress(
    /* User */
    inout my_ingress_headers_t                       hdr,
    inout my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_t               ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t   ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md) {   

    /* Define variables, actions and tables here */
    action send() {
        /* We hardcode the egress port (all packets towards port 140) */
        ig_tm_md.ucast_egress_port = 140;
    }

    /* Define the processing algorithm here */
    apply {
        send();
    }
}

/*** DEPARSER ***/

control MyIngressDeparser(packet_out                 pkt,
    /* User */
    inout my_ingress_headers_t                       hdr,
    in    my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md) {

        apply {
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