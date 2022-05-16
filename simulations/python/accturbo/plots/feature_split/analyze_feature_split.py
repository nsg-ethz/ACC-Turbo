# RUN WITH PYTHON 3 !!! OTHERWISE THE apply_async DOES NOT WORK !!!
import sys
import os 

if __name__ == '__main__':

    if len(sys.argv) != 2: 
        print("Syntax reguired: analyze_clustering_performance_results.py name_analysis")
    else:

        ###################
        # Num clusters
        ###################

        if (sys.argv[1] == "numclusters"):

            output_file_numclusters_purity = open('python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_purity.dat', 'w')
            output_file_numclusters_recall_benign = open('python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_recall_benign.dat', 'w')
            output_file_numclusters_recall_malicious = open('python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_recall_malicious.dat', 'w')

            # We initialize the file
            output_file_numclusters_purity.write("#    Range_Exhaustive_Anime    Range_Exhaustive_Manhattan    Representative_Exhaustive    Range_Fast_Anime    Range_Fast_Manhattan    Representative_Fast\n")
            output_file_numclusters_recall_benign.write("#    Range_Exhaustive_Anime    Range_Exhaustive_Manhattan    Representative_Exhaustive    Range_Fast_Anime    Range_Fast_Manhattan    Representative_Fast\n")
            output_file_numclusters_recall_malicious.write("#    Range_Exhaustive_Anime    Range_Exhaustive_Manhattan    Representative_Exhaustive    Range_Fast_Anime    Range_Fast_Manhattan    Representative_Fast\n")

            for num_clusters in range(2,11,2): # num_clusters = 2,4,6,8,10
                average_purity_range_exhaustive_anime = ""
                average_purity_range_exhaustive_manhattan = ""
                average_purity_representative_exhaustive = ""
                average_purity_range_fast_anime = ""
                average_purity_range_fast_manhattan = ""
                average_purity_representative_fast = ""

                average_recall_benign_range_exhaustive_anime = ""
                average_recall_benign_range_exhaustive_manhattan = ""
                average_recall_benign_representative_exhaustive = ""
                average_recall_benign_range_fast_anime = ""
                average_recall_benign_range_fast_manhattan = ""
                average_recall_benign_representative_fast = ""

                average_recall_malicious_range_exhaustive_anime = ""
                average_recall_malicious_range_exhaustive_manhattan = ""
                average_recall_malicious_representative_exhaustive = ""
                average_recall_malicious_range_fast_anime = ""
                average_recall_malicious_range_fast_manhattan = ""
                average_recall_malicious_representative_fast = "" 

                input_file = open('python/ddos-aid/performance_evaluation_last/clustering_performance_logs.dat', 'r')
                for line in input_file.readlines():
                    if ("Online_Range_Exhaustive_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                        average_purity_range_exhaustive_anime = line.split(",")[1]
                        average_recall_benign_range_exhaustive_anime = line.split(",")[4]
                        average_recall_malicious_range_exhaustive_anime = line.split(",")[5].split("\n")[0]

                    elif ("Online_Range_Exhaustive_Manhattan_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                        average_purity_range_exhaustive_manhattan = line.split(",")[1]
                        average_recall_benign_range_exhaustive_manhattan = line.split(",")[4]
                        average_recall_malicious_range_exhaustive_manhattan = line.split(",")[5].split("\n")[0]

                    elif ("Online_Representative_Exhaustive_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                        average_purity_representative_exhaustive = line.split(",")[1]
                        average_recall_benign_representative_exhaustive = line.split(",")[4]
                        average_recall_malicious_representative_exhaustive = line.split(",")[5].split("\n")[0]                  

                    elif ("Online_Range_Fast_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                        average_purity_range_fast_anime = line.split(",")[1]
                        average_recall_benign_range_fast_anime = line.split(",")[4]
                        average_recall_malicious_range_fast_anime = line.split(",")[5].split("\n")[0]                
            
                    elif ("Online_Range_Fast_Manhattan_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                        average_purity_range_fast_manhattan = line.split(",")[1]
                        average_recall_benign_range_fast_manhattan = line.split(",")[4]
                        average_recall_malicious_range_fast_manhattan = line.split(",")[5].split("\n")[0]      
            
                    elif ("Online_Representative_Fast_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                        average_purity_representative_fast = line.split(",")[1]
                        average_recall_benign_representative_fast = line.split(",")[4]
                        average_recall_malicious_representative_fast = line.split(",")[5].split("\n")[0]      

                output_file_numclusters_purity.write(str(num_clusters) + "    " + average_purity_range_exhaustive_anime + "    " + average_purity_range_exhaustive_manhattan + "    " + average_purity_representative_exhaustive + "    " + average_purity_range_fast_anime + "    " + average_purity_range_fast_manhattan + "    " + average_purity_representative_fast + "\n")
                output_file_numclusters_recall_benign.write(str(num_clusters) + "    " + average_recall_benign_range_exhaustive_anime + "    " + average_recall_benign_range_exhaustive_manhattan + "    " + average_recall_benign_representative_exhaustive + "    " + average_recall_benign_range_fast_anime + "    " + average_recall_benign_range_fast_manhattan + "    " + average_recall_benign_representative_fast + "\n")
                output_file_numclusters_recall_malicious.write(str(num_clusters) + "    " + average_recall_malicious_range_exhaustive_anime + "    " + average_recall_malicious_range_exhaustive_manhattan + "    " + average_recall_malicious_representative_exhaustive + "    " + average_recall_malicious_range_fast_anime + "    " + average_recall_malicious_range_fast_manhattan + "    " + average_recall_malicious_representative_fast + "\n")
                input_file.close()

            output_file_numclusters_purity.close()
            output_file_numclusters_recall_benign.close()
            output_file_numclusters_recall_malicious.close()


        elif (sys.argv[1] == "extended_numclusters"):

            ###################
            # Extended Num clusters
            ###################

            # We add here three more types (Random, Representative_Fast_Initialized, Representative_Exhaustive_Initialized, Offline_KMeans)

            output_file_extended_numclusters_purity = open('python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_purity.dat', 'w')
            output_file_extended_numclusters_recall_benign = open('python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_recall_benign.dat', 'w')
            output_file_extended_numclusters_recall_malicious = open('python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_recall_malicious.dat', 'w')

            # We initialize the file
            output_file_extended_numclusters_purity.write("#    Random    Range_Exhaustive_Anime    Range_Fast_Anime    Representative_Exhaustive    Representative_Fast    Representative_Fast_Initialized    Representative_Exhaustive_Initialized    Offline_KMeans\n")
            output_file_extended_numclusters_recall_benign.write("#    Random    Range_Exhaustive_Anime    Range_Fast_Anime    Representative_Exhaustive    Representative_Fast    Representative_Fast_Initialized    Representative_Exhaustive_Initialized    Offline_KMeans\n")
            output_file_extended_numclusters_recall_malicious.write("#    Random    Range_Exhaustive_Anime    Range_Fast_Anime    Representative_Exhaustive    Representative_Fast    Representative_Fast_Initialized    Representative_Exhaustive_Initialized    Offline_KMeans\n")

            #for num_clusters in [1,2,4,6,8,10]:
            for num_clusters in [2,4,6,8,10]:

                # We initialize all the values to zero (which is the value we will keep not to plot the non-existing results)
                average_purity_range_exhaustive = 0
                average_purity_range_fast = 0
                average_purity_representative_exhaustive = 0
                average_purity_representative_fast = 0
                average_purity_random = 0
                average_purity_representative_fast_initialized = 0
                average_purity_representative_exhaustive_initialized = 0
                average_purity_offlinekmeans = 0

                average_recall_benign_range_exhaustive = 0
                average_recall_benign_range_fast = 0
                average_recall_benign_representative_exhaustive = 0
                average_recall_benign_representative_fast = 0
                average_recall_benign_random = 0
                average_recall_benign_representative_fast_initialized = 0
                average_recall_benign_representative_exhaustive_initialized = 0
                average_recall_benign_offlinekmeans = 0

                average_recall_malicious_range_exhaustive = 0
                average_recall_malicious_range_fast = 0
                average_recall_malicious_representative_exhaustive = 0
                average_recall_malicious_representative_fast = 0       
                average_recall_malicious_random = 0
                average_recall_malicious_representative_fast_initialized = 0
                average_recall_malicious_representative_exhaustive_initialized = 0
                average_recall_malicious_offlinekmeans = 0

                input_file = open('python/ddos-aid/performance_evaluation/clustering_performance_logs.dat', 'r')
                for line in input_file.readlines():
                    if ("Online_Random_Fast_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_purity_random = line.split(",")[1]
                        average_recall_benign_random = line.split(",")[4]
                        average_recall_malicious_random = line.split(",")[5].split("\n")[0]

                    if ("Online_Range_Exhaustive_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_purity_range_exhaustive = line.split(",")[1]
                        average_recall_benign_range_exhaustive = line.split(",")[4]
                        average_recall_malicious_range_exhaustive = line.split(",")[5].split("\n")[0]
            
                    elif ("Online_Range_Fast_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_purity_range_fast = line.split(",")[1]
                        average_recall_benign_range_fast = line.split(",")[4]
                        average_recall_malicious_range_fast = line.split(",")[5].split("\n")[0]                
            
                    elif ("Online_Representative_Exhaustive_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_purity_representative_exhaustive = line.split(",")[1]
                        average_recall_benign_representative_exhaustive = line.split(",")[4]
                        average_recall_malicious_representative_exhaustive = line.split(",")[5].split("\n")[0]              
            
                    elif ("Online_Representative_Fast_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_purity_representative_fast = line.split(",")[1]
                        average_recall_benign_representative_fast = line.split(",")[4]
                        average_recall_malicious_representative_fast = line.split(",")[5].split("\n")[0]      

                    elif ("Online_Representative_Fast_Offline-Centroid-Initialization_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_purity_representative_fast_initialized = line.split(",")[1]
                        average_recall_benign_representative_fast_initialized = line.split(",")[4]
                        average_recall_malicious_representative_fast_initialized = line.split(",")[5].split("\n")[0]              
            
                    elif ("Online_Representative_Exhaustive_Offline-Centroid-Initialization_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_purity_representative_exhaustive_initialized = line.split(",")[1]
                        average_recall_benign_representative_exhaustive_initialized = line.split(",")[4]
                        average_recall_malicious_representative_exhaustive_initialized = line.split(",")[5].split("\n")[0]      

                    elif ("Offline_KMeans_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_purity_offlinekmeans = line.split(",")[1]
                        average_recall_benign_offlinekmeans = line.split(",")[4]
                        average_recall_malicious_offlinekmeans = line.split(",")[5].split("\n")[0]      

                output_file_extended_numclusters_purity.write(str(num_clusters) + "    " + str(average_purity_random) + "    " + str(average_purity_range_exhaustive) + "    " + str(average_purity_range_fast) + "    " + str(average_purity_representative_exhaustive) + "    " + str(average_purity_representative_fast) + "    " + str(average_purity_representative_fast_initialized) + "    " + str(average_purity_representative_exhaustive_initialized) + "    " + str(average_purity_offlinekmeans) + "\n")
                output_file_extended_numclusters_recall_benign.write(str(num_clusters) + "    " + str(average_recall_benign_random) + "    " + str(average_recall_benign_range_exhaustive) + "    " + str(average_recall_benign_range_fast) + "    " + str(average_recall_benign_representative_exhaustive) + "    " + str(average_recall_benign_representative_fast) + "    " + str(average_recall_benign_representative_fast_initialized) + "    " + str(average_recall_benign_representative_exhaustive_initialized) + "    " + str(average_recall_benign_offlinekmeans) + "\n")
                output_file_extended_numclusters_recall_malicious.write(str(num_clusters) + "    " + str(average_recall_malicious_random) + "    " + str(average_recall_malicious_range_exhaustive) + "    " + str(average_recall_malicious_range_fast) + "    " + str(average_recall_malicious_representative_exhaustive) + "    " + str(average_recall_malicious_representative_fast) + "    " + str(average_recall_malicious_representative_fast_initialized) + "    " + str(average_recall_malicious_representative_exhaustive_initialized) + "    " + str(average_recall_malicious_offlinekmeans) + "\n")
                input_file.close()

            output_file_extended_numclusters_purity.close()
            output_file_extended_numclusters_recall_benign.close()
            output_file_extended_numclusters_recall_malicious.close()

        elif (sys.argv[1] == "features"):

            ###################
            # Feature selection
            ###################

            output_file_features_purity = open('plot_features_purity.dat', 'w')
            output_file_features_recall_benign = open('plot_features_recall_benign.dat', 'w')
            output_file_features_recall_malicious = open('plot_features_recall_malicious.dat', 'w')

            # We initialize the file
            output_file_features_purity.write("#    Range_Exhaustive    Range_Fast    Representative_Exhaustive    Representative_Fast\n")
            output_file_features_recall_benign.write("#    Range_Exhaustive    Range_Fast    Representative_Exhaustive    Representative_Fast\n")
            output_file_features_recall_malicious.write("#    Range_Exhaustive    Range_Fast    Representative_Exhaustive    Representative_Fast\n")

            feature_list = ["sport", 
            "sport_dport", 
            "src0_src1_src2_src3", 
            "dst0_dst1_dst2_dst3", 
            "src0_src1_src2_src3_dst0_dst1_dst2_dst3",
            "src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport",
            "src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len",
            "len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport"]

            for features in feature_list:
                average_purity_range_exhaustive = ""
                average_purity_range_fast = ""
                average_purity_representative_exhaustive = ""
                average_purity_representative_fast = ""

                average_recall_benign_range_exhaustive = ""
                average_recall_benign_range_fast = ""
                average_recall_benign_representative_exhaustive = ""
                average_recall_benign_representative_fast = ""

                average_recall_malicious_range_exhaustive = ""
                average_recall_malicious_range_fast = ""
                average_recall_malicious_representative_exhaustive = ""
                average_recall_malicious_representative_fast = ""       

                input_file = open('clustering_performance_logs.dat', 'r')
                for line in input_file.readlines():
                    if ("Online_Range_Exhaustive_10_1_0.3_False_1_" + features) in line:
                        average_purity_range_exhaustive = line.split(",")[1]
                        average_recall_benign_range_exhaustive = line.split(",")[4]
                        average_recall_malicious_range_exhaustive = line.split(",")[5].split("\n")[0]
            
                    elif ("Online_Range_Fast_10_1_0.3_False_1_" + features) in line:
                        average_purity_range_fast = line.split(",")[1]
                        average_recall_benign_range_fast = line.split(",")[4]
                        average_recall_malicious_range_fast = line.split(",")[5].split("\n")[0]                
            
                    elif ("Online_Representative_Exhaustive_10_1_0.3_False_1_" + features) in line:
                        average_purity_representative_exhaustive = line.split(",")[1]
                        average_recall_benign_representative_exhaustive = line.split(",")[4]
                        average_recall_malicious_representative_exhaustive = line.split(",")[5].split("\n")[0]              
            
                    elif ("Online_Representative_Fast_10_1_0.3_False_1_" + features) in line:
                        average_purity_representative_fast = line.split(",")[1]
                        average_recall_benign_representative_fast = line.split(",")[4]
                        average_recall_malicious_representative_fast = line.split(",")[5].split("\n")[0]      

                output_file_features_purity.write(features + "    " + average_purity_range_exhaustive + "    " + average_purity_range_fast + "    " + average_purity_representative_exhaustive + "    " + average_purity_representative_fast + "\n")
                output_file_features_recall_benign.write(features + "    " + average_recall_benign_range_exhaustive + "    " + average_recall_benign_range_fast + "    " + average_recall_benign_representative_exhaustive + "    " + average_recall_benign_representative_fast + "\n")
                output_file_features_recall_malicious.write(features + "    " + average_recall_malicious_range_exhaustive + "    " + average_recall_malicious_range_fast + "    " + average_recall_malicious_representative_exhaustive + "    " + average_recall_malicious_representative_fast + "\n")
                input_file.close()

            output_file_features_purity.close()
            output_file_features_recall_benign.close()
            output_file_features_recall_malicious.close()