#!/bin/bash

echo -e "Executed attack_analysis.sh"

# #############
# Attack generation
# #############

# We create a list with all the pcap files we want to analyze
INPUT_FILE='/mnt/fischer/thomas/traces/caida/2018/equinix-nyc/equinix-nyc.dirB.20180315.pcap'
OUTPUT_FILE_BASELINE='pcaps/morphing_tofino_baseline.pcap' # Only contains the cut from the origin pcap. If we don't want to save the baseline pcap we can just put ''.
OUTPUT_FILE_ATTACK='pcaps/morphing_tofino_attack.pcap'     # Contains the cut from the origin pcap and the attack on top

BASELINE_START_TIME=0         # Float (Seconds)
BASELINE_END_TIME=15          # Float (Seconds)
  
ATTACK_START_TIME=5           # Float (Seconds)
ATTACK_END_TIME=10            # Float (Seconds)
ATTACK_RATE=5                 # Float (Gbps)
ATTACK_IP_SRC='192.168.0.5'   # String
ATTACK_IP_DST='172.168.0.5'   # String
ATTACK_IP_ID=51105            # Int
ATTACK_IP_FRAG_OFFSET=16384   # Int
ATTACK_IP_TTL=255             # Int
ATTACK_IP_PROTO=17            # Int (6 = TCP, 17 = UDP) 
ATTACK_IP_LEN=10              # Int (MTU minus 20 bytes IP header and 20 bytes TCP or 8 byte UDP header)
ATTACK_T_SPORT=111            # Int
ATTACK_T_DPORT=222            # Int

# Generate the attack trace
#python3 python/attack_generation/pcap_attack_generation/simple_attack_generation.py $INPUT_FILE $OUTPUT_FILE_BASELINE $OUTPUT_FILE_ATTACK $BASELINE_START_TIME $BASELINE_END_TIME $ATTACK_START_TIME $ATTACK_END_TIME $ATTACK_RATE $ATTACK_IP_SRC $ATTACK_IP_DST $ATTACK_IP_ID $ATTACK_IP_FRAG_OFFSET $ATTACK_IP_TTL $ATTACK_IP_PROTO $ATTACK_IP_LEN $ATTACK_T_SPORT $ATTACK_T_DPORT

# Compute the throughput of the original and the one with attack (to compare)
#python3 python/attack_generation/analyze_created_attacks/plot_throughput.py 'pcaps/morphing_tofino_baseline.pcap' 'python/attack_generation/analyze_created_attacks/morphing_tofino_baseline_throughput.dat'
#python3 python/attack_generation/analyze_created_attacks/plot_throughput.py 'pcaps/morphing_tofino_attack.pcap' 'python/attack_generation/analyze_created_attacks/morphing_tofino_attack_throughput.dat'
#gnuplot -e "baseline_file='python/attack_generation/analyze_created_attacks/morphing_tofino_baseline_throughput.dat';attack_file='python/attack_generation/analyze_created_attacks/morphing_tofino_attack_throughput.dat';output_file='python/attack_generation/analyze_created_attacks/throughput.pdf'" python/attack_generation/analyze_created_attacks/plot_throughput.gnuplot

##############
# Clustering Performance Evaluation
##############

# Input-file configuration
INPUT_PCAP_SEED="pcaps/morphing_tofino_baseline.pcap"
INPUT_PCAP_RANGE_ENABLED="False"
INPUT_FILE_RANGE_INIT=0                   #(Int)
INPUT_PCAP_RANGE_END=0                    #(Int)

INPUT_PCAP_TIME_ADJUSTMENT="Remove,5"               #(String) Add/Remove,hours  # There is a difference of 5h with respect to UTC in that dataset
INPUT_PCAP_TIME_START="None"
INPUT_PCAP_TIME_END="None"
#INPUT_PCAP_TIME_START="2018,12,1,10,52,00,000000"   #(String) To only analyze a fragment of the whole pcap. "" to use all
#INPUT_PCAP_TIME_END="2018,12,1,11,5,00,000000"               
        
# Clustering-algorithm configuration
CLUSTERING_TYPE="Online_Range_Fast"             #(String)  "Online_Range_Fast", "Online_Range_Exhaustive", "Online_Representative_Fast", "Online_Representative_Exhaustive", "Offline_KMeans", "Online_Random_Fast", "Online_Representative_Exhaustive_Offline-Centroid-Initialization", "Online_Representative_Fast_Offline-Centroid-Initialization"
NUM_CLUSTERS=4                                  #(Integer) Can be set to 1 to measure the overall throughput
RESET_CLUSTERS=60                               #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
LEARNING_RATE=0.3                               #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
FEATURE_SET="len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"                             #(String) Complete if "len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"
NORMALIZE_FEATURE_VALUES="False"

# PRIORITIZATION CONFIGURATION
PRIORITIZING_TYPE="Throughput"                  #(String) "Throughput", "Numpackets", "Size", "ThroughputXSize", "Entropy"
UPDATE_PRIORITIES_WINDOW=0.001                  #(Float) Seconds. If the window is 0, the priorities will be updated per packet (ideal). 0.001 also works well

# Logging configuration
MONITORING_WINDOW=60                            #(Float)   Monitoring window (in seconds)
THROUGHPUT_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_LOGGING="False"
CLUSTERING_PERFORMANCE_LOGGING="True"
CLUSTERING_PERFORMANCE_TIME_LOGGING="False"     #(String)  "True" or "False" depending on whether we want to keep track of all the purities/true_positive/true_negative/recalls and J computed along the simulation
PRIORITY_PERFORMANCE_LOGGING="True"
PRIORITY_PERFORMANCE_TIME_LOGGING="False"       #(String)  "True" or "False" depending on whether we want to keep track of all the purities/true_positive/true_negative/recalls and J computed along the simulation
THROUGHPUT_PRIORITIES_LOGGING="False"

# Output logfiles configuration
OUTPUT_LOGFILES_SEED="python/ddos-aid/performance_evaluation/"
OUTPUT_PCAP="False"
OUTPUT_PCAP_SEED="pcaps/"

#python3 python/ddos-aid/main.py $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED


# #############
# Signature evaluation
# #############

# MONITORING_WINDOW=1                         #(Float)   Monitoring window (in seconds)
# RANGE_BASED="Range"                         #(String)  "Range" based or "Representative" based
# NUM_CLUSTERS=4                              #(Integer) Can be set to 1 to measure the overall throughput
# UPDATE_PRIORITIES=0.001                     #(Float)   In seconds. If set to 0, updates per-packet (k)
# RESET_CLUSTERS=60                           #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
# FAST_CLUSTERING="Exhaustive"                #(String)  "Exhaustive" search or "Fast" search
# LEARNING_RATE=0.3                           #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
# INPUT_FILE="pcaps/attack.pcap"

# python3 signature_evaluation/signature_evaluation.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $INPUT_FILE
# gnuplot signature_evaluation/plot.gnuplot


# #############
# Execution Netbench
# #############

#cd netbench_ddos
#mvn clean compile assembly:single
#cd ..
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/test.properties

# #############
# Throughput
# #############

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/throughput/clustering_1_Range_4_0001_60_Exhaustive_03_0_400_Fifo_80.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/throughput/clustering_1_Range_4_0001_60_Exhaustive_03_401_800_Fifo_80.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/throughput/clustering_1_Range_4_0001_60_Exhaustive_03_0_400_Pifo_80.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/throughput/clustering_1_Range_4_0001_60_Exhaustive_03_401_800_Pifo_80.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/throughput/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Fifo_80.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/throughput/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Fifo_80.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/throughput/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_80.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/throughput/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_80.properties

#mkdir netbench_ddos/projects/ddos-aid/analysis/throughput/clustering_1_Range_10_0001_60_Exhaustive_03_0_800_Fifo_80
#mkdir netbench_ddos/projects/ddos-aid/analysis/throughput/clustering_1_Range_10_0001_60_Exhaustive_03_0_800_Pifo_80
#mkdir netbench_ddos/projects/ddos-aid/analysis/throughput/clustering_1_Range_4_0001_60_Exhaustive_03_0_800_Fifo_80
#mkdir netbench_ddos/projects/ddos-aid/analysis/throughput/clustering_1_Range_4_0001_60_Exhaustive_03_0_800_Pifo_80

#python3 netbench_ddos/projects/ddos-aid/analysis/throughput/analyze.py clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Fifo_80 clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Fifo_80 throughput/clustering_1_Range_10_0001_60_Exhaustive_03_0_800_Fifo_80
#python3 netbench_ddos/projects/ddos-aid/analysis/throughput/analyze.py clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_80 clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_80 throughput/clustering_1_Range_10_0001_60_Exhaustive_03_0_800_Pifo_80
#python3 netbench_ddos/projects/ddos-aid/analysis/throughput/analyze.py clustering_1_Range_4_0001_60_Exhaustive_03_0_400_Fifo_80 clustering_1_Range_4_0001_60_Exhaustive_03_401_800_Fifo_80 throughput/clustering_1_Range_4_0001_60_Exhaustive_03_0_800_Fifo_80
#python3 netbench_ddos/projects/ddos-aid/analysis/throughput/analyze.py clustering_1_Range_4_0001_60_Exhaustive_03_0_400_Pifo_80 clustering_1_Range_4_0001_60_Exhaustive_03_401_800_Pifo_80 throughput/clustering_1_Range_4_0001_60_Exhaustive_03_0_800_Pifo_80

#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/throughput/clustering_1_Range_10_0001_60_Exhaustive_03_0_800_Fifo_80/'" netbench_ddos/projects/ddos-aid/analysis/throughput/plot.gnuplot
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/throughput/clustering_1_Range_10_0001_60_Exhaustive_03_0_800_Pifo_80/'" netbench_ddos/projects/ddos-aid/analysis/throughput/plot.gnuplot
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/throughput/clustering_1_Range_4_0001_60_Exhaustive_03_0_800_Fifo_80/'" netbench_ddos/projects/ddos-aid/analysis/throughput/plot.gnuplot
#gnuplot -e "path='netbench_ddos/projects/ddos-aid/analysis/throughput/clustering_1_Range_4_0001_60_Exhaustive_03_0_800_Pifo_80/'" netbench_ddos/projects/ddos-aid/analysis/throughput/plot.gnuplot
