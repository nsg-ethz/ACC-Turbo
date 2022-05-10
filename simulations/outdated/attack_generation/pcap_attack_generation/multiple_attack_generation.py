#######
# This script takes baseline pcap files and generates attacks on top
#######

from scapy.all import *
import dpkt
import ipaddress
import numpy as np

from morphing_attack_dict import morphing_attack_vectors
from carpet_bombing_dict import carpet_bombing_vectors

TH_FIN = 0b1
TH_SYN = 0b10
TH_RST = 0b100
TH_PUSH = 0b1000
TH_ACK = 0b10000
TH_URG = 0b100000
TH_ECE = 0b1000000
TH_CWR = 0b10000000

SRC_PORT_NTP        = 123
SRC_PORT_SSDP       = 1900
SRC_PORT_IP_FRAG    = 0
SRC_PORT_DNS        = 53
SRC_PORT_SRCDS      = 27015
SRC_PORT_Chargen    = 19
SRC_PORT_CallofDuty = 20800
SRC_PORT_SNMP       = 161
SRC_PORT_CLDAP      = 389
SRC_PORT_Sunrpc     = 111
SRC_PORT_Netbios    = 137
SRC_PORT_HTTP       = 80
SRC_PORT_SRCDS      = 27005
SRC_PORT_RIP        = 520

def ipv6_to_ipv4(ipv6):
    hashed = hash(ipv6) & 0xfffffff
    ip = ipaddress.IPv4Address(hashed)
    return ip.compressed


def generate_packet(attack_vector, is_last_packet):

    # We first analyze if any of the features of the attack_vector is a dictionary instead of a fixed value. 
    # If that is the case, we need to compute a random value for that feature
    # Once we have computed the random value, we place it in the attack_vector dictionary, substituting the feature dictionary
    for k, v in attack_vector.items():

        # If one of the attack_vector fields is a dictionary (which means it should be randomized)
        if isinstance(v, dict):

            # We generate a new random value for that feature
            if (v["distrib"] == "normal"): 
                generated_value = int(np.random.normal(v["mean"] , v["std_dev"]))
                while (generated_value < v["min"] or generated_value > v["max"]):
                    result = int(np.random.normal(v["mean"], v["std_dev"]))

            # Uniform: Samples are uniformly distributed over the half-open interval [low, high) (includes low, but excludes high)
            if (v["distrib"] == "uniform"): 
                generated_value = int(np.random.uniform(v["min"] , v["max"]))

            # We put the generated_value in the original dictionary
            attack_vector[k] = generated_value

    # We create the ethernet packets for each attack vector
    ip_src_addr = str(attack_vector["ip_src_0"]) + "." + str(attack_vector["ip_src_1"]) + "." + str(attack_vector["ip_src_2"]) + "." + str(attack_vector["ip_src_3"])
    ip_dst_addr = str(attack_vector["ip_dst_0"]) + "." + str(attack_vector["ip_dst_1"]) + "." + str(attack_vector["ip_dst_2"]) + "." + str(attack_vector["ip_dst_3"])

    # If is not last packet, we create MTU packet
    if (not is_last_packet):

        # TCP attack (maximum segment size packets):
        if attack_vector["ip_proto"] == 6:

            generated_packet = dpkt.ethernet.Ethernet(
                src  = attack_vector["eth_src"], 
                dst  = attack_vector["eth_dst"], 
                type = dpkt.ethernet.ETH_TYPE_IP,
                data = dpkt.ip.IP(
                    src  = ipaddress.ip_address(ip_src_addr).packed,
                    off  = attack_vector["ip_frag_offset"], 
                    dst  = ipaddress.ip_address(ip_dst_addr).packed, 
                    p    = dpkt.ip.IP_PROTO_TCP, 
                    id   = attack_vector["ip_id"], 
                    ttl  = attack_vector["ip_ttl"],
                    data = dpkt.tcp.TCP(
                        dport = attack_vector["t_dport"], 
                        sport = attack_vector["t_sport"],
                        data  = bytes(1460)
                    )
                )
            )

        # UDP attack
        else:

            generated_packet = dpkt.ethernet.Ethernet(
                src  = attack_vector["eth_src"], 
                dst  = attack_vector["eth_dst"], 
                type = dpkt.ethernet.ETH_TYPE_IP,
                data = dpkt.ip.IP(
                    src  = ipaddress.ip_address(ip_src_addr).packed,
                    off  = attack_vector["ip_frag_offset"], 
                    dst  = ipaddress.ip_address(ip_dst_addr).packed, 
                    p    = dpkt.ip.IP_PROTO_UDP,
                    id   = attack_vector["ip_id"], 
                    ttl  = attack_vector["ip_ttl"], 
                    data = dpkt.udp.UDP(
                        dport = attack_vector["t_dport"], 
                        sport = attack_vector["t_sport"], 
                        data  = bytes(1472)
                    )
                )
            )

    # If is last packet
    else:

        # TCP attack:
        if attack_vector["ip_proto"] == 6:

            generated_packet = dpkt.ethernet.Ethernet(
                src  = attack_vector["eth_src"],
                dst  = attack_vector["eth_dst"],
                type = dpkt.ethernet.ETH_TYPE_IP,
                data = dpkt.ip.IP(
                    src  = ipaddress.ip_address(ip_src_addr).packed,
                    off  = attack_vector["ip_frag_offset"], 
                    dst  = ipaddress.ip_address(ip_dst_addr).packed,
                    p    = dpkt.ip.IP_PROTO_TCP,
                    id   = attack_vector["ip_id"], 
                    ttl  = attack_vector["ip_ttl"], 
                    data = dpkt.tcp.TCP(
                        dport = attack_vector["t_dport"],
                        sport = attack_vector["t_sport"],
                        data  = bytes(attack_vector["size_last_packet_bytes"] - 20 - 20)
                    )
                )
            )

        # UDP attack
        else:

            generated_packet = dpkt.ethernet.Ethernet(
                src  = attack_vector["eth_src"],
                dst  = attack_vector["eth_dst"],
                type = dpkt.ethernet.ETH_TYPE_IP,
                data = dpkt.ip.IP(
                    src  = ipaddress.ip_address(ip_src_addr).packed,
                    off  = attack_vector["ip_frag_offset"], 
                    dst  = ipaddress.ip_address(ip_dst_addr).packed,
                    p    = dpkt.ip.IP_PROTO_UDP,
                    id   = attack_vector["ip_id"], 
                    ttl  = attack_vector["ip_ttl"], 
                    data = dpkt.udp.UDP(
                        dport = attack_vector["t_dport"],
                        sport = attack_vector["t_sport"],
                        data = bytes(attack_vector["size_last_packet_bytes"] - 20 - 8)
                    )
                )
            )

    return generated_packet


if __name__ == '__main__':  # Main: Uses SCAPY to read pcap, DPKT to write

    # We create a list with all the pcap files we want to analyze
    input_file_name = '/mnt/fischer/thomas/traces/caida/2018/equinix-nyc/equinix-nyc.dirB.20180315.pcap'

    # We clean the origin pcap (fixing possible broken packets)
    #os.system('pcapfix /mnt/fischer/albert/equinix-nyc.dirA.20180315.pcap' + input_file_name)
    #os.remove(output_file)

    # We make sure the format is pcap and not pcapng
    #os.system('editcap -F libpcap fixed_' + output_file + ' ../netbench_ddos/pcap/input_netbench.pcap')

    # Input file configuration
    print('Started generating an attack on top of ' + input_file_name)
    pcap_reader = RawPcapReader(input_file_name)

    # Output file configuration
    output_file_baseline_name = '/home/albert/DDoS-AID_private/code/pcaps/morphing_attack/baseline.pcap'
    if output_file_baseline_name != 'none':
        output_file_baseline = open(output_file_baseline_name, 'wb')
        pcap_writer_baseline = dpkt.pcap.Writer(output_file_baseline)

    output_file_attack_name = '/home/albert/DDoS-AID_private/code/pcaps/morphing_attack/attack.pcap'
    output_file_attack      = open(output_file_attack_name, 'wb')
    pcap_writer_atack       = dpkt.pcap.Writer(output_file_attack)

    # Output pcap duration
    baseline_start_time_us  = (0)*1000000 # Between brackets the value in seconds             
    baseline_end_time_us    = (45)*1000000             

    #####
    # Attacks configurations
    #####
    attack_vectors = morphing_attack_vectors
    #attack_vectors = carpet_bombing_vectors

    # We check whether we will need a last packet, and the size of that last packet (sizes of the rest of packets is MTU)
    ## Understand data.len and then substitute by hardcoded value
    for attack_vector in attack_vectors:
        test_packet = generate_packet(dict(attack_vectors[attack_vector]), False) # Dicts are mutable. If we don't pass a copy, it will modify the original dict
        packet_size_bits = int(test_packet.data.len)*8
        
        attack_vectors[attack_vector]["packets_per_us"] = int((attack_vectors[attack_vector]["rate_bps"]/1000000)/packet_size_bits) # number of (full) MTU packets to be sent in a us
        attack_vectors[attack_vector]["size_last_packet_bytes"] = math.ceil(((attack_vectors[attack_vector]["rate_bps"]/1000000) - (attack_vectors[attack_vector]["packets_per_us"]*packet_size_bits))/8) # size of the last packet to send
        
        if (attack_vectors[attack_vector]["size_last_packet_bytes"] > 20): # If it is more than a packet header size, otherwise makes no sense to create a new packet for just that
            attack_vectors[attack_vector]["has_last_packet"] = True

    # Setup for pcap reading
    first_packet = True
    default_packet_offset = 0

    IP_LEN = 20
    IPv6_LEN = 40
    TCP_LEN = 14
    UDP_LEN = 8

    # Start processing the pcap
    for packet, meta in pcap_reader:
        try:

            if first_packet:
                first_packet = False

                # We check in the metadata of the first packet, whether the trace is pcap or pcapng
                if hasattr(meta, 'usec'):
                    pcap_format = "pcap"
                    link_type = pcap_reader.linktype
                elif hasattr(meta, 'tshigh'):
                    pcap_format = "pcapng"
                    link_type = meta.linktype

                # We also check in the first packet the link type
                if link_type == DLT_EN10MB:
                    default_packet_offset += 14
                elif link_type == DLT_RAW_ALT:
                    default_packet_offset += 0
                elif link_type == DLT_PPP:
                    default_packet_offset += 2

                # We then extract the time and date of the first packet
                pcap_format = "pcap"
                timestamp_us = 0

                if pcap_format == "pcap":
                    timestamp_us = meta.sec*1000000 + meta.usec
                elif pcap_format == "pcapng":
                    timestamp_us = (((meta.tshigh << 32) | meta.tslow) / float(meta.tsresol))*1000000

                # We initialize the timer of the pcap based on the extracted time
                origin_timestamp_us = timestamp_us
                current_time_us = 0

            else: 

                # We extract the time and date   
                if pcap_format == "pcap":
                    timestamp_us = meta.sec*1000000 + meta.usec
                elif pcap_format == "pcapng":
                    timestamp_us = (((meta.tshigh << 32) | meta.tslow) / float(meta.tsresol))*1000000

                # We set the timer based on the extracted time and the origin time of the pcap
                current_time_us = timestamp_us - origin_timestamp_us
                        
            # We only analyze the indicated fragment
            if current_time_us < baseline_start_time_us:
                print("Skipped packet " + str(current_time_us))
                continue # We skip that iteration

            if current_time_us > baseline_end_time_us:
                print("Stop analysis " + str(current_time_us))
                break # We stop analyzing

            ####
            # Add the attack packets
            ####

            for attack_vector in attack_vectors:

                if current_time_us >= attack_vectors[attack_vector]["start_time_us"] and current_time_us <= attack_vectors[attack_vector]["end_time_us"]:

                    # We need to fill with attack packets all the micro seconds between attack_start_time and current_time_us (before writing the current packet)
                    for time in range(int(attack_vectors[attack_vector]["start_time_us"]), current_time_us):
                        
                        # We add all the MTU packets for the iteration
                        for iteration in range (attack_vectors[attack_vector]["packets_per_us"]):
                            new_packet = generate_packet(dict(attack_vectors[attack_vector]), False) # Dicts are mutable. If we don't pass a copy, it will modify the original dict
                            pcap_writer_atack.writepkt(new_packet, float(time/1000000)) # ts of writepkt needs to be in seconds

                        # Plus an extra packet (non-MTU) if needed
                        if attack_vectors[attack_vector]["has_last_packet"]:
                            new_last_packet = generate_packet(dict(attack_vectors[attack_vector]), True) # Dicts are mutable. If we don't pass a copy, it will modify the original dict
                            pcap_writer_atack.writepkt(new_last_packet, float(time/1000000)) # ts of writepkt needs to be in seconds

                    attack_vectors[attack_vector]["start_time_us"] = current_time_us # We update the cursor of the attack to the current time        
            
            ####
            # Write the read packet to an output pcap (converting the data to dpkt)
            ####

            # Remove bytes until IP layer, based on the link-type obtained from the first packet
            packet = packet[default_packet_offset:]

            # IP-Layer Parsing
            packet_offset = 0
            version = struct.unpack("!B", bytes([packet[0]]))
            ip_version = version[0] >> 4

            # IP Version 4
            if ip_version == 4:

                # Filter the packet if it does not even have 20+14 bytes
                if len(packet) < (IP_LEN + TCP_LEN):
                    continue

                # Parse IP header
                ip_header = struct.unpack("!BBHHHBBHBBBBBBBB", packet[:IP_LEN])

                ip_header_length = (ip_header[0] & 0x0f) * 4
                packet_offset += ip_header_length

                # Extract IP fields
                read_ip_len = ip_header[2]
                read_ip_proto = ip_header[6]

                read_ip_ttl = ip_header[5]
                read_ip_id = ip_header[3]
                
                flags_and_fragoffset = ip_header[4]
                read_ip_frag_offset = flags_and_fragoffset & 0x0fff

                # Format IP addresses
                ip_src_addr = '{0:d}.{1:d}.{2:d}.{3:d}'.format(ip_header[8],
                                                        ip_header[9],
                                                        ip_header[10],
                                                        ip_header[11])
                ip_dst_addr = '{0:d}.{1:d}.{2:d}.{3:d}'.format(ip_header[12],
                                                        ip_header[13],
                                                        ip_header[14],
                                                        ip_header[15])
                read_ip_src_addr = ipaddress.ip_address(ip_src_addr).packed
                read_ip_dst_addr = ipaddress.ip_address(ip_dst_addr).packed

            # IP Version 6
            elif ip_version == 6:

                # Filter the packet if it does not even have 20+14 bytes
                if len(packet) < (IPv6_LEN + TCP_LEN):
                    continue

                # Parse IP header
                ip_header = struct.unpack("!LHBBQQQQ", packet[:40])
                ip_header_length = 40
                packet_offset += ip_header_length

                # Extract IP fields
                read_ip_len = 40 + ip_header[1]
                read_ip_proto = ip_header[2]
                read_ip_ttl = ip_header[3] # hop limit
                read_ip_frag_offset = 0
                read_ip_id = 0

                # Format IP addresses
                ip_src_addr = ipv6_to_ipv4(ip_header[4] << 64 | ip_header[5])
                ip_dst_addr = ipv6_to_ipv4(ip_header[6] << 64 | ip_header[7])

                read_ip_src_addr = ipaddress.ip_address(ip_src_addr).packed
                read_ip_dst_addr = ipaddress.ip_address(ip_dst_addr).packed

            else:
                continue

            # Parse TCP header
            if read_ip_proto == 6:
                tcp_header = struct.unpack("!HHLLBB", packet[packet_offset:packet_offset+TCP_LEN])
                
                # Extract TCP fields
                read_t_sport = tcp_header[0]
                read_t_dport = tcp_header[1]
                read_t_pkt_seq = tcp_header[2]
                tcp_header_length = ((tcp_header[4] & 0xf0) >> 4) * 4
                read_t_payload_length = read_ip_len - ip_header_length - TCP_LEN

            # Parse UDP header
            elif read_ip_proto == 17:
                udp_header = struct.unpack("!HHHH", packet[packet_offset:packet_offset+UDP_LEN])
                
                # Extract UDP fields
                read_t_sport = udp_header[0]
                read_t_dport = udp_header[1]
                read_t_length = udp_header[2]
                read_t_checksum = udp_header[3]
                read_t_payload_length = read_ip_len - ip_header_length - UDP_LEN

            else:
                continue

            # Generate the transport layer frame with extracted information
            if read_ip_proto == 6:
                read_t_data=dpkt.tcp.TCP(
                    dport=read_t_dport, 
                    sport=read_t_sport,
                    data=bytes(read_t_payload_length)
                )

            elif read_ip_proto == 17:
                read_t_data=dpkt.udp.UDP(
                    dport=read_t_dport, 
                    sport=read_t_sport,
                    data=bytes(read_t_payload_length)
                )

            else:
                continue

            # Generate the ethernet frame in dpkt format
            read_packet = dpkt.ethernet.Ethernet(
                src = b'\x00\x00\x00\x00\x00\x00', 
                dst = b'\x00\x00\x00\x00\x00\x00', 
                type = dpkt.ethernet.ETH_TYPE_IP,
                data = dpkt.ip.IP(
                    src = read_ip_src_addr,
                    off = read_ip_frag_offset, 
                    dst = read_ip_dst_addr, 
                    p = read_ip_proto, 
                    id = read_ip_id, 
                    ttl = read_ip_ttl,
                    data = read_t_data
                )
            )
            
            # Write it to the output pcap (dpkt-style)
            if output_file_baseline_name != 'none':
                pcap_writer_baseline.writepkt(read_packet, float(current_time_us/1000000)) # ts of writepkt needs to be in seconds
            pcap_writer_atack.writepkt(read_packet, float(current_time_us/1000000)) # ts of writepkt needs to be in seconds

        except Exception:
                # Note from Edgar: If this prints something just ingore it i left it for debugging, but it should happen almost never
                import traceback
                traceback.print_exc()
                break

    if output_file_baseline_name != 'none':
        output_file_baseline.close()
    output_file_attack.close()

