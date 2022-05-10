#!/bin/bash

echo -e "Executed morphing_attack.sh"

# #############
# Attack generation
# #############

# Generate the attack trace
#python3 python/attack_generation/pcap_attack_generation/multiple_attack_generation.py

# #############
# Print the throughput of the original and the one with attack (to compare)
# #############

#python3 python/attack_generation/analyze_created_attacks/plot_throughput.py 'pcaps/carpet_bombing/carpet_bombing_baseline.pcap' 'python/attack_generation/analyze_created_attacks/carpet_bombing_baseline_throughput.dat'
#python3 python/attack_generation/analyze_created_attacks/plot_throughput.py 'pcaps/carpet_bombing/carpet_bombing_attack.pcap' 'python/attack_generation/analyze_created_attacks/carpet_bombing_attack_throughput.dat'
#gnuplot -e "baseline_file='python/attack_generation/analyze_created_attacks/carpet_bombing_baseline_throughput.dat';attack_file='python/attack_generation/analyze_created_attacks/carpet_bombing_attack_throughput.dat';output_file='python/attack_generation/analyze_created_attacks/throughput.pdf'" python/attack_generation/analyze_created_attacks/plot_throughput.gnuplot

##############
# Run the clustering algorithm
##############

# Input-file configuration
SIMULATION_ID="CarpetBombing"                         #(String) CICDDoS2019, Morphing (used to define e.g., where can the ground truth be found)
INPUT_PCAP_SEED="pcaps/carpet_bombing/baseline.pcap"
INPUT_PCAP_RANGE_ENABLED="False"
INPUT_PCAP_RANGE_INIT=0                             #(Int)
INPUT_PCAP_RANGE_END=0                              #(Int)
INPUT_PCAP_TIME_ADJUSTMENT="None"                   #(String) Add/Remove,hours  # There is a difference of 5h with respect to UTC in that dataset
INPUT_PCAP_TIME_START="None"
INPUT_PCAP_TIME_END="None"
#INPUT_PCAP_TIME_START="2018,12,1,10,52,00,000000"   #(String) To only analyze a fragment of the whole pcap. "" to use all
#INPUT_PCAP_TIME_END="2018,12,1,11,5,00,000000"   

# Clustering-algorithm configuration
CLUSTERING_TYPE="Online_Hash"          #(String)  "Online_Range_Fast_Manhattan", "Online_Range_Fast_Anime", "Online_Range_Exhaustive_Manhattan", "Online_Range_Exhaustive_Anime", "Online_Representative_Fast", "Online_Representative_Exhaustive", "Offline_KMeans", "Online_Random_Fast", "Online_Representative_Exhaustive_Offline-Centroid-Initialization", "Online_Representative_Fast_Offline-Centroid-Initialization", "Online_Hash"
NUM_CLUSTERS=256                                #(Integer) Can be set to 1 to measure the overall throughput
RESET_CLUSTERS=1                                #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
LEARNING_RATE=0.3                               #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
FEATURE_SET="proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"  #(String) Complete if "len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"
NORMALIZE_FEATURE_VALUES="False"

# PRIORITIZATION CONFIGURATION
PRIORITIZING_TYPE="Throughput"                  #(String) "Throughput", "Numpackets", "Size", "ThroughputXSize", "Entropy"
UPDATE_PRIORITIES_WINDOW=0.001                  #(Float) Seconds. If the window is 0, the priorities will be updated per packet (ideal). 0.001 also works well

# Logging configuration
MONITORING_WINDOW=1                             #(Float)   Monitoring window (in seconds)
THROUGHPUT_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_LOGGING="True"
TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING="True"
CLUSTERING_PERFORMANCE_LOGGING="False"
CLUSTERING_PERFORMANCE_TIME_LOGGING="False"     #(String)  "True" or "False" depending on whether we want to keep track of all the purities/true_positive/true_negative/recalls and J computed along the simulation
PRIORITY_PERFORMANCE_LOGGING="False"
PRIORITY_PERFORMANCE_TIME_LOGGING="False"       #(String)  "True" or "False" depending on whether we want to keep track of all the purities/true_positive/true_negative/recalls and J computed along the simulation
THROUGHPUT_PRIORITIES_LOGGING="False"
SIGNATURE_EVALUATION_LOGGING="False"

# Output logfiles configuration  
OUTPUT_LOGFILES_SEED="python/ddos-aid/carpet_bombing_results/hash/"
OUTPUT_PCAP="False"
OUTPUT_PCAP_SEED="pcaps/carpet_bombing/"
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

# #############
# Plot histograms
# #############

#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_0.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_0.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_6.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_6.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_11.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_11.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_16.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_16.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_21.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_21.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_25.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_benign_25.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot

#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_0.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_0.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_6.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_6.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_11.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_11.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_16.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_16.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_21.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_21.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_25.dat'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_distrib_histogram_malicious_25.pdf'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms.gnuplot

# #############
# Plot distributions
# #############

#gnuplot -e "src='pcaps/morphing_attack/dst3_distrib_0.dat'; dst='pcaps/morphing_attack/dst3_distrib_0.pdf'" pcaps/morphing_attack/plot_distributions.gnuplot
#gnuplot -e "src='pcaps/morphing_attack/dst3_distrib_6.dat'; dst='pcaps/morphing_attack/dst3_distrib_6.pdf'" pcaps/morphing_attack/plot_distributions.gnuplot
#gnuplot -e "src='pcaps/morphing_attack/dst3_distrib_11.dat'; dst='pcaps/morphing_attack/dst3_distrib_11.pdf'" pcaps/morphing_attack/plot_distributions.gnuplot
#gnuplot -e "src='pcaps/morphing_attack/dst3_distrib_16.dat'; dst='pcaps/morphing_attack/dst3_distrib_16.pdf'" pcaps/morphing_attack/plot_distributions.gnuplot
#gnuplot -e "src='pcaps/morphing_attack/dst3_distrib_21.dat'; dst='pcaps/morphing_attack/dst3_distrib_21.pdf'" pcaps/morphing_attack/plot_distributions.gnuplot
#gnuplot -e "src='pcaps/morphing_attack/dst3_distrib_25.dat'; dst='pcaps/morphing_attack/dst3_distrib_25.pdf'" pcaps/morphing_attack/plot_distributions.gnuplot

# #############
# Signature and time-performance evaluation
# #############

#gnuplot -e "path='python/ddos-aid/morphing_attack_results/online_representative_fast/';feature='dst3'" python/ddos-aid/morphing_attack_results/plot_signature_evaluation.gnuplot
#gnuplot -e "path='python/ddos-aid/morphing_attack_results/online_representative_fast/'" python/ddos-aid/morphing_attack_results/plot_performance_time.gnuplot

#gnuplot -e "path='python/ddos-aid/morphing_attack_results/online_range_fast_anime/';feature='dst3'" python/ddos-aid/morphing_attack_results/plot_signature_evaluation.gnuplot
#gnuplot -e "path='python/ddos-aid/morphing_attack_results/online_range_fast_anime/'" python/ddos-aid/morphing_attack_results/plot_performance_time.gnuplot

#gnuplot -e "path='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan/';feature='dst3'" python/ddos-aid/morphing_attack_results/plot_signature_evaluation.gnuplot
#gnuplot -e "path='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan/'" python/ddos-aid/morphing_attack_results/plot_performance_time.gnuplot

# #############
# Execution Netbench
# #############

#cd netbench_ddos
#mvn clean compile assembly:single
#cd ..

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_fifo.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_ground_truth.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_range_fast_anime.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_representative_fast.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_range_fast_manhattan.properties

# #############
# Analysis throughput
# #############

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_fifo
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_fifo" "morphing_analysis/attack_fifo"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_fifo/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_ground_truth
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_ground_truth" "morphing_analysis/attack_pifo_ground_truth"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_ground_truth/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_anime
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_range_fast_anime" "morphing_analysis/attack_pifo_range_fast_anime"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_anime/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_representative_fast
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_representative_fast" "morphing_analysis/attack_pifo_representative_fast"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_representative_fast/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_manhattan
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_range_fast_manhattan" "morphing_analysis/attack_pifo_range_fast_manhattan"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_manhattan/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot