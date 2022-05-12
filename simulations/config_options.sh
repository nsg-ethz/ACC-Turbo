# Input-file configuration
SIMULATION_ID="CICDDoS2019"                         #(String) CICDDoS2019, Morphing (used to define e.g., where can the ground truth be found)
INPUT_PCAP_SEED="/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0"
INPUT_PCAP_RANGE_ENABLED="True"
INPUT_PCAP_RANGE_INIT=0                             #(Int)
INPUT_PCAP_RANGE_END=400                            #(Int)
INPUT_PCAP_TIME_ADJUSTMENT="Remove,5"               #(String) Add/Remove,hours  # There is a difference of 5h with respect to UTC in that dataset
INPUT_PCAP_TIME_START="None"
INPUT_PCAP_TIME_END="None"
#INPUT_PCAP_TIME_START="2018,12,1,10,52,00,000000"   #(String) To only analyze a fragment of the whole pcap. "" to use all
#INPUT_PCAP_TIME_END="2018,12,1,11,5,00,000000"               
        
# Clustering-algorithm configuration
CLUSTERING_TYPE="Online_Range_Fast_Manhattan"       #(String)  "Online_Range_Fast_Manhattan", "Online_Range_Fast_Anime", "Online_Range_Exhaustive_Manhattan", "Online_Range_Exhaustive_Anime", "Online_Representative_Fast", "Online_Representative_Exhaustive", "Offline_KMeans", "Online_Random_Fast", "Online_Representative_Exhaustive_Offline-Centroid-Initialization", "Online_Representative_Fast_Offline-Centroid-Initialization"
NUM_CLUSTERS=10                                     #(Integer) Can be set to 1 to measure the overall throughput
RESET_CLUSTERS=1                                   #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
LEARNING_RATE=0.3                                   #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
FEATURE_SET="dst0,dst1,dst2,dst3" #(String) Complete if "len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"
NORMALIZE_FEATURE_VALUES="False"

# PRIORITIZATION CONFIGURATION
PRIORITIZING_TYPE="Throughput"                  #(String) "Throughput", "Numpackets", "Size", "ThroughputXSize", "Entropy"
UPDATE_PRIORITIES_WINDOW=-1                      #(Float) Seconds. If the window is 0, the priorities will be updated per packet (ideal). 0.001 also works well

# Logging configuration
MONITORING_WINDOW=60                             #(Float)   Monitoring window (in seconds)
THROUGHPUT_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_LOGGING="False"
TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING="False"
CLUSTERING_PERFORMANCE_LOGGING="False"
CLUSTERING_PERFORMANCE_TIME_LOGGING="False"     #(String)  "True" or "False" depending on whether we want to keep track of all the purities/true_positive/true_negative/recalls and J computed along the simulation
PRIORITY_PERFORMANCE_LOGGING="True"
PRIORITY_PERFORMANCE_TIME_LOGGING="False"       #(String)  "True" or "False" depending on whether we want to keep track of all the purities/true_positive/true_negative/recalls and J computed along the simulation
THROUGHPUT_PRIORITIES_LOGGING="False"
SIGNATURE_EVALUATION_LOGGING="False"

# Output logfiles configuration
OUTPUT_LOGFILES_SEED="python/ddos-aid/plots_eval/"
OUTPUT_PCAP="True"
OUTPUT_PCAP_SEED="pcaps/schedulers_reflection/"
python3 python/ddos-aid/main.py $SIMULATION_ID $INPUT_PCAP_SEED $INPUT_PCAP_RANGE_ENABLED $INPUT_PCAP_RANGE_INIT $INPUT_PCAP_RANGE_END $INPUT_PCAP_TIME_ADJUSTMENT $INPUT_PCAP_TIME_START $INPUT_PCAP_TIME_END $CLUSTERING_TYPE $NUM_CLUSTERS $RESET_CLUSTERS $LEARNING_RATE $FEATURE_SET $NORMALIZE_FEATURE_VALUES $PRIORITIZING_TYPE $UPDATE_PRIORITIES_WINDOW $MONITORING_WINDOW $THROUGHPUT_LOGGING $TRAFFIC_DISTRIBUTIONS_LOGGING $TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING $CLUSTERING_PERFORMANCE_LOGGING $CLUSTERING_PERFORMANCE_TIME_LOGGING $PRIORITY_PERFORMANCE_LOGGING $PRIORITY_PERFORMANCE_TIME_LOGGING $THROUGHPUT_PRIORITIES_LOGGING $SIGNATURE_EVALUATION_LOGGING $OUTPUT_LOGFILES_SEED $OUTPUT_PCAP $OUTPUT_PCAP_SEED