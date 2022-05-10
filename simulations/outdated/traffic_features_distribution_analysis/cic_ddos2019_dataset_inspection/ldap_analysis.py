import dpkt
import datetime
import matplotlib
import matplotlib.pyplot as plt
import os
import multiprocessing 
import socket

matplotlib.use('tkagg')

class TrafficAnalyzer():
    '''
    The TrafficAnalyzer object is in charge of processing pcap files and extract useful information about the traffic characteristics.

    Args:

    Attributes:

    '''

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

        elif (header_field == "udp.sport"):

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

        elif (header_field == "udp.dport"):

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
                    if (int(udp.dport) >= min) and (int(udp.dport) <= max):
                        return True
                    else:
                        return False

    def execute(self):
        pool = multiprocessing.Pool(processes=48) # Use 41 cores only

        # We start processing the pcap files (individually)
        for file_name in self.file_list:     
            #self.analyze(file_name, self.aggregation_levels, self.features, self.time_window)
            pool.apply_async(self.analyze, args=(file_name, self.aggregation_levels, self.features, self.time_window)) 
        pool.close()
        pool.join()    

    def analyze(self, file_name, aggregation_levels, features, time_window):
        '''
        Reads the pcap file, and extracts the specificated features, on the defined aggregation_levels

        Args:
            file_name (string):             Path where the pcap file is located.
            aggregation_levels(dict):       Each entry contains a different traffic aggregation-level (ranges).
            features(list):                 Features that need to be computed for each traffic segment (strings).
            time_window(integer):           Width of the time window used to scan the pcaps (seconds).
        '''

        # We first initialize the features
        if "throughput" in features:
            throughputs = {}
            for aggregation_id in aggregation_levels:
                throughputs[aggregation_id] = {}
                throughputs[aggregation_id][0] = 0

        if "numpackets" in features:
            numpackets = {}
            for aggregation_id in aggregation_levels:
                numpackets[aggregation_id] = {}
                numpackets[aggregation_id][0] = 0

        # We initialize the main variables for the analysis
        is_first_packet = True
        current_bucket = 0
        time_axis = {}
        time_axis[0] = None

        # We analyze each pcap file, reading packet by packet
        print('Started processing ' + file_name)
        f = open(file_name,'rb')
        pcap = dpkt.pcap.Reader(f)
        list_flows = []

        for timestamp, buf in pcap:
            
            # Extract the date and time
            date_time = datetime.datetime.fromtimestamp(timestamp)-datetime.timedelta(hours=5, minutes=0) # There is a difference of 5h with respect to UTC in that dataset
            
            # We only analyze the fragment of the LDAP attack
            start_time = datetime.datetime(2018, 12, 1, 11, 20, 00, 000000)
            end_time = datetime.datetime(2018, 12, 1, 11, 35, 00, 000000)
            if date_time < start_time or date_time > end_time: 
                continue # We skip that iteration
            
            # We check whether the packet corresponds to a new flow
            eth = dpkt.ethernet.Ethernet(buf)
            str_eth_src = ':'.join('%02x' % dpkt.compat_ord(b) for b in eth.src) # To make easier to read the mac
            str_eth_dst = ':'.join('%02x' % dpkt.compat_ord(b) for b in eth.dst)

            if isinstance(eth.data, dpkt.ip.IP):
                ip = eth.data
                str_ip_src = str(socket.inet_ntop(socket.AF_INET, ip.src))
                str_ip_dst = str(socket.inet_ntop(socket.AF_INET, ip.dst))

                if isinstance(ip.data, dpkt.udp.UDP):
                    udp = ip.data
                    str_transp_src = str(udp.sport)
                    str_transp_dst = str(udp.dport)
                    
                elif isinstance(ip.data, dpkt.tcp.TCP):
                    tcp = ip.data
                    str_transp_src = str(tcp.sport)
                    str_transp_dst = str(tcp.dport)

                else:
                    str_transp_src = "-1"
                    str_transp_dst = "-1"

            flow_id = str_eth_src + " " + str_eth_dst + " " + str_ip_src + " " + str_ip_dst + " " + str_transp_src + " " + str_transp_dst
            if str_transp_src == "695":
                if not flow_id in list_flows:
                    list_flows.append(flow_id)
            
            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counter
                time_axis[0] = date_time
                is_first_packet = False

            # We check whether the time window has been exceeded. 
            difference = (date_time-time_axis[current_bucket]).total_seconds()
            if (difference > time_window):

                # If it has, we initialize a new bucket.
                current_bucket = current_bucket + 1
                time_axis[current_bucket] = date_time

                for aggregation_id in aggregation_levels:
                    if "throughput" in features: 
                        throughputs[aggregation_id][current_bucket] = 0
                    if "numpackets" in features:    
                        numpackets[aggregation_id][current_bucket] = 0

            # If the time window has not been exceeded, we just update the counters
            for aggregation_id in aggregation_levels:
                
                # We check whether the packet fulfills ALL the conditions of the aggregation
                satisfies = True

                for header in aggregation_levels[aggregation_id]:
                    if not (self.packet_belongs_to_aggregation_level(buf, header, aggregation_levels[aggregation_id][header]["min"], aggregation_levels[aggregation_id][header]["max"])):
                        satisfies = False

                if (satisfies):

                    # Counters update
                    if "throughput" in features:
                        throughputs[aggregation_id][current_bucket] = throughputs[aggregation_id][current_bucket] + len(buf) # count bits to have bps
                    if "numpackets" in features:
                        numpackets[aggregation_id][current_bucket] = numpackets[aggregation_id][current_bucket] + 1

        f.close()
        #print(list_flows)
        # Once we have processed all the pcaps, and computed the required features, we write the results in a file
        print('Saving the results on a file...')

        if "throughput" in features: 
            for aggregation_id in aggregation_levels:
                file_id = file_name.split('/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0')[1]
                file = open(file_id + 'throughput' + aggregation_id + '.dat', 'w+')
                
                # For the first file, we initialize the gnuplot header
                if file_id == file_name[0].split('/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0'):
                    file.write("#,Throughput\n")

                for line in range(0,len(throughputs[aggregation_id])):
                    if time_axis[line] != None:
                        file.write("%s,%s\n" % (time_axis[line], throughputs[aggregation_id][line]))
                file.close()

        if "numpackets" in features:
            for aggregation_id in aggregation_levels:
                file_id = file_name.split('/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0')[1]
                file = open(file_id + 'numpackets' + aggregation_id + '.dat', 'w+')

                # For the first file, we initialize the gnuplot header
                if file_id == file_name[0].split('/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0'):
                    file.write("#,Num_packets\n")

                for line in range(0,len(numpackets[aggregation_id])):
                    if time_axis[line] != None:
                        file.write("%s,%s\n" % (time_axis[line], numpackets[aggregation_id][line]))
                file.close()   

if __name__ == '__main__':

    # We create a list with all the pcap files we want to analyze
    file_list = []

    for file_id in range(370,450):
    #for file_id in range(800):  
        if file_id == 0:
            file_name = '/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0'
        else:
            file_name = '/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0' + str(file_id)
        file_list.append(file_name)

    # We create a new set of aggregation levels
    # TODO add support for 'ands' and 'ors' in the signatures: eg. srcport 53 or dstport 53
    # Right now all the conditions have to be satisfied
    aggregation_levels = {          
        "UDP" : {           # UDP traffic          
            "ip.proto" : {
               "min" : 17,
               "max" : 17
            }
        },
        "TCP" : {           # TCP traffic
            "ip.proto" : {          
               "min" : 6,
               "max" : 6
            }
        },
        "flow1" : {
            "udp.sport" : {          
               "min" : 695,
               "max" : 695
            },
            "udp.dport" : {          
               "min" : 5910,
               "max" : 5910
            }   
        },
        "flow2" : {
            "udp.sport" : {          
               "min" : 695,
               "max" : 695
            },
            "udp.dport" : {          
               "min" : 61435,
               "max" : 61435
            }              
        },
        "flow3" : {
            "udp.sport" : {          
               "min" : 695,
               "max" : 695
            },
            "udp.dport" : {          
               "min" : 33087,
               "max" : 33087
            }             
        },
        "flow4" : {
            "udp.sport" : {          
               "min" : 695,
               "max" : 695
            },
            "udp.dport" : {          
               "min" : 1097,
               "max" : 1097
            }              
        }              
    }

    # We select the features that we want to extract
    features = ["throughput", "numpackets"]

    # We configure the time granularity at which we want to perform the analysis
    time_window = 1 # in seconds

    # We create a new instance of the traffic analyzer, and we start the analysis
    traffic_analyzer = TrafficAnalyzer(file_list, aggregation_levels, features, time_window)
    traffic_analyzer.execute()

    # We need to merge all the individual files
    if "throughput" in features: 
        for aggregation_id in aggregation_levels:
            file_destination = open('aggregated_throughput' + aggregation_id + '.dat', 'w+')
            for file_name in file_list:
                file_id = file_name.split('/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0')[1]
                file_origin = open(file_id + 'throughput' + aggregation_id + '.dat', 'r')
                for line in file_origin.readlines():
                    file_destination.write(line)
                file_origin.close()

                # As soon as we have finished copying the content, we delete the file
                os.remove(file_id + 'throughput' + aggregation_id + '.dat') 
        file_destination.close()

    if "numpackets" in features: 
        for aggregation_id in aggregation_levels:
            file_destination = open('aggregated_numpackets' + aggregation_id + '.dat', 'w+')
            for file_name in file_list:
                file_id = file_name.split('/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0')[1]
                file_origin = open(file_id + 'numpackets' + aggregation_id + '.dat', 'r')
                for line in file_origin.readlines():
                    file_destination.write(line)
                file_origin.close()

                # As soon as we have finished copying the content, we delete the file
                os.remove(file_id + 'numpackets' + aggregation_id + '.dat') 
        file_destination.close()

    # We will need to generate the plots afterwards   
    print('Generating the plots...')
    #os.system('gnuplot plot_ldap.gnuplot') 