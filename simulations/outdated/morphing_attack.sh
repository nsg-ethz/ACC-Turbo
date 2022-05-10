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

#python3 python/attack_generation/analyze_created_attacks/plot_throughput.py 'pcaps/morphing_attack/morphing_tofino_baseline.pcap' 'python/attack_generation/analyze_created_attacks/morphing_tofino_baseline_throughput.dat'
#python3 python/attack_generation/analyze_created_attacks/plot_throughput.py 'pcaps/morphing_attack/morphing_tofino_attack.pcap' 'python/attack_generation/analyze_created_attacks/morphing_tofino_attack_throughput.dat'
#gnuplot -e "baseline_file='python/attack_generation/analyze_created_attacks/morphing_tofino_baseline_throughput.dat';attack_file='python/attack_generation/analyze_created_attacks/morphing_tofino_attack_throughput.dat';output_file='python/attack_generation/analyze_created_attacks/throughput.pdf'" python/attack_generation/analyze_created_attacks/plot_throughput.gnuplot

##############
# Print the heatmap of the attack generated
##############

#python3 python/attack_generation/analyze_created_attacks/plot_heatmap.py 'pcaps/morphing_attack/morphing_tofino_baseline.pcap' 'python/attack_generation/analyze_created_attacks/morphing_tofino_baseline_heatmap.dat'
#gnuplot -e "input_file='python/attack_generation/analyze_created_attacks/morphing_tofino_baseline_heatmap.dat';output_file='python/attack_generation/analyze_created_attacks/morphing_tofino_baseline_heatmap.pdf'" python/attack_generation/analyze_created_attacks/plot_heatmap.gnuplot

#python3 python/attack_generation/analyze_created_attacks/plot_heatmap.py 'pcaps/morphing_attack/morphing_tofino_attack.pcap' 'python/attack_generation/analyze_created_attacks/morphing_tofino_attack_heatmap.dat'
#gnuplot -e "input_file='python/attack_generation/analyze_created_attacks/morphing_tofino_attack_heatmap.dat';output_file='python/attack_generation/analyze_created_attacks/morphing_tofino_attack_heatmap.pdf'" python/attack_generation/analyze_created_attacks/plot_heatmap.gnuplot

##############
# Run the clustering algorithm
##############

# Input-file configuration
SIMULATION_ID="Morphing"                         #(String) CICDDoS2019, Morphing (used to define e.g., where can the ground truth be found)
INPUT_PCAP_SEED="pcaps/morphing_attack/attack.pcap"
INPUT_PCAP_RANGE_ENABLED="False"
INPUT_PCAP_RANGE_INIT=0                             #(Int)
INPUT_PCAP_RANGE_END=0                              #(Int)
INPUT_PCAP_TIME_ADJUSTMENT="None"                   #(String) Add/Remove,hours  # There is a difference of 5h with respect to UTC in that dataset
INPUT_PCAP_TIME_START="None"
INPUT_PCAP_TIME_END="None"
#INPUT_PCAP_TIME_START="2018,12,1,10,52,00,000000"   #(String) To only analyze a fragment of the whole pcap. "" to use all
#INPUT_PCAP_TIME_END="2018,12,1,11,5,00,000000"   

# Clustering-algorithm configuration
CLUSTERING_TYPE="Online_Range_Fast_Manhattan"   #(String)  "Online_Range_Fast_Manhattan", "Online_Range_Fast_Anime", "Online_Range_Exhaustive_Manhattan", "Online_Range_Exhaustive_Anime", "Online_Representative_Fast", "Online_Representative_Exhaustive", "Offline_KMeans", "Online_Random_Fast", "Online_Representative_Exhaustive_Offline-Centroid-Initialization", "Online_Representative_Fast_Offline-Centroid-Initialization"
NUM_CLUSTERS=10                                 #(Integer) Can be set to 1 to measure the overall throughput
RESET_CLUSTERS=1                                #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
LEARNING_RATE=0.3                               #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
FEATURE_SET="len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"               #(String) Complete if "len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"
NORMALIZE_FEATURE_VALUES="False"

# PRIORITIZATION CONFIGURATION
PRIORITIZING_TYPE="Throughput"                  #(String) "Throughput", "Numpackets", "Size", "ThroughputXSize", "Entropy"
UPDATE_PRIORITIES_WINDOW=0                      #(Float) Seconds. If the window is 0, the priorities will be updated per packet (ideal). 0.001 also works well

# Logging configuration
MONITORING_WINDOW=1                             #(Float)   Monitoring window (in seconds)
THROUGHPUT_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING="False"
CLUSTERING_PERFORMANCE_LOGGING="False"
CLUSTERING_PERFORMANCE_TIME_LOGGING="False"     #(String)  "True" or "False" depending on whether we want to keep track of all the purities/true_positive/true_negative/recalls and J computed along the simulation
PRIORITY_PERFORMANCE_LOGGING="False"
PRIORITY_PERFORMANCE_TIME_LOGGING="False"       #(String)  "True" or "False" depending on whether we want to keep track of all the purities/true_positive/true_negative/recalls and J computed along the simulation
THROUGHPUT_PRIORITIES_LOGGING="False"
SIGNATURE_EVALUATION_LOGGING="False"

# Output logfiles configuration  
OUTPUT_LOGFILES_SEED="python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/"
OUTPUT_PCAP="True"
OUTPUT_PCAP_SEED="pcaps/morphing_attack/"
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

#NUM_CLUSTERS=4
#TRAFFIC_DISTRIBUTIONS_LOGGING="True"
#OUTPUT_LOGFILES_SEED="python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_4clusters/"
#python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

# #############
# Plot distributions
# #############

#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_4clusters/'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_4clusters/dst3_distributions'" python/ddos-aid/morphing_attack_results/plot_distributions.gnuplot

# #############
# Plot histograms
# #############

#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_4clusters/'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_4clusters/dst3_histograms'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms_4.gnuplot
#gnuplot -e "src='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/'; dst='python/ddos-aid/morphing_attack_results/online_range_fast_manhattan_dst3_10clusters/dst3_histograms'" python/ddos-aid/morphing_attack_results/plot_distributions_histograms_10.gnuplot

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

cd netbench_ddos
mvn clean compile assembly:single
cd ..

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_fifo.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_ground_truth.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_range_fast_manhattan_4.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_range_fast_manhattan_10.properties
java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_range_fast_manhattan_10_allfeatures.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_range_fast_anime.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/morphing/attack_pifo_representative_fast.properties

# #############
# Analysis throughput
# #############

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_fifo
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_fifo" "morphing_analysis/attack_fifo"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_fifo/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_ground_truth
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_ground_truth" "morphing_analysis/attack_pifo_ground_truth"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_ground_truth/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_manhattan_4
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_range_fast_manhattan_4" "morphing_analysis/attack_pifo_range_fast_manhattan_4"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_manhattan_4/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_manhattan_10
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_range_fast_manhattan_10" "morphing_analysis/attack_pifo_range_fast_manhattan_10"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_manhattan_10/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_manhattan_10_allfeatures
python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_range_fast_manhattan_10_allfeatures" "morphing_analysis/attack_pifo_range_fast_manhattan_10_allfeatures"
gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_manhattan_10_allfeatures/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_anime
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_range_fast_anime" "morphing_analysis/attack_pifo_range_fast_anime"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_range_fast_anime/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot

#mkdir netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_representative_fast
#python3 netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/analyze.py "morphing/attack_pifo_representative_fast" "morphing_analysis/attack_pifo_representative_fast"
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/attack_pifo_representative_fast/'" netbench_ddos/projects/ddos-aid/analysis/morphing_analysis/in_out_plot.gnuplot