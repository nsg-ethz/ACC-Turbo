# RUN WITH PYTHON 3 !!! OTHERWISE THE apply_async DOES NOT WORK !!!
import sys
import os 

if __name__ == '__main__':

    ###################
    # Num clusters
    ###################

    output_file_numclusters_purity = open('python/plots/num_clusters/numclusters_purity.dat', 'w')
    output_file_numclusters_recall_benign = open('python/plots/num_clusters/numclusters_recall_benign.dat', 'w')
    output_file_numclusters_recall_malicious = open('python/plots/num_clusters/numclusters_recall_malicious.dat', 'w')

    # We initialize the file
    output_file_numclusters_purity.write("#    Range_Exhaustive_Anime    Range_Exhaustive_Manhattan    Representative_Exhaustive    Range_Fast_Anime    Range_Fast_Manhattan    Representative_Fast    Representative_Fast_Initialized    Offline_kMeans\n")
    output_file_numclusters_recall_benign.write("#    Range_Exhaustive_Anime    Range_Exhaustive_Manhattan    Representative_Exhaustive    Range_Fast_Anime    Range_Fast_Manhattan    Representative_Fast    Representative_Fast_Initialized    Offline_kMeans\n")
    output_file_numclusters_recall_malicious.write("#    Range_Exhaustive_Anime    Range_Exhaustive_Manhattan    Representative_Exhaustive    Range_Fast_Anime    Range_Fast_Manhattan    Representative_Fast    Representative_Fast_Initialized    Offline_kMeans\n")

    for num_clusters in range(2,11,2): # num_clusters = 2,4,6,8,10
        average_purity_range_exhaustive_anime = ""
        average_purity_range_exhaustive_manhattan = ""
        average_purity_representative_exhaustive = ""
        average_purity_range_fast_anime = ""
        average_purity_range_fast_manhattan = ""
        average_purity_representative_fast = ""
        average_purity_representative_fast_initialized = ""
        average_purity_offlinekmeans = ""

        average_recall_benign_range_exhaustive_anime = ""
        average_recall_benign_range_exhaustive_manhattan = ""
        average_recall_benign_representative_exhaustive = ""
        average_recall_benign_range_fast_anime = ""
        average_recall_benign_range_fast_manhattan = ""
        average_recall_benign_representative_fast = ""
        average_recall_benign_representative_fast_initialized = ""
        average_recall_benign_offlinekmeans = ""

        average_recall_malicious_range_exhaustive_anime = ""
        average_recall_malicious_range_exhaustive_manhattan = ""
        average_recall_malicious_representative_exhaustive = ""
        average_recall_malicious_range_fast_anime = ""
        average_recall_malicious_range_fast_manhattan = ""
        average_recall_malicious_representative_fast = "" 
        average_recall_malicious_representative_fast_initialized = ""
        average_recall_malicious_offlinekmeans = ""

        input_file = open('python/plots/num_clusters/clustering_performance_logs.dat', 'r')
        for line in input_file.readlines():
            if ("Online_Range_Fast_Manhattan_" + str(num_clusters) + "_60_0.3_False_Throughput_-1_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                average_purity_range_fast_manhattan = line.split(",")[1]
                average_recall_benign_range_fast_manhattan = line.split(",")[4]
                average_recall_malicious_range_fast_manhattan = line.split(",")[5].split("\n")[0]      
    
            elif ("Online_Representative_Fast_" + str(num_clusters) + "_60_0.3_False_Throughput_-1_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                average_purity_representative_fast = line.split(",")[1]
                average_recall_benign_representative_fast = line.split(",")[4]
                average_recall_malicious_representative_fast = line.split(",")[5].split("\n")[0]    

            elif ("Online_Range_Fast_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_-1_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                average_purity_range_fast_anime = line.split(",")[1]
                average_recall_benign_range_fast_anime = line.split(",")[4]
                average_recall_malicious_range_fast_anime = line.split(",")[5].split("\n")[0]                

            elif ("Online_Range_Exhaustive_Manhattan_" + str(num_clusters) + "_60_0.3_False_Throughput_-1_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                average_purity_range_exhaustive_manhattan = line.split(",")[1]
                average_recall_benign_range_exhaustive_manhattan = line.split(",")[4]
                average_recall_malicious_range_exhaustive_manhattan = line.split(",")[5].split("\n")[0]

            elif ("Online_Representative_Exhaustive_" + str(num_clusters) + "_60_0.3_False_Throughput_-1_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                average_purity_representative_exhaustive = line.split(",")[1]
                average_recall_benign_representative_exhaustive = line.split(",")[4]
                average_recall_malicious_representative_exhaustive = line.split(",")[5].split("\n")[0]                  

            elif ("Online_Range_Exhaustive_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_-1_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                average_purity_range_exhaustive_anime = line.split(",")[1]
                average_recall_benign_range_exhaustive_anime = line.split(",")[4]
                average_recall_malicious_range_exhaustive_anime = line.split(",")[5].split("\n")[0]

            elif ("Online_Representative_Fast_Offline-Centroid-Initialization_" + str(num_clusters) + "_60_0.3_False_Throughput_-1_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                average_purity_representative_fast_initialized = line.split(",")[1]
                average_recall_benign_representative_fast_initialized = line.split(",")[4]
                average_recall_malicious_representative_fast_initialized = line.split(",")[5].split("\n")[0]              
    
            elif ("Offline_KMeans_" + str(num_clusters) + "_60_0.3_False_Throughput_-1_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len") in line:
                average_purity_offlinekmeans = line.split(",")[1]
                average_recall_benign_offlinekmeans = line.split(",")[4]
                average_recall_malicious_offlinekmeans = line.split(",")[5].split("\n")[0]      

        output_file_numclusters_purity.write(str(num_clusters) + "    " + average_purity_range_exhaustive_anime + "    " + average_purity_range_exhaustive_manhattan + "    " + average_purity_representative_exhaustive + "    " + average_purity_range_fast_anime + "    " + average_purity_range_fast_manhattan + "    " + average_purity_representative_fast + "    " + average_purity_representative_fast_initialized + "    " + average_purity_offlinekmeans + "\n")
        output_file_numclusters_recall_benign.write(str(num_clusters) + "    " + average_recall_benign_range_exhaustive_anime + "    " + average_recall_benign_range_exhaustive_manhattan + "    " + average_recall_benign_representative_exhaustive + "    " + average_recall_benign_range_fast_anime + "    " + average_recall_benign_range_fast_manhattan + "    " + average_recall_benign_representative_fast + "    " + average_recall_benign_representative_fast_initialized + "    " + average_recall_benign_offlinekmeans + "\n")
        output_file_numclusters_recall_malicious.write(str(num_clusters) + "    " + average_recall_malicious_range_exhaustive_anime + "    " + average_recall_malicious_range_exhaustive_manhattan + "    " + average_recall_malicious_representative_exhaustive + "    " + average_recall_malicious_range_fast_anime + "    " + average_recall_malicious_range_fast_manhattan + "    " + average_recall_malicious_representative_fast + "    " + average_recall_malicious_representative_fast_initialized + "    " + average_recall_malicious_offlinekmeans + "\n")
        input_file.close()

    output_file_numclusters_purity.close()
    output_file_numclusters_recall_benign.close()
    output_file_numclusters_recall_malicious.close()