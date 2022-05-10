/* -*- P4_16 -*- */

#include <core.p4>
#include <tna.p4>

/*************************************************************************
 ************* C O N S T A N T S    A N D   T Y P E S  *******************
*************************************************************************/

#define BLOOM_FILTER_ENTRIES 1024

typedef bit<10> register_num_entries; // This determines the number of indexes supported by the register
typedef bit<32> register_max_count; // This is the width (in bits) of the maximum value that a register entry can hold

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
    bit<32> dst_addr;
}

header transport_h {
    bit<16> sport;
    bit<16> dport;
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
    bit<10> index;
    bit<1> ctr_exceeded;
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
        meta.index = 0;
        meta.ctr_exceeded = 0;

        /* Mandatory code required by Tofino Architecture */
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
        transition select(hdr.ipv4.proto) {
            (6)  : parse_transport;
            (17) : parse_transport;
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

    // Hash computation
    Hash<bit<16>>(HashAlgorithm_t.RANDOM) hash_function;

    action compute_hash() {
        meta.index = (bit<10>)(hash_function.get({
            hdr.ipv4.src_addr
        }));
    }

    table tbl_compute_hash {
        actions = {
            compute_hash;
        }
        const default_action = compute_hash();
        size = 1;
    }

    // Bloom filter instantiation
    Register<register_max_count, register_num_entries>(BLOOM_FILTER_ENTRIES) counting_bloom_filter;
    
    RegisterAction<register_max_count, register_num_entries,  bit<1>>(counting_bloom_filter) 
    read_and_update_bloom_filter = {
        void apply(inout register_max_count data) {
            data = data + 1;
        }
    };

    action update_bloom_filter() {
        read_and_update_bloom_filter.execute(meta.index);
    }

    table tbl_update_bloom_filter {
        actions = {
            update_bloom_filter;
        }
        const default_action = update_bloom_filter();
        size = 1;
    }

    action drop() {
        ig_dprsr_md.drop_ctl = 0x1; // Mark packet for dropping after ingress.
    }

    table tbl_drop {
        key = {
            hdr.ipv4.dst_addr: exact;
        }
        actions = {
            drop;
            @defaultonly NoAction;
        }
        const default_action = NoAction();
        size = 5;
    }

    // Ingress processing
    apply {

        // If all headers are valid and metadata ready, we run the heavy-hitter
        if (hdr.ipv4.isValid()) {
            if (hdr.transport.isValid()){

                // We first compute the hash to get the index
                tbl_compute_hash.apply();
                tbl_update_bloom_filter.apply();            

                // We decide from the controller whether to drop the traffic or not, based on the counter values
                tbl_drop.apply();
            }
        }
    }
}

control MyIngressDeparser(packet_out                 pkt,    
    inout my_ingress_headers_t                       hdr,
    in    my_ingress_metadata_t                      meta,
    in    ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md) {

        apply {
            pkt.emit(hdr);
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