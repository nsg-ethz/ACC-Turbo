morphing_attack_vectors = {

    "attack_vector_1" : {

        # Times and rate
        "start_time_us":     5000000,
        "end_time_us":       10000000,
        "rate_bps":          5000000000,

        # ETH layer
        "eth_src":          b'\x00\x00\x00\x00\x00\x00',
        "eth_dst":          b'\x00\x00\x00\x00\x00\x00',

        # IP layer
        "ip_src_0":         "192",
        "ip_src_1":         "168",
        "ip_src_2":         "0",
        "ip_src_3":         "5",

        "ip_dst_0":          "172",
        "ip_dst_1":          "168",
        "ip_dst_2":          "0",
        "ip_dst_3":          "50",

        "ip_id":           51105,
        "ip_frag_offset":  16384,
        "ip_ttl":          255,
        "ip_proto":        17,  # Int (6 = TCP, 17 = UDP)
        "ip_len":          222, # Not used (MTU minus 20 bytes IP header and 20 bytes TCP or 8 byte UDP header)

        # Transport layer
        "t_sport":         111,
        "t_dport":         0
    },

    "attack_vector_2" : {

        # Times and rate
        "start_time_us":     15000000,
        "end_time_us":       20000000,
        "rate_bps":          5000000000,

        # ETH layer
        "eth_src":          b'\x00\x00\x00\x00\x00\x00',
        "eth_dst":          b'\x00\x00\x00\x00\x00\x00',

        # IP layer
        "ip_src_0":          "192",
        "ip_src_1":          "168",
        "ip_src_2":          "0",
        "ip_src_3":          "5",

        "ip_dst_0":          "172",
        "ip_dst_1":          "168",
        "ip_dst_2":          "0",
        "ip_dst_3":          "100",

        "ip_id":           51105,
        "ip_frag_offset":  16384,
        "ip_ttl":          255,
        "ip_proto":        17,  # Int (6 = TCP, 17 = UDP)
        "ip_len":          222, # Not used (MTU minus 20 bytes IP header and 20 bytes TCP or 8 byte UDP header)

        # Transport layer
        "t_sport":         111,
        "t_dport":         0, 

        # Ethernet packet (to be initialized later)
        "packets_per_us":               None,
        "has_last_packet":              False,
        "size_last_packet_bytes":       None
    },

    "attack_vector_3" : {

        # Times and rate
        "start_time_us":     25000000,
        "end_time_us":       30000000,
        "rate_bps":          5000000000,

        # ETH layer
        "eth_src":          b'\x00\x00\x00\x00\x00\x00',
        "eth_dst":          b'\x00\x00\x00\x00\x00\x00',

        # IP layer
        "ip_src_0":          "192",
        "ip_src_1":          "168",
        "ip_src_2":          "0",
        "ip_src_3":          "5",

        "ip_dst_0":          "172",
        "ip_dst_1":          "168",
        "ip_dst_2":          "0",
        "ip_dst_3":          "150",

        "ip_id":           51105,
        "ip_frag_offset":  16384,
        "ip_ttl":          255,
        "ip_proto":        17,  # Int (6 = TCP, 17 = UDP)
        "ip_len":          222, # Not used (MTU minus 20 bytes IP header and 20 bytes TCP or 8 byte UDP header)

        # Transport layer
        "t_sport":         111,
        "t_dport":         0, 

        # Ethernet packet (to be initialized later)
        "packets_per_us":               None,
        "has_last_packet":              False,
        "size_last_packet_bytes":       None
    }, 

    "attack_vector_4" : {

        # Times and rate
        "start_time_us":     35000000,
        "end_time_us":       40000000,
        "rate_bps":          5000000000,

        # ETH layer
        "eth_src":          b'\x00\x00\x00\x00\x00\x00',
        "eth_dst":          b'\x00\x00\x00\x00\x00\x00',

        # IP layer
        "ip_src_0":          "192",
        "ip_src_1":          "168",
        "ip_src_2":          "0",
        "ip_src_3":          "5",

        "ip_dst_0":          "172",
        "ip_dst_1":          "168",
        "ip_dst_2":          "0",
        "ip_dst_3":          "200",

        "ip_id":           51105,
        "ip_frag_offset":  16384,
        "ip_ttl":          255,
        "ip_proto":        17,  # Int (6 = TCP, 17 = UDP)
        "ip_len":          222, # Not used (MTU minus 20 bytes IP header and 20 bytes TCP or 8 byte UDP header)

        # Transport layer
        "t_sport":         111,
        "t_dport":         0, 

        # Ethernet packet (to be initialized later)
        "packets_per_us":               None,
        "has_last_packet":              False,
        "size_last_packet_bytes":       None
    }
}