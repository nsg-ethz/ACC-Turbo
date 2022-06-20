##################################
# Analyze bottleneck capacities
##################################

def analyze_bottleneck_capacities(range_bottleneck_capacities, schedulers):
        
    for scheduler in schedulers:
        print("Analyzing scheduler: " + scheduler)
        first_file = True
        for bottleneck_capacitiy in range_bottleneck_capacities:
            print("Bottleneck capacity: " + bottleneck_capacitiy)
            
            # We select the first input file
            if scheduler == "PifoManhattanFast":
                input_file_first = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")
            elif scheduler == "PifoAnimeExhaustive":
                input_file_first = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Exhaustive_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")
            elif scheduler == "PifoAnimeFast":
                input_file_first = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")
            elif scheduler == "PifoManhattanExhaustive":
                input_file_first = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")           
            elif scheduler == "PifoManhattanFastThroughputSize":
                input_file_first = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_0_400_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")           

            else:
                input_file_first = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/0_400_" + scheduler + "_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")

            # We process the statistics of the first input file
            benign_sent = 0
            benign_dropped = 0  

            for line in input_file_first:
                if line.split(": ")[0] == "BENIGN_PACKETS_SENT":
                    benign_sent = float(line.split(": ")[1])
                if line.split(": ")[0] == "BENIGN_PACKETS_DROPPED":
                    benign_dropped = float(line.split(": ")[1])      
                if line.split(": ")[0] == "MALICIOUS_PACKETS_SENT":
                    malicious_sent = float(line.split(": ")[1])
                if line.split(": ")[0] == "MALICIOUS_PACKETS_DROPPED":
                    malicious_dropped = float(line.split(": ")[1])
                if line.split(": ")[0] == "PACKETS_DROPPED":
                    total_dropped = float(line.split(": ")[1])
            input_file_first.close()

            # We select the second input file
            if scheduler == "PifoManhattanFast":
                input_file_second = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Fast_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")
            elif scheduler == "PifoAnimeExhaustive":
                input_file_second = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Exhaustive_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")
            elif scheduler == "PifoAnimeFast":
                input_file_second = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Fast_Anime_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")
            elif scheduler == "PifoManhattanExhaustive":
                input_file_second = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Exhaustive_Manhattan_10_1_0.3_False_Throughput_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")
            elif scheduler == "PifoManhattanFastThroughputSize":
                input_file_second = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/Online_Range_Fast_Manhattan_10_1_0.3_False_ThroughputSize_0_1_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_ttl_401_819_Pifo_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")
            else:
                input_file_second = open("netbench/temp/accturbo/bottleneck_capacities/"+str(bottleneck_capacitiy)+"/401_819_" + scheduler + "_80_" + str(bottleneck_capacitiy) + "/statistics.log", "r")

            # We process the statistics of the second input file
            for line in input_file_second:
                if line.split(": ")[0] == "BENIGN_PACKETS_SENT":
                    benign_sent = benign_sent + float(line.split(": ")[1])
                if line.split(": ")[0] == "BENIGN_PACKETS_DROPPED":
                    benign_dropped = benign_dropped + float(line.split(": ")[1])      
                if line.split(": ")[0] == "MALICIOUS_PACKETS_SENT":
                    malicious_sent = malicious_sent + float(line.split(": ")[1])
                if line.split(": ")[0] == "MALICIOUS_PACKETS_DROPPED":
                    malicious_dropped = malicious_dropped + float(line.split(": ")[1])
                if line.split(": ")[0] == "PACKETS_DROPPED":
                    total_dropped = total_dropped + float(line.split(": ")[1])
            input_file_second.close()

            # We compute the drop percentages
            drop_percentage_benign = (benign_dropped/benign_sent)*100
            print("Drop percentage benign: " + str(drop_percentage_benign))

            # We create the file for the first queue depth
            if (first_file):
                output_file1 = open("netbench/projects/accturbo/analysis/bottleneck_capacities/drop_percentage_benign_" + scheduler + ".dat", "w+")
                output_file1.write("#BottleneckCapacities,PercentLoss")
                output_file1.write("\n" + str(bottleneck_capacitiy) + "," + str(drop_percentage_benign))
                output_file1.close()
                first_file = False
            
            # We just add data points for the others
            else:
                output_file1 = open("netbench/projects/accturbo/analysis/bottleneck_capacities/drop_percentage_benign_" + scheduler + ".dat", "a")
                output_file1.write("\n" + str(bottleneck_capacitiy) + "," + str(drop_percentage_benign))
                output_file1.close()

if __name__ == "__main__":
    range_bottleneck_capacities = ["005","002","001","0005","0001"]
    schedulers = ["Fifo", "PifoGT", "PifoManhattanFast", "PifoManhattanFastThroughputSize", "PifoManhattanExhaustive", "PifoAnimeFast"] 
    analyze_bottleneck_capacities(range_bottleneck_capacities, schedulers)