import dpkt
import datetime
import os
import multiprocessing 
import socket 
import sys
import matplotlib
import random
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from clustering import range_based_clustering, representative_based_clustering
from sklearn.cluster import KMeans
import numpy as np

class Analyzer():

    def __init__(self, simulation_id, input_pcap_list, input_pcap_range_enabled, input_pcap_time_adjustment, input_pcap_time_start, input_pcap_time_end, clustering_type, num_clusters, reset_clusters_window, learning_rate, feature_set, normalize_feature_values, prioritizing_type, update_priorities_window, monitoring_window, throughput_logging, traffic_distributions_logging, traffic_distributions_histogram_logging, clustering_performance_logging, clustering_performance_time_logging, priority_performance_logging, priority_performance_time_logging, throughput_priorities_logging, signature_evaluation_logging, output_logfiles_seed, output_pcap, output_pcap_seed):
       
        # Input-file configuration
        self.simulation_id = simulation_id
        self.input_pcap_list = input_pcap_list
        self.input_pcap_range_enabled = input_pcap_range_enabled
        self.input_pcap_time_adjustment = input_pcap_time_adjustment
        self.input_pcap_time_start = input_pcap_time_start
        self.input_pcap_time_end = input_pcap_time_end
        
        # Clustering-algorithm configuration
        self.clustering_type = clustering_type
        self.num_clusters = num_clusters
        self.reset_clusters_window = reset_clusters_window
        self.learning_rate = learning_rate
        self.feature_set = feature_set
        self.normalize_feature_values = normalize_feature_values

        # Prioritization configuration
        self.prioritizing_type = prioritizing_type
        self.update_priorities_window = update_priorities_window

        # Logging configuration
        self.monitoring_window = monitoring_window
        self.throughput_logging = throughput_logging
        self.traffic_distributions_logging = traffic_distributions_logging
        self.traffic_distributions_histogram_logging = traffic_distributions_histogram_logging
        self.clustering_performance_logging = clustering_performance_logging
        self.clustering_performance_time_logging = clustering_performance_time_logging
        self.priority_performance_logging = priority_performance_logging
        self.priority_performance_time_logging = priority_performance_time_logging
        self.throughput_priorities_logging = throughput_priorities_logging
        self.signature_evaluation_logging = signature_evaluation_logging
        
        # Output-files configuration
        self.output_logfiles_seed = output_logfiles_seed
        self.output_pcap = output_pcap
        self.output_pcap_seed = output_pcap_seed

        ##################
        # We print the selected configurations
        ##################

        print("[INFO] ------------------------------------------------------------------------ \n" + 
            "[INFO] Running Analyzer \n"    + 
            "[INFO] ------------------------------------------------------------------------ \n" + 
            "[INFO]  --- # Input-file configuration \n" +
            "[INFO] simulation_id: " + str(simulation_id) + "\n" +
            "[INFO] input_pcap_list[0]: " + str(input_pcap_list[0]) + "\n" +
            "[INFO] input_pcap_range_enabled: " + str(input_pcap_range_enabled) + "\n" +
            "[INFO] input_pcap_time_adjustment: " + str(input_pcap_time_adjustment) + "\n" +
            "[INFO] input_pcap_time_start: " + str(input_pcap_time_start) + "\n" +
            "[INFO] input_pcap_time_end: " + str(input_pcap_time_end) + "\n" +
            "[INFO] ------------------------------------------------------------------------ \n" + 
            "[INFO]  --- # Clustering-algorithm configuration \n" +
            "[INFO] clustering_type: " + str(clustering_type) + "\n" +
            "[INFO] num_clusters: " + str(num_clusters) + "\n" +
            "[INFO] reset_clusters_window: " + str(reset_clusters_window) + "\n" +
            "[INFO] learning_rate: " + str(learning_rate) + "\n" +
            "[INFO] feature_set: " + str(feature_set) + "\n" +
            "[INFO] normalize_feature_values: " + str(normalize_feature_values) + "\n" +
            "[INFO] ------------------------------------------------------------------------ \n" + 
            "[INFO]  --- # Prioritization configuration \n" +
            "[INFO] prioritizing_type: " + str(prioritizing_type) + "\n" +
            "[INFO] update_priorities_window: " + str(update_priorities_window) + "\n" +
            "[INFO] ------------------------------------------------------------------------ \n" + 
            "[INFO]  --- # Logging configuration \n" +
            "[INFO] monitoring_window: " + str(monitoring_window) + "\n" +
            "[INFO] throughput_logging: " + str(throughput_logging) + "\n" +
            "[INFO] traffic_distributions_logging: " + str(traffic_distributions_logging) + "\n" +
            "[INFO] traffic_distributions_histogram_logging: " + str(traffic_distributions_histogram_logging) + "\n" +
            "[INFO] clustering_performance_logging: " + str(clustering_performance_logging) + "\n" +
            "[INFO] clustering_performance_time_logging: " + str(clustering_performance_time_logging) + "\n" +
            "[INFO] priority_performance_logging: " + str(priority_performance_logging) + "\n" +
            "[INFO] priority_performance_time_logging: " + str(priority_performance_time_logging) + "\n" +
            "[INFO] throughput_priorities_logging: " + str(throughput_priorities_logging) + "\n" +
            "[INFO] signature_evaluation_logging: " + str(signature_evaluation_logging) + "\n" +
            "[INFO] ------------------------------------------------------------------------ \n" + 
            "[INFO] # Output-files configuration \n" +
            "[INFO] output_logfiles_seed: " + str(output_logfiles_seed) + "\n" +
            "[INFO] output_pcap: " + str(output_pcap) + "\n" +
            "[INFO] output_pcap_seed: " + str(output_pcap_seed))

    def execute(self):
        pool = multiprocessing.Pool(processes=128) # Use 128 cores

        # We start processing the pcap files (individually)
        for input_pcap_name in self.input_pcap_list:     
            pool.apply_async(self.analyze, args=(self.simulation_id, input_pcap_name, self.input_pcap_range_enabled, self.input_pcap_time_adjustment, self.input_pcap_time_start, self.input_pcap_time_end, self.clustering_type, self.num_clusters, self.reset_clusters_window, self.learning_rate, self.feature_set, self.normalize_feature_values, self.prioritizing_type, self.update_priorities_window, self.monitoring_window, self.throughput_logging, self.traffic_distributions_logging, self.traffic_distributions_histogram_logging, self.clustering_performance_logging, self.clustering_performance_time_logging, self.priority_performance_logging, self.priority_performance_time_logging, self.throughput_priorities_logging, self.signature_evaluation_logging, self.output_logfiles_seed, self.output_pcap, self.output_pcap_seed)) 
            
            # TO DEBUG:
            #handler = pool.apply_async(self.analyze, args=(self.simulation_id, input_pcap_name, self.input_pcap_range_enabled, self.input_pcap_time_adjustment, self.input_pcap_time_start, self.input_pcap_time_end, self.clustering_type, self.num_clusters, self.reset_clusters_window, self.learning_rate, self.feature_set, self.normalize_feature_values, self.prioritizing_type, self.update_priorities_window, self.monitoring_window, self.throughput_logging, self.traffic_distributions_logging, self.traffic_distributions_histogram_logging, self.clustering_performance_logging, self.clustering_performance_time_logging, self.priority_performance_logging, self.priority_performance_time_logging, self.throughput_priorities_logging, self.signature_evaluation_logging, self.output_logfiles_seed, self.output_pcap, self.output_pcap_seed))
            #handler.get()
        pool.close()
        pool.join()

    def analyze(self, simulation_id, input_pcap_name, input_pcap_range_enabled, input_pcap_time_adjustment, input_pcap_time_start, input_pcap_time_end, clustering_type, num_clusters, reset_clusters_window, learning_rate, feature_set, normalize_feature_values, prioritizing_type, update_priorities_window, monitoring_window, throughput_logging, traffic_distributions_logging, traffic_distributions_histogram_logging, clustering_performance_logging, clustering_performance_time_logging, priority_performance_logging, priority_performance_time_logging, throughput_priorities_logging, signature_evaluation_logging, output_logfiles_seed, output_pcap, output_pcap_seed):

        ##################
        # We configure the clustering algorithm
        ##################

        # Analyze each pcap file, reading packet by packet
        #print('Started reading file: ' + input_pcap_name)
        read_file = open(input_pcap_name,'rb')
        pcap_reader = dpkt.pcap.Reader(read_file)
        is_first_packet = True

        # Create the clustering-algorithm manager
        if (clustering_type.split("_")[1] == "Range"):
            clustering = range_based_clustering.RangeBasedClustering(num_clusters, feature_set)

        elif (clustering_type.split("_")[1] == "Representative"): 
            clustering = representative_based_clustering.RepresentativeBasedClustering(num_clusters, feature_set)
            
            # We check if we need to periodically initialize centroids with the offline result
            if(len(clustering_type.split("_")) == 4):
                if(clustering_type.split("_")[3] == "Offline-Centroid-Initialization"):
                    batch_packets_offline = []
                    offline = KMeans(n_clusters=num_clusters)

        elif (clustering_type.split("_")[1] == "KMeans"):
            batch_packets = []
            clustering = KMeans(n_clusters=num_clusters)

        else:
            raise Exception("Clustering algorithm not supported: {}".format(clustering_type))

        ##################
        # We prepare the logging files and the logging configuration
        ##################

        # Create the output files for clustering-performance logging
        if clustering_performance_logging == "True":
            sum_purities = 0
            sum_true_negative_rates = 0
            sum_true_positive_rates = 0
            sum_recall_benign = 0
            sum_recall_malicious = 0
            number_iterations = 0
            original_labels_packets = []

            if input_pcap_range_enabled == "True":

                file_id = input_pcap_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                clustering_performance_file = open(output_logfiles_seed + file_id + '_clustering_performance.dat', 'w+')
                if file_id == self.input_pcap_list[0].split('DDoS2019/SAT-01-12-2018_0')[1]:
                    clustering_performance_file.write("#Sum_Purities,Sum_True_Negative_Rates,Sum_True_Positive_Rates,Sum_Recall_Benign,Sum_Recall_Malicious,Number_Iterations\n")

                if clustering_performance_time_logging == "True":
                    clustering_performance_time_file = open(output_logfiles_seed + file_id + '_clustering_performance_time.dat', 'w+')
                    if file_id == self.input_pcap_list[0].split('DDoS2019/SAT-01-12-2018_0')[1]:
                        clustering_performance_time_file.write("#Date_Time,Purity,True_Negative_Rate,True_Positive_Rate,Recall_Benign,Recall_Malicious\n")

            else:
                clustering_performance_file = open(output_logfiles_seed + '_clustering_performance.dat', 'w+')
                clustering_performance_file.write("#Sum_Purities,Sum_True_Negative_Rates,Sum_True_Positive_Rates,Sum_Recall_Benign,Sum_Recall_Malicious,Number_Iterations\n")
                
                if clustering_performance_time_logging == "True":
                    clustering_performance_time_file = open(output_logfiles_seed + '_clustering_performance_time.dat', 'w+')
                    clustering_performance_time_file.write("#Date_Time,Purity,True_Negative_Rate,True_Positive_Rate,Recall_Benign,Recall_Malicious\n")


        # Create the output files for priority-performance logging
        if priority_performance_logging == "True":
            sum_scores = 0
            number_iterations_score = 0

            # We initialize the time loggers
            current_benign_priorities = 0
            current_benign_packets = 0
            current_malicious_priorities = 0
            current_malicious_packets = 0

            if input_pcap_range_enabled == "True":

                file_id = input_pcap_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                priority_performance_file = open(output_logfiles_seed + file_id + '_priority_performance.dat', 'w+')
                if file_id == self.input_pcap_list[0].split('DDoS2019/SAT-01-12-2018_0')[1]:
                    priority_performance_file.write("#Sum_Scores,Number_Iterations_Score\n")

                if priority_performance_time_logging == "True":
                    priority_performance_time_file = open(output_logfiles_seed + file_id + '_priority_performance_time.dat', 'w+')
                    if file_id == self.input_pcap_list[0].split('DDoS2019/SAT-01-12-2018_0')[1]:
                        priority_performance_time_file.write("#Date_Time,Benign_average_priority,Malicious_average_priority,Score\n")

            else:
                priority_performance_file = open(output_logfiles_seed + '_priority_performance.dat', 'w+')
                priority_performance_file.write("#Sum_Scores,Number_Iterations_Score\n")
                
                if priority_performance_time_logging == "True":
                    priority_performance_time_file = open(output_logfiles_seed + '_priority_performance_time.dat', 'w+')
                    priority_performance_time_file.write("#Date_Time,Benign_average_priority,Malicious_average_priority,Score\n")

        # Throughput logging (actually numpackets)
        if throughput_logging == "True":        

            if input_pcap_range_enabled == "True":
        
                file_id = input_pcap_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                throughput_file = open(output_logfiles_seed + file_id + '_throughput.dat', 'w+')
                if file_id == self.input_pcap_list[0].split('DDoS2019/SAT-01-12-2018_0')[1]:
                    throughput_file.write("#Time,Benign_throughput,Malicious_throughput\n")

            else:
                throughput_file = open(output_logfiles_seed + '_throughput.dat', 'w+')
                throughput_file.write("#Time,Benign_throughput,Malicious_throughput\n")

            # We initialize the time loggers
            current_throughput_benign = 0
            current_throughput_malicious = 0

        # Throughput priorities logging
        if throughput_priorities_logging == "True":         

            if input_pcap_range_enabled == "True":       
                file_id = input_pcap_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                throughput_priorities_file = open(output_logfiles_seed + file_id + '_throughput_priorities.dat', 'w+')
                if file_id == self.input_pcap_list[0].split('DDoS2019/SAT-01-12-2018_0')[1]:
                    throughput_priorities_file.write("#Time")
                    for p in range(num_clusters):
                        throughput_priorities_file.write(", Throughput_Prio_" + str(p))
                    throughput_priorities_file.write("\n")
            else:
                throughput_priorities_file = open(output_logfiles_seed + '_throughput_priorities.dat', 'w+')
                throughput_priorities_file.write("#Time")
                for p in range(num_clusters):
                    throughput_priorities_file.write(", Throughput_Prio_" + str(p))
                throughput_priorities_file.write("\n")

            # We initialize the time loggers
            throughput_per_priority = {}
            for priority_id in range(num_clusters):
                throughput_per_priority[priority_id] = 0
                
        # Traffic-distribution logging 
        if traffic_distributions_logging == "True":
            
            period_counter = 0
            distrib_benign = {}
            distrib_malicious = {}

            for feature in feature_set.split(","):
                distrib_benign[feature] = {}
                distrib_malicious[feature] = {}

                if ((feature == "len") or (feature == "id") or (feature == "sport") or (feature == "dport")):
                    for a in range(0, 65536):
                        distrib_benign[feature][a] = 0
                        distrib_malicious[feature][a] = 0
                elif ((feature == "ttl") or (feature == "proto") or 
                    (feature == "src0") or (feature == "src1") or (feature == "src2") or (feature == "src3") or 
                    (feature == "dst0") or (feature == "dst1") or (feature == "dst2") or (feature == "dst3")):
                    for a in range(0, 256):
                        distrib_benign[feature][a] = 0
                        distrib_malicious[feature][a] = 0
                elif (feature == "frag_offset"):
                    for a in range(0, 8192):
                        distrib_benign[feature][a] = 0
                        distrib_malicious[feature][a] = 0
                else:
                    raise Exception("Feature not supported: {}".format(feature))

        # Traffic-distributions histogram logging 
        if traffic_distributions_histogram_logging == "True":

            hist_period_counter = 0
            histogram_benign = {}
            histogram_malicious = {}

            for feature_name in feature_set.split(","):
                histogram_benign[feature_name] = {}
                histogram_malicious[feature_name] = {}

                for prio in range(num_clusters):
                    histogram_benign[feature_name][prio] = []
                    histogram_malicious[feature_name][prio] = []

        # Signature-evaluation logging
        if signature_evaluation_logging == "True":

            signature_evaluation_files = []
            for feature in feature_set.split(","):
                new_signature_evaluation_file = open(output_logfiles_seed + feature + ".dat",'w+')
                signature_evaluation_files.append(new_signature_evaluation_file)

            for signature_evaluation_file in signature_evaluation_files:
                signature_evaluation_file.write("#Time")
                for num_cluster in range(num_clusters):
                    signature_evaluation_file.write(",Signature"+str(num_cluster)+"_Min,"+"Signature"+str(num_cluster)+"_Max")
                signature_evaluation_file.close()

        # Initialize the individual output pcap file (then we will merge them all)
        if output_pcap == "True":
            if input_pcap_range_enabled == "True":
                file_id = input_pcap_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                write_file = open(output_pcap_seed + file_id + 'output.pcap', 'wb')
            else:
                write_file = open(output_pcap_seed + 'output.pcap', 'wb')
            pcap_writer = dpkt.pcap.Writer(write_file)

        ##################
        # We start processing packets
        ##################

        for timestamp, buf in pcap_reader:

            # Extract the date and time
            if input_pcap_time_adjustment.split(",")[0] == "Remove":
                date_time = datetime.datetime.fromtimestamp(timestamp)-datetime.timedelta(hours=int(input_pcap_time_adjustment.split(",")[1]), minutes=0)
            elif input_pcap_time_adjustment.split(",")[0] == "Add":
                date_time = datetime.datetime.fromtimestamp(timestamp)+datetime.timedelta(hours=int(input_pcap_time_adjustment.split(",")[1]), minutes=0)
            else:
                date_time = datetime.datetime.fromtimestamp(timestamp)

            # Analyze only the parts in which there is attack
            if(simulation_id == "CICDDoS2019"):
                
                # According to the CSV analysis
                ntp_start       = datetime.datetime(2018, 12, 1, 10, 35, 0, 0)
                ntp_end         = datetime.datetime(2018, 12, 1, 10, 51, 39, 813446)

                dns_start       = datetime.datetime(2018, 12, 1, 10, 51, 39, 813448)
                dns_end         = datetime.datetime(2018, 12, 1, 11, 22, 40, 254721)

                ldap_start      = datetime.datetime(2018, 12, 1, 11, 22, 40, 254769)
                ldap_end        = datetime.datetime(2018, 12, 1, 11, 32, 32, 915362)

                mssql_start     = datetime.datetime(2018, 12, 1, 11, 32, 32, 915441)
                mssql_end       = datetime.datetime(2018, 12, 1, 11, 47, 8, 463108)

                netbios_start   = datetime.datetime(2018, 12, 1, 11, 47, 8, 463789)
                netbios_end     = datetime.datetime(2018, 12, 1, 12, 0, 13, 902733)

                snmp_start      = datetime.datetime(2018, 12, 1, 12, 00, 13, 902782)
                snmp_end        = datetime.datetime(2018, 12, 1, 12, 23, 13, 663371)

                ssdp_start      = datetime.datetime(2018, 12, 1, 12, 23, 13, 663425)
                ssdp_end        = datetime.datetime(2018, 12, 1, 12, 36, 57, 627790)

                udp_start       = datetime.datetime(2018, 12, 1, 12, 36, 57, 628026)
                udp_end         = datetime.datetime(2018, 12, 1, 13, 4, 45, 928383)

                udplag_start    = datetime.datetime(2018, 12, 1, 13, 4, 45, 928673)
                udplag_end      = datetime.datetime(2018, 12, 1, 13, 30, 30, 740559)

                syn_start       = datetime.datetime(2018, 12, 1, 13, 30, 30, 741451)
                syn_end         = datetime.datetime(2018, 12, 1, 13, 34, 27, 403192)
                
                tftp_start      = datetime.datetime(2018, 12, 1, 13, 34, 27, 403713)
                tftp_end        = datetime.datetime(2018, 12, 1, 14, 10, 0, 0)

                # We use the input_pcap_time_start field to select the attack that we want to run
                if (input_pcap_time_start == "NTP"):
                    if (date_time < ntp_start or date_time > ntp_end):
                        continue

                elif (input_pcap_time_start == "DNS"):
                    if (date_time < dns_start or date_time > dns_end):
                        continue

                elif (input_pcap_time_start == "LDAP"):
                    if (date_time < ldap_start or date_time > ldap_end):
                        continue

                elif (input_pcap_time_start == "MSSQL"):
                    if (date_time < mssql_start or date_time > mssql_end):
                        continue

                elif (input_pcap_time_start == "NetBIOS"):
                    if (date_time < netbios_start or date_time > netbios_end):
                        continue

                elif (input_pcap_time_start == "SNMP"):
                    if (date_time < snmp_start or date_time > snmp_end):
                        continue

                elif (input_pcap_time_start == "SSDP"):
                    if (date_time < ssdp_start or date_time > ssdp_end):
                        continue

                elif (input_pcap_time_start == "UDP"):
                    if (date_time < udp_start or date_time > udp_end):
                        continue

                elif (input_pcap_time_start == "UDPLag"):
                    if (date_time < udplag_start or date_time > udplag_end):
                        continue
                
                elif (input_pcap_time_start == "SYN"):
                    if (date_time < syn_start or date_time > syn_end):
                        continue
                
                elif (input_pcap_time_start == "TFTP"):
                    if (date_time < tftp_start or date_time > tftp_end):
                        continue
                
                elif (input_pcap_time_start == "Reflection"):

                    # If we want to just look at reflection:
                    reflection = False
                    if ((date_time > ntp_start and date_time < ntp_end) 
                    or (date_time > dns_start and date_time < dns_end)
                    or (date_time > ldap_start and date_time < ldap_end)
                    or (date_time > mssql_start and date_time < mssql_end)
                    or (date_time > netbios_start and date_time < netbios_end)
                    or (date_time > snmp_start and date_time < snmp_end)
                    or (date_time > ssdp_start and date_time < ssdp_end)
                    or (date_time > tftp_start and date_time < tftp_end)):
                        reflection = True

                    if reflection == False:
                        continue


                # We focus on the parts where there is attack going on
                if ((date_time < ntp_start) 
                    or (date_time > tftp_end)):

                    continue
                
            # We define the initial time reference
            if is_first_packet == True:
                
                # We notify that the time we want to analyze is found (at least) in this file 
                print(str(date_time) + ': Time match in: ' + input_pcap_name)

                # We initialize the time counters
                last_reset_clusters = date_time
                last_monitoring_update = date_time
                last_update_priorities = date_time
                is_first_packet = False

            # Unpack the Ethernet frame
            eth = dpkt.ethernet.Ethernet(buf)

            # Make sure the Ethernet data contains an IP packet
            if not isinstance(eth.data, dpkt.ip.IP):
                continue

            # Unpack the data within the Ethernet frame (the IP packet)
            ip = eth.data
            
            # We only process IPv4 packets
            try:
                src =  socket.inet_ntop(socket.AF_INET, ip.src)
                src0 = int(src.split(".")[0])
                src1 = int(src.split(".")[1])
                src2 = int(src.split(".")[2])
                src3 = int(src.split(".")[3])

            except ValueError:
                src =  socket.inet_ntop(socket.AF_INET6, ip.src)
                continue

            try:
                dst =  socket.inet_ntop(socket.AF_INET, ip.dst)
                dst0 = int(dst.split(".")[0])
                dst1 = int(dst.split(".")[1])
                dst2 = int(dst.split(".")[2])
                dst3 = int(dst.split(".")[3])

            except ValueError:
                dst =  socket.inet_ntop(socket.AF_INET6, ip.dst)
                continue

            # We extract the source and destination port of the transport layer
            if isinstance(ip.data, dpkt.tcp.TCP):
                tcp = ip.data
                sport = tcp.sport
                dport = tcp.dport

            elif isinstance(ip.data, dpkt.udp.UDP): 
                udp = ip.data
                sport = udp.sport
                dport = udp.dport

            else:
                continue

            # We only process packets of the downlink
            if(simulation_id == "CICDDoS2019"):
                if (dst == "172.16.0.5"):
                    continue

                # Correct the source port for the reflection attacks
                if (src == "172.16.0.5"): # if malicious
                    if (date_time > ntp_start and date_time < ntp_end):
                        sport = 123
                    elif (date_time > dns_start and date_time < dns_end):
                        sport = 53
                    elif (date_time > ldap_start and date_time < ldap_end):
                        sport = 389
                    elif (date_time > mssql_start and date_time < mssql_end):
                        pick_from = [1433, 4022, 135, 1434]
                        sport = random.choice(pick_from)
                    elif (date_time > netbios_start and date_time < netbios_end):
                        sport = 137
                    elif (date_time > snmp_start and date_time < snmp_end):
                        sport = 161
                    elif (date_time > ssdp_start and date_time < ssdp_end):
                        sport = 1900
                    elif (date_time > tftp_start and date_time < tftp_end):
                        sport = 69

            # Create the packet feature vector
            full_packet = {
                "len"         : ip.len,
                "id"          : ip.id,
                "frag_offset" : ip._flags_offset,
                "ttl"         : ip.ttl,
                "proto"       : ip.p,
                "src0"        : src0,
                "src1"        : src1,
                "src2"        : src2,
                "src3"        : src3,
                "dst0"        : dst0,
                "dst1"        : dst1,
                "dst2"        : dst2,
                "dst3"        : dst3,
                "sport"       : sport,
                "dport"       : dport
            }

            if normalize_feature_values == "True":
                full_packet = {
                    "len"         : float(ip.len/65535),
                    "id"          : float(ip.id/65535),
                    "frag_offset" : float(ip._flags_offset/8191),
                    "ttl"         : float(ip.ttl/255),
                    "proto"       : float(ip.p/255),
                    "src0"        : float(src0/255),
                    "src1"        : float(src1/255),
                    "src2"        : float(src2/255),
                    "src3"        : float(src3/255),
                    "dst0"        : float(dst0/255),
                    "dst1"        : float(dst1/255),
                    "dst2"        : float(dst2/255),
                    "dst3"        : float(dst3/255),
                    "sport"       : float(sport/65535),
                    "dport"       : float(dport/65535)
                }
                
            packet = []
            for feature in feature_set.split(","):
                packet.append(full_packet[feature])
             
            # Cluster that packet
            if clustering_type == "Online_Range_Fast_Anime":
                selected_cluster = clustering.fit_fast(packet, ip.len, "anime")

            elif clustering_type == "Online_Range_Fast_Manhattan":
                selected_cluster = clustering.fit_fast(packet, ip.len, "manhattan")

            elif clustering_type == "Online_Range_Exhaustive_Anime":
                selected_cluster = clustering.fit_exhaustive(packet, ip.len, "anime")

            elif clustering_type == "Online_Range_Exhaustive_Manhattan":
                selected_cluster = clustering.fit_exhaustive(packet, ip.len, "manhattan")

            elif clustering_type == "Online_Representative_Fast" or clustering_type == "Online_Representative_Fast_Offline-Centroid-Initialization":
                selected_cluster = clustering.fit_fast(packet, ip.len, learning_rate)

                # We keep track of the packets so that we can later run the offline initialization for the current batch
                if(len(clustering_type.split("_")) == 4):
                    if(clustering_type.split("_")[3] == "Offline-Centroid-Initialization"):
                        batch_packets_offline.append(packet)

            elif clustering_type == "Online_Representative_Exhaustive" or clustering_type == "Online_Representative_Exhaustive_Offline-Centroid-Initialization":
                selected_cluster = clustering.fit_exhaustive(packet, ip.len, learning_rate)

                # We keep track of the packets so that we can later run the offline initialization for the current batch
                if(len(clustering_type.split("_")) == 4):
                    if(clustering_type.split("_")[3] == "Offline-Centroid-Initialization"):
                        batch_packets_offline.append(packet)

            elif clustering_type == "Offline_KMeans":
                # We just append the generated packet to a batch of packets, which we will then cluster together
                batch_packets.append(packet)

            else:
                raise Exception("Clustering algorithm not supported: {}".format(clustering_type))

            # We compute the packet priority (only possible for online approaches)
            packet_priority = 0
            if (clustering_type.split("_")[0] == "Online"):
                    
                    # We return the priority assigned to the packet
                    packet_priority = selected_cluster.get_priority()

            ##################
            # We perform the per-packet logging
            ##################

            # Clustering-performance logging
            if clustering_performance_logging == "True":

                if(simulation_id == "CICDDoS2019"):

                    # We keep the ground-truth label for the packet so that later we can compute the purity with it
                    if (src == "172.16.0.5"):
                        # Malicious
                        original_labels_packets.append(False)
                    
                    else:
                        # Benign
                        original_labels_packets.append(True)

                elif (simulation_id == "Morphing"):

                    # We keep the ground-truth label for the packet so that later we can compute the purity with it
                    if (src == "192.168.0.5"):
                        # Malicious
                        original_labels_packets.append(False)
                    
                    else:
                        # Benign
                        original_labels_packets.append(True)

                else:
                    raise Exception("Simulation ID not supported: {}".format(simulation_id))

            # Priority time logging
            if priority_performance_logging == "True":

                if(simulation_id == "CICDDoS2019"):
                    if (src == "172.16.0.5"):
                        current_malicious_packets = current_malicious_packets + 1
                        current_malicious_priorities = current_malicious_priorities + packet_priority
                    else:
                        current_benign_packets = current_benign_packets + 1
                        current_benign_priorities = current_benign_priorities + packet_priority

                elif(simulation_id == "Morphing"):
                    if (src == "192.168.0.5"):
                        current_malicious_packets = current_malicious_packets + 1
                        current_malicious_priorities = current_malicious_priorities + packet_priority
                    else:
                        current_benign_packets = current_benign_packets + 1
                        current_benign_priorities = current_benign_priorities + packet_priority

                else:
                    raise Exception("Simulation ID not supported: {}".format(simulation_id))

            # Throughput logging
            if throughput_logging == "True":

                if(simulation_id == "CICDDoS2019"):
                    if (src == "172.16.0.5"):
                        current_throughput_malicious = current_throughput_malicious + int(ip.len)*8 + (60*8) + (60*8) # We put the 60 bytes headers that Netbench will add (instead of the original headers)
                    else:
                        current_throughput_benign = current_throughput_benign + int(ip.len)*8 + (60*8) + (60*8)

                elif(simulation_id == "Morphing"):
                    if (src == "192.168.0.5"):
                        current_throughput_malicious = current_throughput_malicious + int(ip.len)*8 + (60*8) + (60*8)
                    else:
                        current_throughput_benign = current_throughput_benign + int(ip.len)*8 + (60*8) + (60*8)

                else:
                    raise Exception("Simulation ID not supported: {}".format(simulation_id))

            # Throughput priorities logging
            if throughput_priorities_logging == "True":
                throughput_per_priority[packet_priority] = throughput_per_priority[packet_priority] + int(ip.len)*8 + (60*8) + (60*8)

            # Traffic-distribution logging
            if traffic_distributions_logging == "True":
                for feature in feature_set.split(","):

                    if(simulation_id == "CICDDoS2019"):
                        if (src == "172.16.0.5"):
                            distrib_malicious[feature][full_packet[feature]] = distrib_malicious[feature][full_packet[feature]] + 1
                        else:
                            distrib_benign[feature][full_packet[feature]] = distrib_benign[feature][full_packet[feature]] + 1

                    elif(simulation_id == "Morphing"):
                        if (src == "192.168.0.5"):
                            distrib_malicious[feature][full_packet[feature]] = distrib_malicious[feature][full_packet[feature]] + 1
                        else:
                            distrib_benign[feature][full_packet[feature]] = distrib_benign[feature][full_packet[feature]] + 1

                    else:
                        raise Exception("Simulation ID not supported: {}".format(simulation_id))

            # Traffic-distribution logging
            if traffic_distributions_histogram_logging == "True":
                
                for feature_name in feature_set.split(","):
                    if(simulation_id == "CICDDoS2019"):
                        if (src == "172.16.0.5"):
                            histogram_malicious[feature_name][packet_priority].append(full_packet[feature_name])
                        else:
                            histogram_benign[feature_name][packet_priority].append(full_packet[feature_name])

                    elif(simulation_id == "Morphing"):
                        if (src == "192.168.0.5"):
                            histogram_malicious[feature_name][packet_priority].append(full_packet[feature_name])
                        else:
                            histogram_benign[feature_name][packet_priority].append(full_packet[feature_name])

                    else:
                        raise Exception("Simulation ID not supported: {}".format(simulation_id))

            # We update the priorities (potentially per packet)
            if (update_priorities_window != -1):
                difference_update_priorities = (date_time-last_update_priorities).total_seconds()
                if (difference_update_priorities > update_priorities_window):

                    # We update the priorities, and update the time tracker
                    clustering.update_priorities(prioritizing_type)
                    last_update_priorities = date_time

            # We write the packet (with the priority) to the output file
            if output_pcap == "True":

                    # We put the priority in some header field
                    eth.src = (packet_priority).to_bytes(6, byteorder="big") #b'\x00\x00\x00\x00\x00\x05' if priority = 5

                    # Write the resulting packet to an output pcap
                    # packet (bytes): Some `bytes` to write to the file
                    # timestamp (float): Timestamp in seconds
                    pcap_writer.writepkt(eth, timestamp)

            ##################
            # We perform the per-monitoring-window logging
            ##################

            # We update time buckets for monitoring
            if (monitoring_window != -1):
                difference_tracking = (date_time-last_monitoring_update).total_seconds()
                if (difference_tracking > monitoring_window):

                    # Throughput logging
                    if throughput_logging == "True":
                        throughput_file.write(str(date_time) + "," + str(current_throughput_benign) + "," + str(current_throughput_malicious) + "\n")                    
                        current_throughput_benign = 0
                        current_throughput_malicious = 0

                    # Throughput priorities logging
                    if throughput_priorities_logging == "True":
                        throughput_priorities_file.write(str(date_time))
                        for current_prio in range(num_clusters):
                            throughput_priorities_file.write("," + str(throughput_per_priority[current_prio]))
                            throughput_per_priority[current_prio] = 0 # We reset the counters
                        throughput_priorities_file.write("\n")

                    # Priority-performance logging
                    if priority_performance_logging == "True":

                        # We compute the average priorities
                        if current_benign_packets == 0:
                            benign_average_priority = -1
                        else:
                            benign_average_priority = current_benign_priorities/current_benign_packets
                        
                        if current_malicious_packets == 0:
                            malicious_average_priority = -1
                        else:
                            malicious_average_priority = current_malicious_priorities/current_malicious_packets

                        # We compute the score. If in that window we didn't see packets of one of the two types, we just skip that window
                        if (benign_average_priority != -1) and (malicious_average_priority != -1):
                            if (malicious_average_priority < benign_average_priority):
                                score = 1
                            else:
                                score = 0

                            # We log the result for the iteration if temporal logging is enabled                
                            if priority_performance_time_logging == "True":
                                priority_performance_time_file.write(str(date_time) + "," + str(benign_average_priority) + "," + str(malicious_average_priority) + "," + str(score) + "\n")
                            
                            # We aggregate the results for overall logging
                            sum_scores = sum_scores + score
                            number_iterations_score = number_iterations_score + 1

                        current_benign_packets = 0
                        current_malicious_packets = 0
                        current_benign_priorities = 0
                        current_malicious_priorities = 0

                    # Clustering-performance logging
                    if clustering_performance_logging == "True":
                    
                        # We initialize the purity and the other statistical metrics that we want to extract
                        purity = 0
                        true_negative_rate = 0
                        true_positive_rate = 0
                        recall_benign = 0
                        recall_malicious = 0

                        majority_benign_counter = {}
                        majority_malicious_counter = {}
                        total_benign_packets_interval = 0
                        total_malicious_packets_interval = 0

                        # We first assign each cluster to the class which is most frequent in the cluster
                        for n in range(num_clusters):
                            majority_benign_counter[n] = 0
                            majority_malicious_counter[n] = 0

                        # We extract the labels allocated to the clustered packets so far and use them to compute purity
                        if (clustering_type == "Online_Range_Fast_Manhattan" or clustering_type == "Online_Range_Fast_Anime" 
                            or clustering_type == "Online_Range_Exhaustive_Manhattan"  or clustering_type == "Online_Range_Exhaustive_Anime"
                            or clustering_type == "Online_Representative_Fast" or clustering_type == "Online_Representative_Fast_Offline-Centroid-Initialization" 
                            or clustering_type == "Online_Representative_Exhaustive" or clustering_type == "Online_Representative_Exhaustive_Offline-Centroid-Initialization" 
                            or clustering_type == "Online_Random_Fast" or clustering_type == "Online_Hash"):
                            result_labels = clustering.get_labels()
                        else:
                            # Offline k-means (we need to fit the whole packet batch)
                            if (len(batch_packets) >= num_clusters):
                                array_batch_packets = np.array(batch_packets)
                                clustering.fit(array_batch_packets)
                                result_labels = clustering.labels_
                                batch_packets = []
                            else:
                                # If we don't have enough samples to run kmeans, we just assign each sample to a different cluster
                                result_labels = []
                                for label in range(len(batch_packets)):
                                    result_labels.append(label)
                                batch_packets = []

                        # We count the number of benign and malicious packets clustered in each cluster
                        for p in range(len(result_labels)):
                            if (original_labels_packets[p] == True):
                                majority_benign_counter[result_labels[p]] = majority_benign_counter[result_labels[p]] + 1
                                total_benign_packets_interval = total_benign_packets_interval + 1
                            else:
                                majority_malicious_counter[result_labels[p]] = majority_malicious_counter[result_labels[p]] + 1
                                total_malicious_packets_interval = total_malicious_packets_interval + 1

                        for n in range(num_clusters):
                            if (majority_benign_counter[n] >= majority_malicious_counter[n]):

                                # The cluster is classified as benign
                                purity = purity + majority_benign_counter[n]
                                true_negative_rate = true_negative_rate + majority_benign_counter[n]

                            else:

                                # The cluster is classified as malicious
                                purity = purity + majority_malicious_counter[n]
                                true_positive_rate = true_positive_rate + majority_malicious_counter[n]

                        # We only study the intervals in which we have both benign and malicious traffic, otherwise the clustering makes no sense
                        if (len(result_labels) != 0) and (total_benign_packets_interval != 0) and (total_malicious_packets_interval != 0):
                            recall_benign = (true_negative_rate/total_benign_packets_interval)*100
                            recall_malicious = (true_positive_rate/total_malicious_packets_interval)*100

                            purity = (purity/len(result_labels))*100
                            true_negative_rate = (true_negative_rate/len(result_labels))*100
                            true_positive_rate = (true_positive_rate/len(result_labels))*100

                            # We log the result for the iteration if temporal logging is enabled                
                            if clustering_performance_time_logging == "True":
                                clustering_performance_time_file.write(str(date_time) + "," + str(purity)+ "," + str(true_negative_rate)+ "," + str(true_positive_rate) + "," + str(recall_benign) + "," + str(recall_malicious) + "\n")
                            
                            # We aggregate the results for overall logging
                            sum_purities = sum_purities + purity
                            sum_true_negative_rates = sum_true_negative_rates + true_negative_rate
                            sum_true_positive_rates = sum_true_positive_rates + true_positive_rate
                            sum_recall_benign = sum_recall_benign + recall_benign
                            sum_recall_malicious = sum_recall_malicious + recall_malicious
                            number_iterations = number_iterations + 1

                        # We reset the analyzed labels and also the labels from the clustering algorithm object (otherwise there will be a missmatch)
                        original_labels_packets.clear()
                        if (clustering_type == "Online_Range_Fast_Manhattan" or clustering_type == "Online_Range_Fast_Anime" 
                            or clustering_type == "Online_Range_Exhaustive_Manhattan"  or clustering_type == "Online_Range_Exhaustive_Anime"
                            or clustering_type == "Online_Representative_Fast" or clustering_type == "Online_Representative_Fast_Offline-Centroid-Initialization" 
                            or clustering_type == "Online_Representative_Exhaustive" or clustering_type == "Online_Representative_Exhaustive_Offline-Centroid-Initialization" 
                            or clustering_type == "Online_Random_Fast" or clustering_type == "Online_Hash"):
                            clustering.reset_labels() # Note that this does not reset the clusters, nor their centroids
                        else:
                            # Offline k-means
                            clustering = KMeans(n_clusters=num_clusters) # Here we just create a new instance, such that we don't have previous labels

                    # Traffic-distribution logging
                    if traffic_distributions_logging == "True":

                        # Safety bound (we don't store more than 50 periods of distributions)
                        if (period_counter < 50):

                            for feature in feature_set.split(","):
                                distrib_file = open(output_logfiles_seed + feature + "_distrib_" + str(period_counter) + ".dat", 'w+')
                                distrib_file.write("#    " + feature + "_distrib_benign    " + feature + "_distrib_attack\n")

                                for line in range(0,len(distrib_benign[feature])):
                                    distrib_file.write("%s   %s   %s\n" % (line, distrib_benign[feature][line], distrib_malicious[feature][line]))
                                distrib_file.close()
                            period_counter = period_counter + 1

                            # We reset the distributions, for the next period
                            distrib_benign = {}
                            distrib_malicious = {}

                            for feature in feature_set.split(","):
                                distrib_benign[feature] = {}
                                distrib_malicious[feature] = {}

                                if ((feature == "len") or (feature == "id") or (feature == "sport") or (feature == "dport")):
                                    for a in range(0, 65536):
                                        distrib_benign[feature][a] = 0
                                        distrib_malicious[feature][a] = 0
                                elif ((feature == "ttl") or (feature == "proto") or 
                                    (feature == "src0") or (feature == "src1") or (feature == "src2") or (feature == "src3") or 
                                    (feature == "dst0") or (feature == "dst1") or (feature == "dst2") or (feature == "dst3")):
                                    for a in range(0, 256):
                                        distrib_benign[feature][a] = 0
                                        distrib_malicious[feature][a] = 0
                                else:
                                    # frag_offset
                                    for a in range(0, 8192):
                                        distrib_benign[feature][a] = 0
                                        distrib_malicious[feature][a] = 0

                        else:
                            print("You have reached the maximum number of distribution periods that you can store (50)")

                    # Traffic-distribution histogram logging
                    if traffic_distributions_histogram_logging == "True":

                        # We just print the slices we want
                        if (hist_period_counter < 50):

                            for feature in feature_set.split(","):
                                histogram_benign_file = open(output_logfiles_seed + feature + "_distrib_histogram_benign_" + str(hist_period_counter) + ".dat", 'w+')
                                histogram_malicious_file = open(output_logfiles_seed + feature + "_distrib_histogram_malicious_" + str(hist_period_counter) + ".dat", 'w+')

                                n_benign = {}
                                bins_benign = {}
                                patches_benign = {}

                                n_malicious = {}
                                bins_malicious = {}
                                patches_malicious = {}

                                if ((feature == "len") or (feature == "id") or (feature == "sport") or (feature == "dport")):
                                    feature_max = 65536
                                elif ((feature == "ttl") or (feature == "proto") or 
                                    (feature == "src0") or (feature == "src1") or (feature == "src2") or (feature == "src3") or 
                                    (feature == "dst0") or (feature == "dst1") or (feature == "dst2") or (feature == "dst3")):
                                    feature_max = 256
                                elif (feature == "frag_offset"):
                                    feature_max = 8192
                                else:
                                    raise Exception("Feature not supported: {}".format(feature))
                                
                                histogram_benign_file.write("#")
                                histogram_malicious_file.write("#")

                                for prio in range(num_clusters):
                                    label_name = "Priority " + str(prio)
                                    histogram_benign_file.write("    "  + label_name)
                                    histogram_malicious_file.write("    "  + label_name)
                                    
                                    # n is the height of each bin in the histogram, bins is the position of the bin in the x axis
                                    n_benign[prio], bins_benign[prio], patches_benign[prio] = plt.hist(histogram_benign[feature][prio], bins=range(0, feature_max), histtype='step', label=label_name)
                                    n_malicious[prio], bins_malicious[prio], patches_malicious[prio] = plt.hist(histogram_malicious[feature][prio], bins=range(0, feature_max), histtype='step', label=label_name)

                                histogram_benign_file.write("\n")
                                histogram_malicious_file.write("\n")

                                for line in range(0,len(n_benign[prio])):
                                    histogram_benign_file.write(str(bins_benign[prio][line]))
                                    for prio in range(num_clusters):
                                        histogram_benign_file.write("    " + str(n_benign[prio][line]))
                                    histogram_benign_file.write("\n")

                                for line in range(0,len(n_malicious[prio])):
                                    histogram_malicious_file.write(str(bins_malicious[prio][line]))
                                    for prio in range(num_clusters):
                                        histogram_malicious_file.write("    " + str(n_malicious[prio][line]))
                                    histogram_malicious_file.write("\n")

                            hist_period_counter = hist_period_counter + 1

                            # We reset the histograms, for the next period
                            histogram_benign = {}
                            histogram_malicious = {}

                            for feature_name in feature_set.split(","):
                                histogram_benign[feature_name] = {}
                                histogram_malicious[feature_name] = {}

                                for prio in range(num_clusters):
                                    histogram_benign[feature_name][prio] = []
                                    histogram_malicious[feature_name][prio] = []

                        else:
                            print("You have reached the maximum number of histograms periods that you can store (50)")


                    # Signature-evaluation logging
                    if signature_evaluation_logging == "True":

                        for feature in feature_set.split(","):

                            # We have already initialized the file, so we just want to append the logging
                            signature_evaluation_file = open(output_logfiles_seed + feature + ".dat",'a')
                            signature_evaluation_file.write("\n" + str(date_time) + str(clustering.write_cluster_signatures(feature)))
                            signature_evaluation_file.close()

                    # We update the time tracker
                    last_monitoring_update = date_time

            # After having performed the required monitoring (if needed), we reset the clusters if the window has expired
            if reset_clusters_window != -1:

                # If both monitoring and reset_clusters are active, they should be the same value for the program to work correctly
                #if monitoring_window != -1:
                    #assert monitoring_window == reset_clusters_window
                
                difference_reset_clusters = (date_time-last_reset_clusters).total_seconds()
                if (difference_reset_clusters > reset_clusters_window):

                    # We delete all existing clusters
                    if (clustering_type == "Online_Range_Fast_Manhattan" or clustering_type == "Online_Range_Fast_Anime" 
                        or clustering_type == "Online_Range_Exhaustive_Manhattan"  or clustering_type == "Online_Range_Exhaustive_Anime"
                        or clustering_type == "Online_Representative_Fast" or clustering_type == "Online_Representative_Fast_Offline-Centroid-Initialization" 
                        or clustering_type == "Online_Representative_Exhaustive" or clustering_type == "Online_Representative_Exhaustive_Offline-Centroid-Initialization" 
                        or clustering_type == "Online_Random_Fast" or clustering_type == "Online_Hash"):
                        clustering.reset_clusters()

                        # If we decided offline initialization, instead of delete the clusters, we create N clusters and initialize them with
                        # the results of the centroids of the offline clustering for the previous batch
                        if(clustering_type.split("_")[1] == "Representative"):
                            if(len(clustering_type.split("_")) == 4): 
                                if (clustering_type.split("_")[3] == "Offline-Centroid-Initialization"):

                                    # We compute the centroids. 
                                    # If we don't have enough samples to run kmeans, we just do not initialize the centroids
                                    if (len(batch_packets_offline) >= num_clusters):
                                        array_batch_packets_offline = np.array(batch_packets_offline)
                                        offline.fit(array_batch_packets_offline)
                                        centroids = offline.cluster_centers_
                                        clustering.initialize(centroids)
                                    
                                    # We clean the batch of packets
                                    batch_packets_offline = []

                    # We update the time tracker
                    last_reset_clusters = date_time

        ##################
        # We close all logging files
        ##################

        # We close the input file
        read_file.close()

        # Clustering-performance logging
        if clustering_performance_logging == "True":
            if (number_iterations > 0):
                clustering_performance_file.write(str(sum_purities) + "," + str(sum_true_negative_rates) + "," + str(sum_true_positive_rates) + "," + str(sum_recall_benign) + "," + str(sum_recall_malicious) + "," + str(number_iterations) + "\n") 
            clustering_performance_file.close()

            # We close the clustering performance logging file
            if clustering_performance_time_logging == "True":
                clustering_performance_time_file.close()

        # Priority-performance logging
        if priority_performance_logging == "True":
            if (number_iterations_score > 0):
                priority_performance_file.write(str(sum_scores) + "," + str(number_iterations_score) + "\n") 
            priority_performance_file.close()
        
            # We close the priority performance logging file
            if priority_performance_time_logging == "True":
                priority_performance_time_file.close()

        # We close the throughput logging file
        if throughput_logging == "True":
            throughput_file.close()

        # We close the throughput priorities logging file
        if throughput_priorities_logging == "True":
            throughput_priorities_file.close()

        # We close the output file
        if output_pcap == "True":
            write_file.close()
