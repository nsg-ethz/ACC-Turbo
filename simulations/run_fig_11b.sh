#!/bin/bash

echo -e "Executed scheduling analysis.sh"

##############
# Generate pcaps
##############

# Input-file configuration
SIMULATION_ID="CICDDoS2019"
INPUT_PCAP_SEED="DDoS2019/SAT-01-12-2018_0"
INPUT_PCAP_RANGE_ENABLED="True"
INPUT_PCAP_RANGE_INIT=0
INPUT_PCAP_RANGE_END=400
INPUT_PCAP_TIME_ADJUSTMENT="Remove,5"
INPUT_PCAP_TIME_START="Reflection"
INPUT_PCAP_TIME_END="None"
                  
# Clustering-algorithm configuration
CLUSTERING_TYPE="Online_Range_Fast_Manhattan"
NUM_CLUSTERS=10
RESET_CLUSTERS=1
LEARNING_RATE=0.3
FEATURE_SET="src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,ttl"
NORMALIZE_FEATURE_VALUES="False"

# PRIORITIZATION CONFIGURATION
PRIORITIZING_TYPE="Throughput"
UPDATE_PRIORITIES_WINDOW=0

# Logging configuration
MONITORING_WINDOW=1
THROUGHPUT_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING="False"
CLUSTERING_PERFORMANCE_LOGGING="False"
CLUSTERING_PERFORMANCE_TIME_LOGGING="False"
PRIORITY_PERFORMANCE_LOGGING="False"
PRIORITY_PERFORMANCE_TIME_LOGGING="False"
THROUGHPUT_PRIORITIES_LOGGING="False"
SIGNATURE_EVALUATION_LOGGING="False"

# Output logfiles configuration
OUTPUT_LOGFILES_SEED="python/plots/"
OUTPUT_PCAP="True"
OUTPUT_PCAP_SEED="pcaps/"

# PCAP Generation
CLUSTERING_TYPE="Online_Range_Fast_Manhattan"
PRIORITIZING_TYPE="Throughput"
INPUT_PCAP_RANGE_INIT=0
INPUT_PCAP_RANGE_END=400
python3 python/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED
INPUT_PCAP_RANGE_INIT=401
INPUT_PCAP_RANGE_END=819
python3 python/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

PRIORITIZING_TYPE="ThroughputSize"
INPUT_PCAP_RANGE_INIT=0
INPUT_PCAP_RANGE_END=400
python3 python/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED
INPUT_PCAP_RANGE_INIT=401
INPUT_PCAP_RANGE_END=819
python3 python/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Online_Range_Fast_Anime"
PRIORITIZING_TYPE="Throughput"
INPUT_PCAP_RANGE_INIT=0
INPUT_PCAP_RANGE_END=400
python3 python/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED
INPUT_PCAP_RANGE_INIT=401
INPUT_PCAP_RANGE_END=819
python3 python/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Online_Range_Exhaustive_Manhattan"
PRIORITIZING_TYPE="Throughput"
INPUT_PCAP_RANGE_INIT=0
INPUT_PCAP_RANGE_END=400
python3 python/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED
INPUT_PCAP_RANGE_INIT=401
INPUT_PCAP_RANGE_END=819
python3 python/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

##############
# Netbench
##############

cd netbench
mvn clean compile assembly:single
cd ..


java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/0_400_PifoGT_80_0001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/401_819_PifoGT_80_0001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0001.properties &
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0001.properties & 
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0001.properties & 
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/0_400_Fifo_80_0001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0001/401_819_Fifo_80_0001.properties &
wait

java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/0_400_PifoGT_80_0005.properties  &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/401_819_PifoGT_80_0005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0005.properties &
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0005.properties & 
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0005.properties & 
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_0005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_0005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/0_400_Fifo_80_0005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/0005/401_819_Fifo_80_0005.properties &
wait

java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/0_400_PifoGT_80_001.properties  &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/401_819_PifoGT_80_001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_001.properties &
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_001.properties & 
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_001.properties & 
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/0_400_Fifo_80_001.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/001/401_819_Fifo_80_001.properties &
wait

java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/0_400_PifoGT_80_002.properties  &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/401_819_PifoGT_80_002.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_002.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_002.properties &
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_002.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_002.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_002.properties & 
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_002.properties & 
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_002.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_002.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/0_400_Fifo_80_002.properties  &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/002/401_819_Fifo_80_002.properties &
wait

java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/0_400_PifoGT_80_005.properties  &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/401_819_PifoGT_80_005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_005.properties &
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_005.properties & 
wait
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_005.properties &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/0_400_Fifo_80_005.properties  &
java -jar -ea netbench/NetBench.jar ./netbench/projects/accturbo/runs/bottleneck_capacities/005/401_819_Fifo_80_005.properties &
wait

python3 netbench/projects/accturbo/analysis/bottleneck_capacities/analyze.py
gnuplot netbench/projects/accturbo/analysis/bottleneck_capacities/plot.gnuplot
