# RUN WITH PYTHON 3 !!! OTHERWISE THE apply_async DOES NOT WORK !!!
import sys
import os 

if __name__ == '__main__':

    if len(sys.argv) != 2: 
        print("Syntax reguired: analyze_priority_performance_results.py name_analysis")
    else:

        ###################
        # Num clusters
        ###################

        if (sys.argv[1] == "numclusters"):

            output_file_numclusters_score = open('python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_numclusters_score.dat', 'w')
            
            # We initialize the file
            output_file_numclusters_score.write("#    Range_Exhaustive_Anime    Range_Exhaustive_Manhattan    Representative_Exhaustive    Range_Fast_Anime    Range_Fast_Manhattan    Representative_Fast\n")

            for num_clusters in range(2,11,2): # num_clusters = 2,4,6,8,10
                average_score_range_exhaustive_anime = ""
                average_score_range_exhaustive_manhattan = ""
                average_score_representative_exhaustive = ""
                average_score_range_fast_anime = ""
                average_score_range_fast_manhattan = ""
                average_score_representative_fast = ""

                input_file = open('python/ddos-aid/performance_evaluation/performance_prioritization_logs_old.dat', 'r')
                for line in input_file.readlines():
                    if ("Online_Range_Exhaustive_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_range_exhaustive_anime = line.split(",")[1].split("\n")[0]
                    elif ("Online_Range_Exhaustive_Manhattan_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_range_exhaustive_manhattan = line.split(",")[1].split("\n")[0]
                    elif ("Online_Representative_Exhaustive_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_representative_exhaustive = line.split(",")[1].split("\n")[0]
                    elif ("Online_Range_Fast_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_range_fast_anime = line.split(",")[1].split("\n")[0]
                    elif ("Online_Range_Fast_Manhattan_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_range_fast_manhattan = line.split(",")[1].split("\n")[0]
                    elif ("Online_Representative_Fast_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_representative_fast = line.split(",")[1].split("\n")[0]

                output_file_numclusters_score.write(str(num_clusters) + "    " + average_score_range_exhaustive_anime + "    " + average_score_range_exhaustive_manhattan + "    " + average_score_representative_exhaustive + "    " + average_score_range_fast_anime + "    " + average_score_range_fast_manhattan + "    " + average_score_representative_fast + "\n")
                input_file.close()

            output_file_numclusters_score.close()



        ###################
        # Extended Num clusters
        ###################

        if (sys.argv[1] == "extended_numclusters"):

            output_file_extended_numclusters_score = open('python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_score.dat', 'w')

            # We initialize the file
            output_file_extended_numclusters_score.write("#    Random    Range_Exhaustive_Anime    Range_Fast_Anime    Representative_Exhaustive    Representative_Fast    Representative_Fast_Initialized    Representative_Exhaustive_Initialized    Offline_KMeans\n")

            for num_clusters in [2,4,6,8,10]:

                # We initialize all the values to zero (which is the value we will keep not to plot the non-existing results)
                average_score_range_exhaustive = 0
                average_score_range_fast = 0
                average_score_representative_exhaustive = 0
                average_score_representative_fast = 0
                average_score_random = 0
                average_score_representative_fast_initialized = 0
                average_score_representative_exhaustive_initialized = 0
                average_score_offlinekmeans = 0

                input_file = open('python/ddos-aid/performance_evaluation/performance_prioritization_logs_old.dat', 'r')
                for line in input_file.readlines():
                    if ("Online_Random_Fast_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_random = line.split(",")[1].split("\n")[0]

                    elif ("Online_Range_Exhaustive_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_range_exhaustive = line.split(",")[1].split("\n")[0]
            
                    elif ("Online_Range_Fast_Anime_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_range_fast = line.split(",")[1].split("\n")[0]       
            
                    elif ("Online_Representative_Exhaustive_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_representative_exhaustive = line.split(",")[1].split("\n")[0]           
            
                    elif ("Online_Representative_Fast_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_representative_fast = line.split(",")[1].split("\n")[0]       

                    elif ("Online_Representative_Fast_Offline-Centroid-Initialization_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_representative_fast_initialized = line.split(",")[1].split("\n")[0]            
            
                    elif ("Online_Representative_Exhaustive_Offline-Centroid-Initialization_" + str(num_clusters) + "_60_0.3_False_Throughput_0.001_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_representative_exhaustive_initialized = line.split(",")[1].split("\n")[0]      

                    elif ("Offline_KMeans_" + str(num_clusters) + "_60_0.3_False_Throughput_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport") in line:
                        average_score_offlinekmeans = line.split(",")[1].split("\n")[0]    

                output_file_extended_numclusters_score.write(str(num_clusters) + "    " + str(average_score_random) + "    " + str(average_score_range_exhaustive) + "    " + str(average_score_range_fast) + "    " + str(average_score_representative_exhaustive) + "    " + str(average_score_representative_fast) + "    " + str(average_score_representative_fast_initialized) + "    " + str(average_score_representative_exhaustive_initialized) + "    " + str(average_score_offlinekmeans) + "\n")
                input_file.close()

            output_file_extended_numclusters_score.close()