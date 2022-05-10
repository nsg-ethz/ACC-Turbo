#!/bin/bash

echo -e "Executed run.sh"

# #############
# Attack generation
# #############

# We create a list with all the pcap files we want to analyze

#INPUT_FILE='/mnt/fischer/thomas/traces/caida/2018/equinix-nyc/equinix-nyc.dirB.20180315.pcap'
#OUTPUT_FILE_BASELINE='pcaps/motivation_baseline.pcap' # Only contains the cut from the origin pcap. If we don't want to save the baseline pcap we can just put 'none'.
#OUTPUT_FILE_ATTACK='pcaps/motivation_attack_5s_2Gbps.pcap'     # Contains the cut from the origin pcap and the attack on top

#BASELINE_START_TIME=0         # Float (Seconds)
#BASELINE_END_TIME=15          # Float (Seconds)

#ATTACK_START_TIME=5           # Float (Seconds)
#ATTACK_END_TIME=10            # Float (Seconds)
#ATTACK_RATE=2                 # Float (Gbps)
#ATTACK_IP_SRC='192.168.0.5'   # String
#ATTACK_IP_DST='172.16.0.5'    # String (this is the address used by attackers in the CICDDoS dataset)
#ATTACK_IP_ID=51105            # Int
#ATTACK_IP_FRAG_OFFSET=16384   # Int
#ATTACK_IP_TTL=255             # Int
#ATTACK_IP_PROTO=17            # Int (6 = TCP, 17 = UDP) 
#ATTACK_IP_LEN=1472            # Int (bytes): MTU (1500B) minus 20B IP header and 20B TCP or 8B UDP header. Not used at the moment.
                              # Note that the last packet in each us will not be size MTU!
#ATTACK_T_SPORT=111            # Int
#ATTACK_T_DPORT=222            # Int
#python3 attack_generation/pcap_attack_generation/attack_generation.py $INPUT_FILE $OUTPUT_FILE_BASELINE $OUTPUT_FILE_ATTACK $BASELINE_START_TIME $BASELINE_END_TIME $ATTACK_START_TIME $ATTACK_END_TIME $ATTACK_RATE $ATTACK_IP_SRC $ATTACK_IP_DST $ATTACK_IP_ID $ATTACK_IP_FRAG_OFFSET $ATTACK_IP_TTL $ATTACK_IP_PROTO $ATTACK_IP_LEN $ATTACK_T_SPORT $ATTACK_T_DPORT

## Second attack (4Gbps)
#OUTPUT_FILE_BASELINE='none'
#OUTPUT_FILE_ATTACK='pcaps/motivation_attack_5s_4Gbps.pcap'
#ATTACK_RATE=4
#python3 attack_generation/pcap_attack_generation/attack_generation.py $INPUT_FILE $OUTPUT_FILE_BASELINE $OUTPUT_FILE_ATTACK $BASELINE_START_TIME $BASELINE_END_TIME $ATTACK_START_TIME $ATTACK_END_TIME $ATTACK_RATE $ATTACK_IP_SRC $ATTACK_IP_DST $ATTACK_IP_ID $ATTACK_IP_FRAG_OFFSET $ATTACK_IP_TTL $ATTACK_IP_PROTO $ATTACK_IP_LEN $ATTACK_T_SPORT $ATTACK_T_DPORT

## Second attack (6Gbps)
#OUTPUT_FILE_ATTACK='pcaps/motivation_attack_5s_6Gbps.pcap'
#ATTACK_RATE=6
#python3 attack_generation/pcap_attack_generation/attack_generation.py $INPUT_FILE $OUTPUT_FILE_BASELINE $OUTPUT_FILE_ATTACK $BASELINE_START_TIME $BASELINE_END_TIME $ATTACK_START_TIME $ATTACK_END_TIME $ATTACK_RATE $ATTACK_IP_SRC $ATTACK_IP_DST $ATTACK_IP_ID $ATTACK_IP_FRAG_OFFSET $ATTACK_IP_TTL $ATTACK_IP_PROTO $ATTACK_IP_LEN $ATTACK_T_SPORT $ATTACK_T_DPORT

## Second attack (8Gbps)
#OUTPUT_FILE_ATTACK='pcaps/motivation_attack_5s_8Gbps.pcap'
#ATTACK_RATE=8
#python3 attack_generation/pcap_attack_generation/attack_generation.py $INPUT_FILE $OUTPUT_FILE_BASELINE $OUTPUT_FILE_ATTACK $BASELINE_START_TIME $BASELINE_END_TIME $ATTACK_START_TIME $ATTACK_END_TIME $ATTACK_RATE $ATTACK_IP_SRC $ATTACK_IP_DST $ATTACK_IP_ID $ATTACK_IP_FRAG_OFFSET $ATTACK_IP_TTL $ATTACK_IP_PROTO $ATTACK_IP_LEN $ATTACK_T_SPORT $ATTACK_T_DPORT

## Second attack (10Gbps)
#OUTPUT_FILE_ATTACK='pcaps/motivation_attack_5s_10Gbps.pcap'
#ATTACK_RATE=10
#python3 attack_generation/pcap_attack_generation/attack_generation.py $INPUT_FILE $OUTPUT_FILE_BASELINE $OUTPUT_FILE_ATTACK $BASELINE_START_TIME $BASELINE_END_TIME $ATTACK_START_TIME $ATTACK_END_TIME $ATTACK_RATE $ATTACK_IP_SRC $ATTACK_IP_DST $ATTACK_IP_ID $ATTACK_IP_FRAG_OFFSET $ATTACK_IP_TTL $ATTACK_IP_PROTO $ATTACK_IP_LEN $ATTACK_T_SPORT $ATTACK_T_DPORT

# Compute the throughput of the original and the one with attack (to compare)
#python3 attack_generation/pcap_attack_generation/plot_throughput.py 'pcaps/motivation_baseline.pcap' 'attack_generation/pcap_attack_generation/throughput/baseline_throughput.dat'
#python3 attack_generation/pcap_attack_generation/plot_throughput.py 'pcaps/motivation_attack_5s_2Gbps.pcap' 'attack_generation/pcap_attack_generation/throughput/attack_throughput.dat'
#gnuplot -e "baseline_file='attack_generation/pcap_attack_generation/throughput/baseline_throughput.dat';attack_file='attack_generation/pcap_attack_generation/throughput/attack_throughput.dat';output_file='attack_generation/pcap_attack_generation/throughput/throughput.pdf'" attack_generation/pcap_attack_generation/plot_throughput.gnuplot

##############
# Execution clustering
##############

INPUT_FILE_SEED="/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0"
INPUT_FILE_RANGE_ENABLED="False"
INPUT_FILE_RANGE_INIT=0                   #(Int)
INPUT_FILE_RANGE_END=0                  #(Int)

CLUSTERING_TYPE="Online_Range_Exhaustive" #(String)  "Online_Range_Fast", "Online_Range_Exhaustive", "Online_Representative_Fast", "Online_Representative_Exhaustive", "Offline_KMeans"
NUM_CLUSTERS=2                            #(Integer) Can be set to 1 to measure the overall throughput
MONITORING_WINDOW=1                       #(Float)   Monitoring window (in seconds)
UPDATE_PRIORITIES=0.001                   #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                         #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
LEARNING_RATE=0.3                         #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)

OUTPUT_FILE_SEED='pcaps/'

python3 ddos-aid/main.py $INPUT_FILE_SEED $INPUT_FILE_RANGE_ENABLED $INPUT_FILE_RANGE_INIT $INPUT_FILE_RANGE_END $CLUSTERING_TYPE $NUM_CLUSTERS $MONITORING_WINDOW $UPDATE_PRIORITIES $RESET_CLUSTERS $LEARNING_RATE $OUTPUT_FILE_SEED

##############
# Execution Netbench
##############

#cd netbench_ddos
#mvn clean compile assembly:single
#cd ..
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/test.properties

##############
# Throughput
##############

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

##############
# Num clusters
##############

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_80_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_80_005.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_80_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_80_005.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_2_0001_60_Exhaustive_03_0_400_Pifo_80_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_2_0001_60_Exhaustive_03_401_800_Pifo_80_005.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_4_0001_60_Exhaustive_03_0_400_Pifo_80_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_4_0001_60_Exhaustive_03_401_800_Pifo_80_005.properties 

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_6_0001_60_Exhaustive_03_0_400_Pifo_80_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_6_0001_60_Exhaustive_03_401_800_Pifo_80_005.properties 

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_8_0001_60_Exhaustive_03_0_400_Pifo_80_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_8_0001_60_Exhaustive_03_401_800_Pifo_80_005.properties 

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_80_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/num_clusters/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_80_005.properties

#python3 netbench_ddos/projects/ddos-aid/analysis/num_clusters_analysis/analyze.py
#gnuplot netbench_ddos/projects/ddos-aid/analysis/num_clusters_analysis/plot.gnuplot

##############
# Queue depths
##############

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/50/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_50_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/50/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_50_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/50/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_50_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/50/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_50_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/50/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_50_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/50/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_50_005.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/100/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_100_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/100/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_100_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/100/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_100_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/100/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_100_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/100/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_100_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/100/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_100_005.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/250/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_250_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/250/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_250_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/250/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_250_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/250/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_250_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/250/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_250_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/250/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_250_005.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/500/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_500_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/500/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_500_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/500/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_500_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/500/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_500_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/500/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_500_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/queue_depths/500/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_500_005.properties

#python3 netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/analyze.py
#gnuplot netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/plot.gnuplot

##############
# Bottleneck capacities
##############

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/001/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_80_001.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/001/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_80_001.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/001/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_80_001.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/001/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_80_001.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/001/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_80_001.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/001/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_80_001.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0001/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_80_0001.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0001/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_80_0001.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0001/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_80_0001.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0001/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_80_0001.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0001/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_80_0001.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0001/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_80_0001.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/002/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_80_002.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/002/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_80_002.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/002/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_80_002.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/002/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_80_002.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/002/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_80_002.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/002/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_80_002.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/005/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_80_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/005/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_80_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/005/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_80_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/005/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_80_005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/005/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_80_005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/005/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_80_005.properties

#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0005/clustering_1_Range_10_0001_60_Exhaustive_03_0_400_Pifo_80_0005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0005/clustering_1_Range_10_0001_60_Exhaustive_03_401_800_Pifo_80_0005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0005/clustering_1_0001_60_Exhaustive_03_0_400_PifoGT_80_0005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0005/clustering_1_0001_60_Exhaustive_03_401_800_PifoGT_80_0005.properties
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0005/clustering_1_0001_60_Exhaustive_03_0_400_Fifo_80_0005.properties 
#java -jar -ea netbench_ddos/NetBench.jar ./netbench_ddos/projects/ddos-aid/runs/bottleneck_capacities/0005/clustering_1_0001_60_Exhaustive_03_401_800_Fifo_80_0005.properties

#python3 netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/analyze.py
#gnuplot netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/plot.gnuplot