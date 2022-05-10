#######
# This script takes baseline pcap files and generates attacks on top
#######

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

    if len(sys.argv) != 18: 
        print("The number of arguments required is 18")
    else:

        # We create a list with all the pcap files we want to analyze
        input_file_name = sys.argv[1]

        # We clean the origin pcap (fixing possible broken packets)
        #os.system('pcapfix /mnt/fischer/albert/equinix-nyc.dirA.20180315.pcap' + input_file_name)
        #os.remove(output_file)

        # We make sure the format is pcap and not pcapng
        #os.system('editcap -F libpcap fixed_' + output_file + ' ../netbench_ddos/pcap/input_netbench.pcap')

        # Input file configuration
        print('Started reading ' + input_file_name)
        pcap_reader = RawPcapReader(input_file_name)

        # Output file configuration
        output_file_baseline_name = sys.argv[2]
        if output_file_baseline_name != 'none':
            output_file_baseline = open(output_file_baseline_name, 'wb')
            pcap_writer_baseline = dpkt.pcap.Writer(output_file_baseline)

        output_file_attack_name = sys.argv[3]
        output_file_attack = open(output_file_attack_name, 'wb')
        pcap_writer_atack = dpkt.pcap.Writer(output_file_attack)

        # Output pcap duration
        baseline_start_time_us = (float(sys.argv[4]))*1000000 # Between brackets the value in seconds             
        baseline_end_time_us = (float(sys.argv[5]))*1000000             

        # Attack configuration
        attack_start_time_us = (float(sys.argv[6]))*1000000
        attack_end_time_us = (float(sys.argv[7]))*1000000
        attack_rate_bps = (float(sys.argv[8]))*1000000000 # sys.argv[8] in Gbps

        # Single flow option
        ip_src_addr = sys.argv[9]
        ip_dst_addr = sys.argv[10]
        attack_ip_src_addr = ipaddress.ip_address(ip_src_addr).packed
        attack_ip_dst_addr = ipaddress.ip_address(ip_dst_addr).packed

        attack_ip_id = int(sys.argv[11])
        attack_ip_frag_offset = int(sys.argv[12])
        attack_ip_ttl = int(sys.argv[13])
        attack_ip_proto = int(sys.argv[14])
        attack_ip_len = int(sys.argv[15])  # In bytes: MTU (1500B) minus 20B IP header and 20B TCP or 8B UDP header
        attack_t_sport = int(sys.argv[16])
        attack_t_dport = int(sys.argv[17])

        # TCP attack (maximum segment size packets):
        if attack_ip_proto == 6:
            ethernet_attack_packet = dpkt.ethernet.Ethernet(
                src=b'\x00\x00\x00\x00\x00\x00', 
                dst=b'\x00\x00\x00\x00\x00\x00', 
                type=dpkt.ethernet.ETH_TYPE_IP,
                data=dpkt.ip.IP(
                    src=attack_ip_src_addr,
                    off=attack_ip_frag_offset, 
                    dst=attack_ip_dst_addr, 
                    p=dpkt.ip.IP_PROTO_TCP, 
                    id=attack_ip_id, 
                    ttl=attack_ip_ttl,
                    data=dpkt.tcp.TCP(
                        dport=attack_t_dport, 
                        sport=attack_t_sport,
                        data=bytes(1460)
                    )
                )
            )

        # UDP attack
        else:
            ethernet_attack_packet = dpkt.ethernet.Ethernet(
                src=b'\x00\x00\x00\x00\x00\x00', 
                dst=b'\x00\x00\x00\x00\x00\x00', 
                type=dpkt.ethernet.ETH_TYPE_IP,
                data=dpkt.ip.IP(
                    src=attack_ip_src_addr,
                    off=attack_ip_frag_offset, 
                    dst=attack_ip_dst_addr, 
                    p=dpkt.ip.IP_PROTO_UDP, 
                    id=attack_ip_id, 
                    ttl=attack_ip_ttl, 
                    data=dpkt.udp.UDP(
                        dport=attack_t_dport, 
                        sport=attack_t_sport,
                        data=bytes(1472)
                    )
                )
            )

        packet_size_bits = int(ethernet_attack_packet.data.len)*8
        packets_per_us = int((attack_rate_bps/1000000)/packet_size_bits) # number of (full) MTU packets to be sent in a us
        size_last_packet_bytes = math.ceil(((attack_rate_bps/1000000) - (packets_per_us*packet_size_bits))/8) # size of the last packet to sendß
        last_packet = False

        # We will have to create the last packet of each us (which will not be MTU size)
        if (size_last_packet_bytes > 20): # If it is more than a packet header size, otherwise makes no sense to create a new packet for just that
            
            last_packet = True

            # TCP attack:
            if attack_ip_proto == 6:
                ethernet_attack_packet_last = dpkt.ethernet.Ethernet(
                    src=b'\x00\x00\x00\x00\x00\x00', 
                    dst=b'\x00\x00\x00\x00\x00\x00', 
                    type=dpkt.ethernet.ETH_TYPE_IP,
                    data=dpkt.ip.IP(
                        src=attack_ip_src_addr,
                        off=attack_ip_frag_offset, 
                        dst=attack_ip_dst_addr, 
                        p=dpkt.ip.IP_PROTO_TCP, 
                        id=attack_ip_id, 
                        ttl=attack_ip_ttl,
                        data=dpkt.tcp.TCP(
                            dport=attack_t_dport, 
                            sport=attack_t_sport,
                            data=bytes(size_last_packet_bytes - 20 - 20)
                        )
                    )
                )

            # UDP attack
            else:
                ethernet_attack_packet_last = dpkt.ethernet.Ethernet(
                    src=b'\x00\x00\x00\x00\x00\x00', 
                    dst=b'\x00\x00\x00\x00\x00\x00', 
                    type=dpkt.ethernet.ETH_TYPE_IP,
                    data=dpkt.ip.IP(
                        src=attack_ip_src_addr,
                        off=attack_ip_frag_offset, 
                        dst=attack_ip_dst_addr, 
                        p=dpkt.ip.IP_PROTO_UDP, 
                        id=attack_ip_id, 
                        ttl=attack_ip_ttl, 
                        data=dpkt.udp.UDP(
                            dport=attack_t_dport, 
                            sport=attack_t_sport,
                            data=bytes(size_last_packet_bytes - 20 - 8)
                        )
                    )
                )

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

                # Add the attack packets
                if current_time_us >= attack_start_time_us and current_time_us <= attack_end_time_us:

                    # We need to fill with attack packets all the micro seconds between attack_start_time and current_time_us (before writing the current packet)
                    for time in range(int(attack_start_time_us), current_time_us):

                        
                        # We add all the MTU packets for the iteration
                        for iteration in range (packets_per_us):
                            pcap_writer_atack.writepkt(ethernet_attack_packet, time)

                        # Plus an extra packet (non-MTU) if needed
                        if last_packet:
                            pcap_writer_atack.writepkt(ethernet_attack_packet_last, time)

                    attack_start_time_us = current_time_us # We update the cursor of the attack to the current time        
                    
                # Write the read packet to an output pcap (converting the data to dpkt)
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
                    pcap_writer_baseline.writepkt(read_packet, current_time_us)
                pcap_writer_atack.writepkt(read_packet, current_time_us)



            except Exception:
                    # Note from Edgar: If this prints something just ingore it i left it for debugging, but it should happen almost never
                    import traceback
                    traceback.print_exc()
                    break 

        if output_file_baseline_name != 'none':
            output_file_baseline.close()
        output_file_attack.close()

