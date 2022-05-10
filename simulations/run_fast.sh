#!/bin/bash

echo -e "Executed run.sh"

##############
# Execution clustering.py
##############

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=2                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"            #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=0                      #(Int)     Between 0 and 800
RANGE_END=400                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=2                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=401                      #(Int)     Between 0 and 800
RANGE_END=800                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=4                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=0                      #(Int)     Between 0 and 800
RANGE_END=400                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=4                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=401                      #(Int)     Between 0 and 800
RANGE_END=800                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=6                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=0                      #(Int)     Between 0 and 800
RANGE_END=400                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=6                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=401                      #(Int)     Between 0 and 800
RANGE_END=800                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=8                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=0                      #(Int)     Between 0 and 800
RANGE_END=400                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=8                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=401                      #(Int)     Between 0 and 800
RANGE_END=800                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=10                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=0                      #(Int)     Between 0 and 800
RANGE_END=400                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

MONITORING_WINDOW=1               #(Float)   Monitoring window (in seconds)
RANGE_BASED="Range"               #(String)  "Range" based or "Representative" based
NUM_CLUSTERS=10                    #(Integer) Can be set to 1 to measure the overall throughput
UPDATE_PRIORITIES=0.001           #(Float)   In seconds. If set to 0, updates per-packet (k)
RESET_CLUSTERS=60                 #(Float)   In seconds (w). Can be set to -1 to avoid resetting in online k-means. 
FAST_CLUSTERING="Fast"      #(String)  "Exhaustive" search or "Fast" search
LEARNING_RATE=0.3                 #(Float)   Between 0 and 1. Only used in representative-based clustering. 0 means representative not updated. 1 means representative set to new packet)
RANGE_INIT=401                      #(Int)     Between 0 and 800
RANGE_END=800                     #(Int)     Between 0 and 800
python3 ddos-aid/clustering.py $MONITORING_WINDOW $RANGE_BASED $NUM_CLUSTERS $UPDATE_PRIORITIES $RESET_CLUSTERS $FAST_CLUSTERING $LEARNING_RATE $RANGE_INIT $RANGE_END

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