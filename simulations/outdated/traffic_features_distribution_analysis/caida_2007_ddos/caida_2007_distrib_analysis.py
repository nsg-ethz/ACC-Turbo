from scapy.all import *
import dpkt
import ipaddress

TH_FIN = 0b1
TH_SYN = 0b10
TH_RST = 0b100
TH_PUSH = 0b1000
TH_ACK = 0b10000
TH_URG = 0b100000
TH_ECE = 0b1000000
TH_CWR = 0b10000000

def ipv6_to_ipv4(ipv6):
    hashed = hash(ipv6) & 0xfffffff
    ip = ipaddress.IPv4Address(hashed)
    return ip.compressed


if __name__ == '__main__':  # Main: Uses SCAPY to read pcap, DPKT to write

    # We create a list for each of the distributions, where we will append all the values that we extract
    ip_len_distrib = {}
    ip_id_distrib = {}
    ip_frag_offset_distrib = {}
    ip_ttl_distrib = {}
    ip_proto_distrib = {}
    ip_src0_distrib = {}
    ip_src1_distrib = {}
    ip_src2_distrib = {}
    ip_src3_distrib = {}
    ip_dst0_distrib = {}
    ip_dst1_distrib = {}
    ip_dst2_distrib = {}
    ip_dst3_distrib = {}
    t_sport_distrib = {}
    t_dport_distrib = {}

    for a in range(0, 65536):
        ip_len_distrib[a] = 0
        ip_id_distrib[a] = 0
        t_sport_distrib[a] = 0
        t_dport_distrib[a] = 0

    for b in range(0, 8192):
        ip_frag_offset_distrib[b] = 0

    for c in range(0, 256):
        ip_ttl_distrib[c] = 0
        ip_proto_distrib[c] = 0

        ip_src0_distrib[c] = 0
        ip_src1_distrib[c] = 0
        ip_src2_distrib[c] = 0
        ip_src3_distrib[c] = 0

        ip_dst0_distrib[c] = 0
        ip_dst1_distrib[c] = 0
        ip_dst2_distrib[c] = 0
        ip_dst3_distrib[c] = 0

    # We clean the origin pcap (fixing possible broken packets)
    #os.system('pcapfix /mnt/fischer/albert/equinix-nyc.dirA.20180315.pcap' + input_file_name)
    #os.remove(output_file)

    # We make sure the format is pcap and not pcapng
    #os.system('editcap -F libpcap fixed_' + output_file + ' ../netbench_ddos/pcap/input_netbench.pcap')

    # How long do we want to read the pcap for
    start_time_us = (0)*1000000 # Between brackets the value in seconds             
    end_time_us = (3600)*1000000

    # Setup for pcap reading
    first_packet = True
    default_packet_offset = 0

    IP_LEN = 20
    IPv6_LEN = 40
    TCP_LEN = 14
    UDP_LEN = 8

    # We create a list with all the pcap files we want to analyze
    input_file_list = ["/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_134936.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_135436.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_135936.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_140436.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_140936.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_141436.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_141936.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_142436.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_142936.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_143436.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_143936.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_144436.pcap.gz",
                       "/mnt/fischer/albert/caida_ddos_2007/ddostrace.to-victim.20070804_144936.pcap.gz"]

    for input_file_name in input_file_list:

        # Input file configuration
        print('Started reading ' + input_file_name)
        pcap_reader = RawPcapReader(input_file_name)

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
                if current_time_us < start_time_us:
                    print("Skipped packet " + str(current_time_us))
                    continue # We skip that iteration

                if current_time_us > end_time_us:
                    print("Stop analysis " + str(current_time_us))
                    break # We stop reading this file
                    break # We stop reading other files

                # Extract packet information
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
                    
                    read_ip_src0 = ip_header[8]
                    read_ip_src1 = ip_header[9]
                    read_ip_src2 = ip_header[10]
                    read_ip_src3 = ip_header[11]

                    read_ip_dst0 = ip_header[12]
                    read_ip_dst1 = ip_header[13]
                    read_ip_dst2 = ip_header[14]
                    read_ip_dst3 = ip_header[15]

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

                    read_ip_src0 = ip_src_addr.split(".")[0]
                    read_ip_src1 = ip_src_addr.split(".")[1]
                    read_ip_src2 = ip_src_addr.split(".")[2]
                    read_ip_src3 = ip_src_addr.split(".")[3]

                    read_ip_dst0 = ip_dst_addr.split(".")[0]
                    read_ip_dst1 = ip_dst_addr.split(".")[1]
                    read_ip_dst2 = ip_dst_addr.split(".")[2]
                    read_ip_dst3 = ip_dst_addr.split(".")[3]

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

                # Add extracted values to the distribution

                ip_len_distrib[int(read_ip_len)]                   = ip_len_distrib[int(read_ip_len)] + 1
                ip_id_distrib[int(read_ip_id)]                      = ip_id_distrib[int(read_ip_id)] + 1
                ip_frag_offset_distrib[int(read_ip_frag_offset)]    = ip_frag_offset_distrib[int(read_ip_frag_offset)] + 1
                ip_ttl_distrib[int(read_ip_ttl)]                    = ip_ttl_distrib[int(read_ip_ttl)] + 1

                ip_proto_distrib[int(read_ip_proto)]                = ip_proto_distrib[int(read_ip_proto)] + 1

                ip_src0_distrib[int(read_ip_src0)]                  = ip_src0_distrib[int(read_ip_src0)] + 1
                ip_src1_distrib[int(read_ip_src1)]                  = ip_src1_distrib[int(read_ip_src1)] + 1
                ip_src2_distrib[int(read_ip_src2)]                  = ip_src2_distrib[int(read_ip_src2)] + 1
                ip_src3_distrib[int(read_ip_src3)]                  = ip_src3_distrib[int(read_ip_src3)] + 1

                ip_dst0_distrib[int(read_ip_dst0)]                  = ip_dst0_distrib[int(read_ip_dst0)] + 1
                ip_dst1_distrib[int(read_ip_dst1)]                  = ip_dst1_distrib[int(read_ip_dst1)] + 1
                ip_dst2_distrib[int(read_ip_dst2)]                  = ip_dst2_distrib[int(read_ip_dst2)] + 1
                ip_dst3_distrib[int(read_ip_dst3)]                  = ip_dst3_distrib[int(read_ip_dst3)] + 1

                t_sport_distrib[int(read_t_sport)]                  = t_sport_distrib[int(read_t_sport)] + 1
                t_dport_distrib[int(read_t_dport)]                  = t_dport_distrib[int(read_t_dport)] + 1

            except Exception:
                    # Note from Edgar: If this prints something just ingore it i left it for debugging, but it should happen almost never
                    import traceback
                    traceback.print_exc()
                    break 

        pcap_reader.close()

    # Finally, we plot the resulting distribution
    w = open("caida_2007_results/ip_len_distrib.dat", 'w')
    w.write("#    ip_len_distrib\n")
    for line in range(0,len(ip_len_distrib)):
        w.write("%s   %s\n" % (line, ip_len_distrib[line]))
    w.close()

    w = open("caida_2007_results/ip_id_distrib.dat", 'w')
    w.write("#    ip_id_distrib\n")
    for line in range(0,len(ip_id_distrib)):
        w.write("%s   %s\n" % (line, ip_id_distrib[line]))
    w.close()

    w = open("caida_2007_results/ip_frag_offset_distrib.dat", 'w')
    w.write("#    ip_frag_offset_distrib\n")
    for line in range(0,len(ip_frag_offset_distrib)):
        w.write("%s   %s\n" % (line, ip_frag_offset_distrib[line]))
    w.close()

    w = open("caida_2007_results/ip_ttl_distrib.dat", 'w')
    w.write("#    ip_ttl_distrib\n")
    for line in range(0,len(ip_ttl_distrib)):
        w.write("%s   %s\n" % (line, ip_ttl_distrib[line]))
    w.close()

    w = open("caida_2007_results/ip_proto_distrib.dat", 'w')
    w.write("#    ip_proto_distrib\n")
    for line in range(0,len(ip_proto_distrib)):
        w.write("%s   %s\n" % (line, ip_proto_distrib[line]))
    w.close()

    w = open("caida_2007_results/ip_src.dat", 'w')
    w.write("#    ip_src0    ip_src1    ip_src2    ip_src3\n")
    for line in range(0,len(ip_src0_distrib)):
        w.write("%s   %s   %s   %s   %s\n" % (line, ip_src0_distrib[line], ip_src1_distrib[line], ip_src2_distrib[line], ip_src3_distrib[line]))
    w.close()

    w = open("caida_2007_results/ip_dst.dat", 'w')
    w.write("#    ip_dst0    ip_dst1    ip_dst2    ip_dst3\n")
    for line in range(0,len(ip_dst0_distrib)):
        w.write("%s   %s   %s   %s   %s\n" % (line, ip_dst0_distrib[line], ip_dst1_distrib[line], ip_dst2_distrib[line], ip_dst3_distrib[line]))
    w.close()

    w = open("caida_2007_results/t_ports.dat", 'w')
    w.write("#    t_sport_distrib    t_dport_distrib\n")
    for line in range(0,len(t_sport_distrib)):
        w.write("%s   %s   %s\n" % (line, t_sport_distrib[line], t_dport_distrib[line]))
    w.close()
