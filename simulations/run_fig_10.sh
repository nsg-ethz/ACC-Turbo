#!/bin/bash

echo -e "Running ACC-Turbo Figure 10 evaluation using run_fig_10.sh"

##############################################
# Fig 10: Performance of clustering strategies
##############################################

# Input-file configuration
SIMULATION_ID="CICDDoS2019"
INPUT_PCAP_SEED="/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0"
INPUT_PCAP_RANGE_ENABLED="True"
INPUT_PCAP_RANGE_INIT=0
INPUT_PCAP_RANGE_END=819
INPUT_PCAP_TIME_ADJUSTMENT="Remove,5"
INPUT_PCAP_TIME_START="None"
INPUT_PCAP_TIME_END="None"

# Clustering-algorithm configuration
CLUSTERING_TYPE="Online_Range_Fast_Manhattan"
NUM_CLUSTERS=10
RESET_CLUSTERS=1
LEARNING_RATE=0.3
FEATURE_SET="len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"
NORMALIZE_FEATURE_VALUES="False"

# PRIORITIZATION CONFIGURATION
PRIORITIZING_TYPE="Throughput"
UPDATE_PRIORITIES_WINDOW=-1

# Logging configuration
MONITORING_WINDOW=60
THROUGHPUT_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING="False"
CLUSTERING_PERFORMANCE_LOGGING="True"
CLUSTERING_PERFORMANCE_TIME_LOGGING="False"
PRIORITY_PERFORMANCE_LOGGING="False"
PRIORITY_PERFORMANCE_TIME_LOGGING="False"
THROUGHPUT_PRIORITIES_LOGGING="False"
SIGNATURE_EVALUATION_LOGGING="False"

# Output logfiles configuration
OUTPUT_LOGFILES_SEED="python/accturbo/plots/num_clusters/"
OUTPUT_PCAP="False"
OUTPUT_PCAP_SEED="pcaps/"

CLUSTERING_TYPE="Online_Representative_Fast"
NUM_CLUSTERS=2
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=4
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=6
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=8
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=10
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Online_Range_Fast_Manhattan"
NUM_CLUSTERS=2
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=4
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=6
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=8
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=10
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Online_Range_Fast_Anime"
NUM_CLUSTERS=2
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=4
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=6
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=8
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=10
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Online_Representative_Exhaustive"
NUM_CLUSTERS=2
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=4
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=6
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=8
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=10
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Online_Range_Exhaustive_Manhattan"
NUM_CLUSTERS=2
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=4
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=6
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=8
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=10
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Online_Range_Exhaustive_Anime"
NUM_CLUSTERS=2
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=4
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=6
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=8
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=10
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Offline_KMeans"
NUM_CLUSTERS=2
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=4
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=6
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=8
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=10
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

CLUSTERING_TYPE="Online_Representative_Fast_Offline-Centroid-Initialization"
NUM_CLUSTERS=2
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=4
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=6
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=8
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

NUM_CLUSTERS=10
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED

python3 python/ddos-aid/performance_evaluation/analyze_clustering_performance_results.py "extended_numclusters"
gnuplot python/ddos-aid/performance_evaluation/performance_clustering.gnuplot
python3 python/ddos-aid/performance_evaluation/analyze_priority_performance_results.py "extended_numclusters"
gnuplot python/ddos-aid/performance_evaluation/performance_prioritization.gnuplot