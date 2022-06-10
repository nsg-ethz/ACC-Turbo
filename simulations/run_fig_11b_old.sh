#!/bin/bash

echo -e "Executed scheduling analysis.sh"

##############
# Generate pcaps
##############

# Input-file configuration
SIMULATION_ID="CICDDoS2019"                         #(String) CICDDoS2019, Morphing (used to define e.g., where can the ground truth be found)
INPUT_PCAP_SEED="/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0"
INPUT_PCAP_RANGE_ENABLED="True"
INPUT_PCAP_RANGE_INIT=0                             #(Int)
INPUT_PCAP_RANGE_END=400                            #(Int)
INPUT_PCAP_TIME_ADJUSTMENT="Remove,5"               #(String) Add/Remove,hours  # There is a difference of 5h with respect to UTC in that dataset
INPUT_PCAP_TIME_START="None"
INPUT_PCAP_TIME_END="None"

# Clustering-algorithm configuration
CLUSTERING_TYPE="Online_Range_Fast_Manhattan" #(String)  "Online_Range_Fast_Manhattan", "Online_Range_Fast_Anime", "Online_Range_Exhaustive_Manhattan", "Online_Range_Exhaustive_Anime", "Online_Representative_Fast", "Online_Representative_Exhaustive", "Offline_KMeans", "Online_Random_Fast", "Online_Representative_Exhaustive_Offline-Centroid-Initialization", "Online_Representative_Fast_Offline-Centroid-Initialization"
NUM_CLUSTERS=10                                     #(Integer) Can be set to 1 to measure the overall throughput
RESET_CLUSTERS=1                                #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
LEARNING_RATE=0.3                                   #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
FEATURE_SET="src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,ttl" #(String) Complete if "len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"
NORMALIZE_FEATURE_VALUES="False"

# PRIORITIZATION CONFIGURATION
PRIORITIZING_TYPE="ThroughputSize"                  #(String) "Throughput", "Numpackets", "Size", "ThroughputXSize", "Entropy"
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
OUTPUT_LOGFILES_SEED="pcaps/"
OUTPUT_PCAP="True"
OUTPUT_PCAP_SEED="pcaps/"
#python3 python/accr/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

INPUT_PCAP_RANGE_INIT=401                             #(Int)
INPUT_PCAP_RANGE_END=819                              #(Int)
#python3 python/accr/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

##############
# Netbench
##############

cd netbench_old
mvn clean compile assembly:single
cd ..

##############
# Overall performance
##############

#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/0_400_Fifo_80_001.properties 
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/401_819_Fifo_80_001.properties
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/0_400_PifoGT_80_001.properties 
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/401_819_PifoGT_80_001.properties
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_001.properties
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_001.properties

java -jar -ea netbench_old/NetBench.jar ./netbench_old/projects/accr/runs/bottleneck_capacities/0001/0_400_Fifo_80_0001.properties 
java -jar -ea netbench_old/NetBench.jar ./netbench_old/projects/accr/runs/bottleneck_capacities/0001/401_819_Fifo_80_0001.properties
#java -jar -ea netbench_old/NetBench.jar ./netbench_old/projects/accr/runs/bottleneck_capacities/0001/0_400_PifoGT_80_0001.properties 
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0001/401_819_PifoGT_80_0001.properties
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0001/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_0001.properties
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0001/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_0001.properties

#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/0_400_Fifo_80_002.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/401_819_Fifo_80_002.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/0_400_PifoGT_80_002.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/401_819_PifoGT_80_002.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_002.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_002.properties

#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/0_400_Fifo_80_005.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/401_819_Fifo_80_005.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/0_400_PifoGT_80_005.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/401_819_PifoGT_80_005.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_005.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_005.properties

#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/0_400_Fifo_80_0005.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/401_819_Fifo_80_0005.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/0_400_PifoGT_80_0005.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/401_819_PifoGT_80_0005.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_0005.properties
#java -jar -ea netbench_old/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_0005.properties

python3 netbench/projects/accr/analysis/bottleneck_capacities_analysis/analyze.py
gnuplot netbench/projects/accr/analysis/bottleneck_capacities_analysis/plot.gnuplot

##############
# Bottleneck capacities (extension of the above to Anime and Exhaustive)
##############

#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_001.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_001.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_001.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/001/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_001.properties

#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0001/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0001.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0001/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0001.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0001/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_0001.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0001/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_0001.properties

#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_002.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_002.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_002.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/002/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_002.properties

#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_005.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_005.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_005.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/005/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_005.properties


#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0005.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0005.properties 
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_0_400_Pifo_80_0005.properties
#java -jar -ea netbench/NetBench.jar ./netbench/projects/accr/runs/bottleneck_capacities/0005/Online_Range_Fast_Manhattan_10_60_0.3_False_ThroughputSize_0_60_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_ttl_len_401_819_Pifo_80_0005.properties