#===============================================================================
# Configuration options
#===============================================================================
#                                    FILE: run_fig_*.sh
#                                   USAGE:  ./run_fig_*.sh

#===============================================================================
# General configuration
#===============================================================================
#                           SIMULATION_ID:    (String)    "CICDDoS2019",  "Morphing"         (defines where can the ground truth be found)
#                         INPUT_PCAP_SEED:    (String)    "DDoS2019/SAT-01-12-2018_0"
#                INPUT_PCAP_RANGE_ENABLED:    (String)    "True", "False"
#                   INPUT_PCAP_RANGE_INIT:       (Int)    0
#                    INPUT_PCAP_RANGE_END:       (Int)    400
#              INPUT_PCAP_TIME_ADJUSTMENT:    (String)    "Remove,5", "Add,10"                (there is a difference of 5h with respect to UTC in that dataset)
#                   INPUT_PCAP_TIME_START:    (String)    "None", "2018,12,1,10,52,00,000000" (to only analyze a fragment of the whole pcap; "None" to use all)
#                     INPUT_PCAP_TIME_END:    (String)    "2018,12,1,11,5,00,000000"    

#===============================================================================
# Clustering-algorithm configuration
#===============================================================================
#                         CLUSTERING_TYPE:    (String)    "Online_Range_Fast_Manhattan"
#                                                         "Online_Range_Fast_Anime", 
#                                                         "Online_Range_Exhaustive_Manhattan", 
#                                                         "Online_Range_Exhaustive_Anime", 
#                                                         "Online_Representative_Fast", 
#                                                         "Online_Representative_Exhaustive", 
#                                                         "Offline_KMeans",
#                                                         "Online_Representative_Exhaustive_Offline-Centroid-Initialization", 
#                                                         "Online_Representative_Fast_Offline-Centroid-Initialization"
#                            NUM_CLUSTERS:   (Integer)    10                                   (can be set to 1 to measure the overall throughput)
#                          RESET_CLUSTERS:     (Float)    1, 60                                (time in seconds, can be set to -1 to avoid resetting in online k-means). 
#                           LEARNING_RATE:     (Float)    0.3                                  (between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
#                             FEATURE_SET:    (String)    "len,id,frag_offset,ttl,proto,src0,src1,src2,src3,dst0,dst1,dst2,dst3,sport,dport"
#                NORMALIZE_FEATURE_VALUES:    (String)    "True", "False"

#===============================================================================
# Scheduling-algorithm configuration
#===============================================================================
#                       PRIORITIZING_TYPE:    (String)    "Throughput", 
#                                                         "NumPackets", 
#                                                         "NumPacketsSize", 
#                                                         "ThroughputSize", 
#                                                         "ThroughputDirect", 
#                                                         "NumPacketsDirect", 
#                                                         "ThroughputSizeDirect", 
#                                                         "NumPacketsSizeDirect"
#                UPDATE_PRIORITIES_WINDOW:     (Float)    -1, 0, 0.001                         (in seconds; -1 to disable; if the window is 0, the priorities are updated per packet)

#===============================================================================
# Logging configuration
#===============================================================================
#                       MONITORING_WINDOW:   (Integer)    60     (in seconds)
#                      THROUGHPUT_LOGGING:    (String)    "True", "False"
#           TRAFFIC_DISTRIBUTIONS_LOGGING:    (String)    "True", "False"
# TRAFFIC_DISTRIBUTIONS_HISTOGRAM_LOGGING:    (String)    "True", "False"
#          CLUSTERING_PERFORMANCE_LOGGING:    (String)    "True", "False"
#     CLUSTERING_PERFORMANCE_TIME_LOGGING:    (String)    "True", "False"                       (if we want to keep track of all the purities/true_positive/true_negative/recalls)
#            PRIORITY_PERFORMANCE_LOGGING:    (String)    "True", "False"
#       PRIORITY_PERFORMANCE_TIME_LOGGING:    (String)    "True", "False"
#           THROUGHPUT_PRIORITIES_LOGGING:    (String)    "True", "False"
#            SIGNATURE_EVALUATION_LOGGING:    (String)    "True", "False"

#===============================================================================
# Output logfiles configuration
#===============================================================================
#                    OUTPUT_LOGFILES_SEED:    (String)    "python/ddos-aid/plots_eval/"
#                             OUTPUT_PCAP:    (String)    "True", "False"
#                        OUTPUT_PCAP_SEED:    (String)    "pcaps/schedulers_reflection/"
#===============================================================================


         
    