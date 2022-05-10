#######
# This script generates pcap files with a number of different traffic distributions (benign and malicious)
#######

import os, sys
import dpkt
import numpy as np
import ipaddress 

def generate_packet(distribution):

    # We first analyze if any of the features of the distribution is a dictionary instead of a fixed value. 
    # If that is the case, we need to compute a random value for that feature
    # Once we have computed the random value, we place it in the distribution dictionary, substituting the feature dictionary
    for k_distribution, v_distribution in distribution.items():

        # If one of the distribution fields is a dictionary (which means it should be randomized)
        if isinstance(v_distribution,dict):

            # We generate a new random value for that feature
            if (v_distribution["distrib"] == "normal"): 
                value = int(np.random.normal(v_distribution["mean"] , v_distribution["std_dev"]))
                while value < v_distribution["min"] or value > v_distribution["max"]:
                    value = int(np.random.normal(v_distribution["mean"], v_distribution["std_dev"]))

            # Uniform: Samples are uniformly distributed over the half-open interval [low, high) (includes low, but excludes high)
            if (v_distribution["distrib"] == "uniform"): 
                value = int(np.random.uniform(v_distribution["min"] , v_distribution["max"]))

            # We put the generated value in the original dictionary
            distribution[k_distribution] = value

    # TCP packet
    if distribution["ip_proto"] == 6:
        packet = dpkt.ethernet.Ethernet(
            src=distribution["eth_src"], 
            dst=distribution["eth_dst"], 
            type=dpkt.ethernet.ETH_TYPE_IP,
            data=dpkt.ip.IP(
                src=ipaddress.ip_address(distribution["ip_src"]).packed,
                off=distribution["ip_frag_offset"], 
                dst=ipaddress.ip_address(distribution["ip_dst"]).packed,
                p=dpkt.ip.IP_PROTO_TCP, 
                id=distribution["ip_id"], 
                ttl=distribution["ip_ttl"],
                data=dpkt.tcp.TCP(
                    dport=distribution["t_dport"], 
                    sport=distribution["t_sport"],
                    data=bytes(1000)
                )
            )
        )

    # UDP packet
    else:
        packet = dpkt.ethernet.Ethernet(
            src=distribution["eth_src"], 
            dst=distribution["eth_dst"], 
            type=dpkt.ethernet.ETH_TYPE_IP,
            data=dpkt.ip.IP(
                src=ipaddress.ip_address(distribution["ip_src"]).packed,
                off=distribution["ip_frag_offset"], 
                dst=ipaddress.ip_address(distribution["ip_dst"]).packed,
                p=dpkt.ip.IP_PROTO_UDP, 
                id=distribution["ip_id"], 
                ttl=distribution["ip_ttl"], 
                data=dpkt.udp.UDP(
                    dport=distribution["t_dport"], 
                    sport=distribution["t_sport"],
                    data=bytes(1000)
                )
            )
        )
    
    return packet

if __name__ == '__main__':

    #####
    # Configuration
    #####

    # One can use start time, end time and rate, or just number of packets (we will just use number of packets for simplicity)
    percentage_benign = 0.5  # percentage_malicious = 1 - percentage_benign
    num_packets = 10000
    #start_time = 0           # seconds
    #end_time = 10            # seconds
    #rate = 1000000000        # bps (it is approximate since we will only use packets of size ip.len)

    # Output file configuration
    output_pcap_file_name = "/mnt/fischer/albert/tofino_analysis.pcap"
    output_pcap_file = open(output_pcap_file_name, 'wb')
    pcap_writer = dpkt.pcap.Writer(output_pcap_file)

    #####
    # Traffic distributions
    #####

    traffic_distribution_benign = {

        # ETH layer
        "eth_src":          b'\x00\x00\x00\x00\x00\x00',
        "eth_dst":          b'\x00\x00\x00\x00\x00\x00',

        # IP layer
        "ip_src":          "0.0.0.0",
        "ip_dst":          "0.0.0.0",
        "ip_id": {
            "distrib":     "uniform", 
            "mean":        32500, 
            "std_dev":     5000,
            "min":         27500,
            "max":         37500
        },
        "ip_frag_offset":  0,
        "ip_ttl":          0,
        "ip_proto":        6,
        "ip_len":          0,

        # Transport layer
        "t_sport":         0,
        "t_dport":         0
    }

    traffic_distribution_malicious = {
        
        # ETH layer
        "eth_src":          b'\x00\x00\x00\x00\x00\x00',
        "eth_dst":          b'\x00\x00\x00\x00\x00\x00',

        # IP layer
        "ip_src":          "0.0.0.0",
        "ip_dst":          "0.0.0.0",
        "ip_id": {
            "distrib":     "uniform", 
            "mean":        15000, 
            "std_dev":     5000,
            "min":         10000,
            "max":         20000
        },
        "ip_frag_offset":  0,
        "ip_ttl":          0,
        "ip_proto":        6,
        "ip_len":          0,

        # Transport layer
        "t_sport":         0,
        "t_dport":         0
    }

    #####
    # Monitoring initialization
    #####

    generated_packets = []
    original_labels_packets = []

    # Monitoring of the traffic distributions
    ip_id_distrib_benign = {}
    ip_id_distrib_attack = {}

    for a in range(0, 65536):
        ip_id_distrib_benign[a] = 0
        #dport_distrib_benign[a] = 0
        ip_id_distrib_attack[a] = 0
        #dport_distrib_attack[a] = 0

    #####
    # Packet trace generation
    #####

    # We operate at a granularity of us. What we do is at each us generate the amount of packets required
    current_time_us = 0
    for i in range(num_packets):
        
        # We generate random value to define if benign or malicious
        benign_or_attack = np.random.uniform(0,1)
        benign = True

        if benign_or_attack < percentage_benign:
            packet = generate_packet(dict(traffic_distribution_benign)) # Dicts are mutable. If we don't pass a copy, it will modify the original dict
        else:
            packet = generate_packet(dict(traffic_distribution_malicious))
            benign = False

        pcap_writer.writepkt(packet, current_time_us)
        current_time_us = current_time_us + 100000
        generated_packets.append([packet.data.id])
        original_labels_packets.append(benign)

    output_pcap_file.close()
    
    # We cluster the packets generated over the period
    # We first need to convert the list to a numpy array
    array_generated_packets = np.array(generated_packets)

    # We can keep track of the generated packet distributions
    for p in range(len(array_generated_packets)):
        if (original_labels_packets[p] == True):
            ip_id_distrib_benign[array_generated_packets[p][0]] = ip_id_distrib_benign[array_generated_packets[p][0]] + 1
            #dport_distrib_benign[array_generated_packets[p][1]] = dport_distrib_benign[array_generated_packets[p][1]] + 1
        else:
            ip_id_distrib_attack[array_generated_packets[p][0]] = ip_id_distrib_attack[array_generated_packets[p][0]] + 1
            #dport_distrib_attack[array_generated_packets[p][1]] = dport_distrib_attack[array_generated_packets[p][1]] + 1

    # We also plot the generated distributions for the first period
    s = open("generated_distributions.dat", 'w')
    s.write("#    distrib_benign    distrib_attack\n")
    for line in range(0,len(ip_id_distrib_benign)):
        s.write("%s   %s   %s\n" % (line, ip_id_distrib_benign[line], ip_id_distrib_attack[line]))
    s.close()








