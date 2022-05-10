import dpkt
import datetime
import matplotlib
import matplotlib.pyplot as plt
import os
import multiprocessing 

matplotlib.use('tkagg')

class Cluster:
    def __init__(self):
        self.signature                  = {
            "ip" : {
                "version"               : 0,
                "hdr_len"               : 0,
                "dsfield"               : 0,
                "dsfield_dscp"          : 0,
                "dsfield_ecn"           : 0,
                "len"                   : 0,
                "id"                    : 0,
                "flags"                 : 0,
                "frag_offset"           : 0,
                "ttl"                   : 0,
                "proto"                 : 0,
                "checksum"              : 0,
                "checksum_status"       : 0,
                "src"                   : 0,
                "addr"                  : 0,
                "src_host"              : 0,
                "host"                  : 0,
                "dst"                   : 0,
                "dst_host"              : 0
            },
            "tcp" : {
                "srcport"               : 0,
                "dstport"               : 0,
                "seq"                   : 0,
                "ack"                   : 0,
                "hdr_len"               : 0,
                "flags_res"             : 0,
                "flags_ns"              : 0,
                "flags_cwr"             : 0,
                "flags_ecn"             : 0,
                "flags_urg"             : 0,
                "flags_ack"             : 0,
                "flags_push"            : 0,
                "flags_reset"           : 0,
                "flags_syn"             : 0,
                "flags_fin"             : 0,
                "window_size"           : 0,
                "checksum"              : 0,
                "urgent_pointer"        : 0            
            },
            "udp" : {
                "srcport"               : 0,
                "dstport"               : 0,
                "length"                : 0,
                "checksum"              : 0            
            }
        }
        self.statistics = {
            bytes : 0,
            packets: 0,
            time_last_packet: 0
        }

    def update_statistics(self, bytes, time):
        self.statistics[bytes] = self.statistics[bytes] + bytes
        self.statistics[packets] = self.statistics[packets] + 1
        self.statistics[time_last_packet] = time

    def compute_similarity(self, packet):
        similarity = 0
        if (self.signature["ip"]["version"]                         == packet.ip.version):          +=similarity
        if (self.signature["ip"]["hdr_len"]                         == packet.ip.hdr_len):          +=similarity
        if (self.signature["ip"]["dsfield"]                         == packet.ip.dsfield):          +=similarity
        if (self.signature["ip"]["dsfield_dscp"]                    == packet.ip.dsfield_dscp):     +=similarity
        if (self.signature["ip"]["dsfield_ecn"]                     == packet.ip.dsfield_ecn):      +=similarity
        if (self.signature["ip"]["len"]                             == packet.ip.len):              +=similarity
        if (self.signature["ip"]["id"]                              == packet.ip.id):               +=similarity
        if (self.signature["ip"]["flags_rb"]                        == packet.ip.flags_rb):         +=similarity
        if (self.signature["ip"]["flags_df"]                        == packet.ip.flags_df):         +=similarity
        if (self.signature["ip"]["flags_mf"]                        == packet.ip.flags_mf):         +=similarity
        if (self.signature["ip"]["frag_offset"]                     == packet.ip.frag_offset):      +=similarity
        if (self.signature["ip"]["ttl"]                             == packet.ip.ttl):              +=similarity
        if (self.signature["ip"]["proto"]                           == packet.ip.proto):            +=similarity
        if (self.signature["ip"]["checksum"]                        == packet.ip.checksum):         +=similarity
        if (self.signature["ip"]["checksum_status"]                 == packet.ip.checksum_status):  +=similarity
        if (self.signature["ip"]["src"]                             == packet.ip.src):              +=similarity
        if (self.signature["ip"]["addr"]                            == packet.ip.addr):             +=similarity
        if (self.signature["ip"]["src_host"]                        == packet.ip.src_host):         +=similarity
        if (self.signature["ip"]["host"]                            == packet.ip.host):             +=similarity
        if (self.signature["ip"]["dst"]                             == packet.ip.dst):              +=similarity
        if (self.signature["ip"]["dst_host"]                        == packet.ip.dst_host):         +=similarity

        if "TCP" in packet:
            if (self.signature["tcp"]["srcport"]                    == packet.tcp.srcport):         +=similarity
            if (self.signature["tcp"]["dstport"]                    == packet.tcp.dstport):         +=similarity
            if (self.signature["tcp"]["seq"]                        == packet.tcp.seq):             +=similarity
            if (self.signature["tcp"]["ack"]                        == packet.tcp.ack):             +=similarity
            if (self.signature["tcp"]["hdr_len"]                    == packet.tcp.hdr_len):         +=similarity
            if (self.signature["tcp"]["flags_res"]                  == packet.tcp.flags_res):       +=similarity
            if (self.signature["tcp"]["flags_ns"]                   == packet.tcp.flags_ns):        +=similarity
            if (self.signature["tcp"]["flags_cwr"]                  == packet.tcp.flags_cwr):       +=similarity
            if (self.signature["tcp"]["flags_ecn"]                  == packet.tcp.flags_ecn):       +=similarity
            if (self.signature["tcp"]["flags_urg"]                  == packet.tcp.flags_urg):       +=similarity
            if (self.signature["tcp"]["flags_ack"]                  == packet.tcp.flags_ack):       +=similarity
            if (self.signature["tcp"]["flags_push"]                 == packet.tcp.flags_push):      +=similarity
            if (self.signature["tcp"]["flags_reset"]                == packet.tcp.flags_reset):     +=similarity
            if (self.signature["tcp"]["flags_syn"]                  == packet.tcp.flags_syn):       +=similarity
            if (self.signature["tcp"]["flags_fin"]                  == packet.tcp.flags_fin):       +=similarity
            if (self.signature["tcp"]["window_size"]                == packet.tcp.window_size):     +=similarity
            if (self.signature["tcp"]["checksum"]                   == packet.tcp.checksum):        +=similarity
            if (self.signature["tcp"]["urgent_pointer"]             == packet.tcp.urgent_pointer):  +=similarity

        if "UDP" in packet:
            if (self.signature["udp"]["srcport"]                    == packet.udp.srcport):         +=similarity
            if (self.signature["udp"]["dstport"]                    == packet.udp.dstport):         +=similarity
            if (self.signature["udp"]["length"]                     == packet.udp.length):          +=similarity
            if (self.signature["udp"]["checksum"]                   == packet.udp.checksum):        +=similarity

class TrafficAnalyzer:


    def __init__(self, file_list, aggregation_levels, features, time_window):
        self.file_list = file_list
        self.aggregation_levels = aggregation_levels
        self.features = features
        self.time_window = time_window

    def packet_belongs_to_aggregation_level(self, buf, header_field, min, max):
        '''
        Returns true if, for this packet representation, the requested field lies between the min and the max values specified.

        Args:
            packet (dict):              The packet in pyshark format
        '''

        # We extract a representation of the packet (the headers that we accept)
        # We check whether the packet belongs to the aggregation level
        if (header_field == "ip.proto"):

            # Unpack the Ethernet frame
            eth = dpkt.ethernet.Ethernet(buf)

            # Make sure the Ethernet data contains an IP packet
            if not isinstance(eth.data, dpkt.ip.IP):
                return False

            else:
                # Now unpack the data within the Ethernet frame (the IP packet)
                ip = eth.data
                if (int(ip.p) >= min) and (int(ip.p) <= max):
                    return True
                else:
                    return False

        elif (header_field == "tcp.srcport"):

            # Unpack the Ethernet frame
            eth = dpkt.ethernet.Ethernet(buf)

            # Make sure the Ethernet data contains an IP packet
            if not isinstance(eth.data, dpkt.ip.IP):
                return False

            else:
                # Now unpack the data within the Ethernet frame (the IP packet)
                ip = eth.data
                if not isinstance(ip.data, dpkt.tcp.TCP):
                    return False
                else:
                    tcp = ip.data
                    if (int(tcp.sport) >= min) and (int(tcp.sport) <= max):
                        return True
                    else:
                        return False

        elif (header_field == "tcp.flags_syn"):

            # Unpack the Ethernet frame
            eth = dpkt.ethernet.Ethernet(buf)

            # Make sure the Ethernet data contains an IP packet
            if not isinstance(eth.data, dpkt.ip.IP):
                return False

            else:
                # Now unpack the data within the Ethernet frame (the IP packet)
                ip = eth.data
                if not isinstance(ip.data, dpkt.tcp.TCP):
                    return False
                else:
                    tcp = ip.data
                    if (tcp.flags == dpkt.tcp.TH_SYN):
                        return True
                    else:
                        return False

        elif (header_field == "udp.srcport"):

            # Unpack the Ethernet frame
            eth = dpkt.ethernet.Ethernet(buf)

            # Make sure the Ethernet data contains an IP packet
            if not isinstance(eth.data, dpkt.ip.IP):
                return False

            else:
                # Now unpack the data within the Ethernet frame (the IP packet)
                ip = eth.data
                if not isinstance(ip.data, dpkt.udp.UDP):
                    return False
                else:
                    udp = ip.data
                    if (int(udp.sport) >= min) and (int(udp.sport) <= max):
                        return True
                    else:
                        return False

    def execute(self):
        #global all_processes
        pool = multiprocessing.Pool(processes=41) # Use 41 cores only

        # We start processing the pcap files (individually)
        for file_name in self.file_list:     
            pool.apply_async(self.analyze, args=(file_name, self.aggregation_levels, self.features, self.time_window)) 
            #analyzing_process = multiprocessing.Process(target=self.analyze, args=([file_name, self.aggregation_levels, self.features, self.time_window]))
            #analyzing_process.start()
            #all_processes.append(analyzing_process)
        pool.close()
        pool.join()    

    def analyze(self, file_name, aggregation_levels, features, time_window):

        # We analyze each pcap file, reading packet by packet
        print('Started processing ' + file_name)
        f = open(file_name,'rb')
        pcap = dpkt.pcap.Reader(f)

        for timestamp, buf in pcap:
            
            # Extract the date and time
            date_time = datetime.datetime.fromtimestamp(timestamp)-datetime.timedelta(hours=5, minutes=0) # There is a difference of 5h with respect to UTC in that dataset

            # We check whether the time window has been exceeded. 
            difference = (date_time-time_axis[current_bucket]).total_seconds()

(self.packet_belongs_to_aggregation_level(buf, header, aggregation_levels[aggregation_id][header]["min"], aggregation_levels[aggregation_id][header]["max"]))





        f.close()

        # Once we have processed all the pcaps, and computed the required features, we write the results in a file
        print('Saving the results on a file...')

        # We extract the pcap aggregation_id

        if "throughput" in features: 
            for aggregation_id in aggregation_levels:
                file_id = file_name.split('/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0')[1]
                file = open(file_id + 'throughput' + aggregation_id + '.dat', 'w+')

                # For the first file, we initialize the gnuplot header
                if file_id == "":
                    file.write("#,Throughput\n")

                for line in range(0,len(throughputs[aggregation_id])):
                    file.write("%s,%s\n" % (time_axis[line], throughputs[aggregation_id][line]))
                file.close()

        if "numpackets" in features:
            for aggregation_id in aggregation_levels:
                file_id = file_name.split('/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0')[1]
                file = open(file_id + 'numpackets' + aggregation_id + '.dat', 'w+')

                # For the first file, we initialize the gnuplot header
                if file_id == "":
                    file.write("#,Num_packets\n")

                for line in range(0,len(numpackets[aggregation_id])):
                    file.write("%s,%s\n" % (time_axis[line], numpackets[aggregation_id][line]))
                file.close()       

if __name__ == '__main__':

    # We create a list with all the pcap files we want to analyze
    file_list = []

    for file_id in range(800):  
        if file_id == 0:
            file_name = '/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0'
        else:
            file_name = '/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0' + str(file_id)
        file_list.append(file_name)

    # We create a new instance of the traffic analyzer, and we start the analysis
    traffic_analyzer = TrafficAnalyzer(file_list)
    traffic_analyzer.execute()