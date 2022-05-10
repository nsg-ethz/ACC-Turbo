carpet_bombing_vectors = {

    "cldap_attack_vector" : {

        # Times and rate
        "start_time_us":     5000000,
        "end_time_us":       25000000,
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
        "ip_dst_3":          {
                                "distrib":     "uniform", 
                                "mean":        128, 
                                "min":         0,
                                "max":         255
                            },
        "ip_id":           0,
        "ip_frag_offset":  0,
        "ip_ttl":          60,
        "ip_proto":        17,  # Int (6 = TCP, 17 = UDP)
        "ip_len":          3006, # Not used (MTU minus 20 bytes IP header and 20 bytes TCP or 8 byte UDP header)

        # Transport layer
        "t_sport":         389,
        "t_dport":         {
                                "distrib":     "uniform", 
                                "mean":        128, 
                                "min":         0,
                                "max":         255
                            }, 

        # Ethernet packet (to be initialized later)
        "packets_per_us":               None,
        "has_last_packet":              False,
        "size_last_packet_bytes":       None
    }
}