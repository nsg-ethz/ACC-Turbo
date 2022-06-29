# RUN WITH PYTHON 3 !!! OTHERWISE THE apply_async DOES NOT WORK !!!
import analyzer
import sys
import os
import dpkt

if __name__ == '__main__':

    if len(sys.argv) != 30: 
        print("The number of arguments required is 30")
    else:

        # Input-file configuration
        simulation_id = sys.argv[1]
        input_pcap_seed = sys.argv[2]
        input_pcap_range_enabled = sys.argv[3]
        input_pcap_range_init = int(sys.argv[4])
        input_pcap_range_end = int(sys.argv[5])
        input_pcap_time_adjustment = sys.argv[6]
        input_pcap_time_start = sys.argv[7]
        input_pcap_time_end = sys.argv[8]

        # Clustering-algorithm configuration       
        clustering_type = sys.argv[9]
        num_clusters = int(sys.argv[10])                # (Can be set to 1 to measure the overall throughput)
        reset_clusters_window = float(sys.argv[11])     # (In seconds) (w). Can be set to -1 to avoid resetting in online k-means. 
        learning_rate = float(sys.argv[12])             # (Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
        feature_set = sys.argv[13]
        normalize_feature_values = sys.argv[14]

        # Prioritization configuration
        prioritizing_type = sys.argv[15]
        update_priorities_window = float(sys.argv[16])  # (In seconds)

        # Logging configuration
        monitoring_window = float(sys.argv[17])         # (In seconds) 
        throughput_logging = sys.argv[18]
        traffic_distributions_logging = sys.argv[19]
        traffic_distributions_histogram_logging = sys.argv[20]
        clustering_performance_logging = sys.argv[21]
        clustering_performance_time_logging = sys.argv[22]
        priority_performance_logging = sys.argv[23]
        priority_performance_time_logging = sys.argv[24]
        throughput_priorities_logging = sys.argv[25]
        signature_evaluation_logging = sys.argv[26]

        # Output-files configuration
        output_logfiles_seed = sys.argv[27]
        output_pcap = sys.argv[28]
        output_pcap_seed = sys.argv[29]

        # We create a list with all the input pcap files that we want to analyze
        input_pcap_list = []
        if input_pcap_range_enabled == "False":
            input_pcap_list.append(input_pcap_seed)
        else:
            for file_id in range(input_pcap_range_init, input_pcap_range_end):
                if file_id == 0:
                    file_name = 'DDoS2019/SAT-01-12-2018_0'
                else:
                    file_name = 'DDoS2019/SAT-01-12-2018_0' + str(file_id)
                input_pcap_list.append(file_name)

        # We create a new instance of the clustering performance analyzer, and we start the analysis
        analyzer = analyzer.Analyzer(simulation_id, input_pcap_list, input_pcap_range_enabled, input_pcap_time_adjustment, input_pcap_time_start, input_pcap_time_end, clustering_type, num_clusters, reset_clusters_window, learning_rate, feature_set, normalize_feature_values, prioritizing_type, update_priorities_window, monitoring_window, throughput_logging, traffic_distributions_logging, traffic_distributions_histogram_logging, clustering_performance_logging, clustering_performance_time_logging, priority_performance_logging, priority_performance_time_logging, throughput_priorities_logging, signature_evaluation_logging, output_logfiles_seed, output_pcap, output_pcap_seed)
        analyzer.execute()

        # We now need to merge all the individual log files
        if clustering_performance_logging == "True":
            print('Merging the general clustering performance logs on a file...')
            
            # We generate the name of the overall purity log
            clustering_performance_collector_file = open(output_logfiles_seed + "clustering_performance_logs.dat", 'a')
            print(str(output_logfiles_seed) + "clustering_performance_logs.dat")

            # We create a summary of the configuration used
            configuration = sys.argv[9]
            for arg_id in range(10,18):
                if arg_id != 13:
                    configuration = configuration + '_' + sys.argv[arg_id]
            for feature in feature_set.split(","):
                configuration = configuration + '_' + feature
            if normalize_feature_values == "True":
                configuration = configuration + '_normalized'

            list_possible_attacks = ["NTP","DNS","LDAP","MSSQL","NetBIOS","SNMP","SSDP","UDP","UDPLag","SYN","TFTP"]
            if (input_pcap_time_start in list_possible_attacks):
                configuration = input_pcap_time_start + configuration

            # We summarize the general performance statistics
            sum_purities = 0
            sum_true_negative_rates = 0
            sum_true_positive_rates = 0
            sum_number_iterations = 0
            sum_recall_benign = 0
            sum_recall_malicious = 0
            
            for file_name in input_pcap_list:
                file_id = file_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                origin_file = open(output_logfiles_seed + file_id + '_clustering_performance.dat', 'r')

                for line in origin_file.readlines():
                    if line.split(",")[0] != "#Sum_Purities" and line.split(",")[0] != "" and line.split(",")[0] != "\n":
                        sum_purities = sum_purities + float(line.split(",")[0])
                        sum_true_negative_rates = sum_true_negative_rates + float(line.split(",")[1])
                        sum_true_positive_rates = sum_true_positive_rates + float(line.split(",")[2])
                        sum_recall_benign = sum_recall_benign + float(line.split(",")[3])
                        sum_recall_malicious = sum_recall_malicious + float(line.split(",")[4])
                        sum_number_iterations = sum_number_iterations + float(line.split(",")[5])
                origin_file.close()
                os.remove(output_logfiles_seed + file_id + '_clustering_performance.dat') 

            if sum_number_iterations > 0:
                average_purity = sum_purities/sum_number_iterations
                average_true_negative_rate = sum_true_negative_rates/sum_number_iterations
                average_true_positive_rate = sum_true_positive_rates/sum_number_iterations
                average_recall_benign = sum_recall_benign/sum_number_iterations
                average_recall_malicious = sum_recall_malicious/sum_number_iterations
                clustering_performance_collector_file.write(str(configuration) + "," + str(average_purity) + "," + str(average_true_negative_rate) + "," + str(average_true_positive_rate) + "," + str(average_recall_benign) + "," + str(average_recall_malicious) + "\n")
            clustering_performance_collector_file.close()

            # We merge all the individual time logs for the simulation, if time logging is enabled
            if clustering_performance_time_logging == "True":

                clustering_performance_time_file_name = output_logfiles_seed + configuration + '_clustering_performance_time.dat'
                if input_pcap_range_enabled == "True":

                    # We create the new file and merge all individual ones
                    clustering_performance_time_file = open(clustering_performance_time_file_name, 'w')
                    for file_name in input_pcap_list:
                        file_id = file_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                        origin_file = open(output_logfiles_seed + file_id + '_clustering_performance_time.dat', 'r')

                        for line in origin_file.readlines():
                            clustering_performance_time_file.write(line)
                        origin_file.close()
                        os.remove(output_logfiles_seed + file_id + '_clustering_performance_time.dat') 
                    clustering_performance_time_file.close()
                else:
                    # We just change the name of the output file to include the configuration info
                    os.system("mv " + output_logfiles_seed + "_clustering_performance_time.dat " + clustering_performance_time_file)

        # We now need to merge all the individual log files
        if priority_performance_logging == "True":
            print('Merging the general priority performance logs on a file...')
            
            # We generate the name of the overall purity log
            priority_performance_collector_file = open(output_logfiles_seed + "priority_performance_logs.dat", 'a')
            print(str(output_logfiles_seed) + "priority_performance_logs.dat")

            # We create a summary of the configuration used
            configuration = sys.argv[9]
            for arg_id in range(10,18):
                if arg_id != 13:
                    configuration = configuration + '_' + sys.argv[arg_id]
            for feature in feature_set.split(","):
                configuration = configuration + '_' + feature
            if normalize_feature_values == "True":
                configuration = configuration + '_normalized'

            list_possible_attacks = ["NTP","DNS","LDAP","MSSQL","NetBIOS","SNMP","SSDP","UDP","UDPLag","SYN","TFTP"]
            if (input_pcap_time_start in list_possible_attacks):
                configuration = input_pcap_time_start + configuration

            # We summarize the general performance statistics
            sum_scores = 0
            sum_number_iterations_score = 0
            
            for file_name in input_pcap_list:
                file_id = file_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                origin_file = open(output_logfiles_seed + file_id + '_priority_performance.dat', 'r')

                for line in origin_file.readlines():
                    if line.split(",")[0] != "#Sum_Scores" and line.split(",")[0] != "" and line.split(",")[0] != "\n":
                        sum_scores = sum_scores + float(line.split(",")[0])
                        sum_number_iterations_score = sum_number_iterations_score + float(line.split(",")[1])
                origin_file.close()
                os.remove(output_logfiles_seed + file_id + '_priority_performance.dat')

            if sum_number_iterations_score > 0:
                average_score = sum_scores/sum_number_iterations_score
                priority_performance_collector_file.write(str(configuration) + "," + str(average_score) + "\n")
            priority_performance_collector_file.close()

            # We merge all the individual time logs for the simulation, if time logging is enabled
            if priority_performance_time_logging == "True":

                priority_performance_time_file_name = output_logfiles_seed + configuration + '_priority_performance_time.dat'
                if input_pcap_range_enabled == "True":

                    # We create the new file and merge all individual ones
                    priority_performance_time_file = open(priority_performance_time_file_name, 'w')
                    for file_name in input_pcap_list:
                        file_id = file_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                        origin_file = open(output_logfiles_seed + file_id + '_priority_performance_time.dat', 'r')

                        for line in origin_file.readlines():
                            priority_performance_time_file.write(line)
                        origin_file.close()
                        os.remove(output_logfiles_seed + file_id + '_priority_performance_time.dat') 
                    priority_performance_time_file.close()
                else:
                    # We just change the name of the output file to include the configuration info
                    os.system("mv " + output_logfiles_seed + "_priority_performance_time.dat " + priority_performance_time_file)

        # We merge all the throughput logging files, if throughput logging is enabled
        if throughput_logging == "True":

            # We create a summary of the configuration used
            configuration = sys.argv[9]
            for arg_id in range(10,18):
                if arg_id != 13:
                    configuration = configuration + '_' + sys.argv[arg_id]
            for feature in feature_set.split(","):
                configuration = configuration + '_' + feature
            if normalize_feature_values == "True":
                configuration = configuration + '_normalized'

            throughput_file_name = output_logfiles_seed + configuration + '_throughput.dat'
            if input_pcap_range_enabled == "True":

                # We create the new file and merge all individual ones
                throughput_file = open(throughput_file_name, 'w')
                for file_name in input_pcap_list:
                    file_id = file_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                    origin_file = open(output_logfiles_seed + file_id + '_throughput.dat', 'r')

                    for line in origin_file.readlines():
                        throughput_file.write(line)
                    origin_file.close()
                    os.remove(output_logfiles_seed + file_id + '_throughput.dat') 
                throughput_file.close()

            else:
                os.system("mv " + output_logfiles_seed + "_throughput.dat " + throughput_file_name)

        # We merge all the priorities throughput logging files, if throughput logging is enabled
        if throughput_priorities_logging == "True":
            
            # We create a summary of the configuration used
            configuration = sys.argv[9]
            for arg_id in range(10,18):
                if arg_id != 13:
                    configuration = configuration + '_' + sys.argv[arg_id]
            for feature in feature_set.split(","):
                configuration = configuration + '_' + feature
            if normalize_feature_values == "True":
                configuration = configuration + '_normalized'

            throughput_priorities_file_name = output_logfiles_seed + configuration + '_throughput_priorities.dat'
            if input_pcap_range_enabled == "True":

                # We create the new file and merge all individual ones
                throughput_priorities_file = open(throughput_priorities_file_name, 'w')
                for file_name in input_pcap_list:
                    file_id = file_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                    origin_file = open(output_logfiles_seed + file_id + '_throughput_priorities.dat', 'r')

                    for line in origin_file.readlines():
                        throughput_priorities_file.write(line)
                    origin_file.close()
                    os.remove(output_logfiles_seed + file_id + '_throughput_priorities.dat') 
                throughput_priorities_file.close()

            else:
                os.system("mv " + output_logfiles_seed + "_throughput_priorities.dat " + throughput_priorities_file_name)

        # We merge all the individual pcap files (since Netbench needs to read them sequentially)
        if output_pcap == "True":
            
            # We create a summary of the configuration used
            configuration = sys.argv[9]
            for arg_id in range(10,18):
                if arg_id != 13:
                    configuration = configuration + '_' + sys.argv[arg_id]
            for feature in feature_set.split(","):
                configuration = configuration + '_' + feature
            if normalize_feature_values == "True":
                configuration = configuration + '_normalized'
            
            if input_pcap_range_enabled == "True":
                configuration = configuration + "_" + str(input_pcap_range_init) + "_" + str(input_pcap_range_end)

            print('Merging the output pcaps on a file...')
            output_file_name = output_pcap_seed + configuration + '_output.pcap'
            if input_pcap_range_enabled == "True":

                write_file_aggregated = open(output_file_name, 'wb')
                pcap_writer_aggregated = dpkt.pcap.Writer(write_file_aggregated)

                for file_name in input_pcap_list:
                    file_id = file_name.split('DDoS2019/SAT-01-12-2018_0')[1]
                    read_file_aggregated = open(output_pcap_seed + file_id + 'output.pcap', 'rb')
                    pcap_reader_aggregated = dpkt.pcap.Reader(read_file_aggregated)

                    # Every time a new packet is received, it creates a new (virtual) cluster
                    for timestamp, buf in pcap_reader_aggregated:
                        pcap_writer_aggregated.writepkt(buf, timestamp)
                    
                    read_file_aggregated.close()
                    os.remove(output_pcap_seed + file_id + 'output.pcap') 

                write_file_aggregated.close()
            
            else:
                # We add the configuration too the name
                os.system("mv " + output_pcap_seed + "output.pcap " + output_file_name)
                print("Results saved in: " + output_file_name)

            # We fix possible broken packets in the resulting pcap so that Netbench can easily read them
            os.system('pcapfix ' + output_file_name)

            # We make sure the format is pcap and not pcapng
            #os.system('editcap -F libpcap ' + (output_file_name.split(".pcap")[0] + '_fixed.pcap') + ' ../netbench_ddos/pcap/' + output_file_name.split(".pcap")[0] + '_input_netbench.pcap')