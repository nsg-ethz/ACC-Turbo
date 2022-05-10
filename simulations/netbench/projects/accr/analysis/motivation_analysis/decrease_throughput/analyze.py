import csv
import sys 
import os

##################################
# Analyze throughput
##################################

def get_throughput(input_file):
    
    # Initialize the main variables for the analysis
    is_first_packet = True
    current_bucket = 0
    time_axis = {}
    time_axis[0] = None

    throughput = {}
    throughput[current_bucket] = 0

    with open(input_file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            timestamp = float(row[0]) # in nanoseconds
            packetSizeBit = float(row[1])

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp
                is_first_packet = False

            # We add the new packet size to the throughput
            throughput[current_bucket] = throughput[current_bucket] + packetSizeBit

            # We update the time buckets for monitoring
            difference_tracking = timestamp-time_axis[current_bucket] # Is ns
            if (difference_tracking > 1000000000): #1s monitoring window

                # We initialize a new aggregation bucket
                current_bucket = current_bucket + 1
                time_axis[current_bucket] = timestamp
                throughput[current_bucket] = 0
    
    csv_file.close()
    return throughput, time_axis

def compute_average_decrease(throughput_input, timeaxis_input, throughput_output, timeaxis_output):
    average_decrease = 0
    num_buckets = 0

    for bucket in range(0, len(timeaxis_input)):
        if (timeaxis_input[bucket] != None):
            # We are only interested in the average decrease during the attack duration
            if((timeaxis_input[bucket] >= 5000000000) and (timeaxis_input[bucket] < 10000000000)):
                percentage_throughput_decreased = 100 - ((throughput_output[bucket]/throughput_input[bucket])*100)
                average_decrease = average_decrease + percentage_throughput_decreased
                num_buckets = num_buckets + 1
    if (average_decrease != 0 and num_buckets != 0):
        return average_decrease/num_buckets
    else:
        return 0

def analyze_throughput_decrease(type):

    rates = ['0', '2', '4', '6', '8', '10']
    percentages = ['0', '02', '04', '06', '08', '1']

    # We create and initialize the three output files
    print("Creating: netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/" + type + "_throughput_decrease_benign.dat")
    out_file_decrease_benign = open("netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/" + type + "_throughput_decrease_benign.dat", "w")
    out_file_decrease_malicious = open("netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/" + type + "_throughput_decrease_malicious.dat", "w")

    if type == "tn":
        out_file_decrease_benign.write("# AttackRate(Gbps), TrueNegativeRate(%), ThroughputDecrease(%)")
        out_file_decrease_malicious.write("# AttackRate(Gbps), TrueNegativeRate(%), ThroughputDecrease(%)")
    else:
        out_file_decrease_benign.write("# AttackRate(Gbps), TruePositiveRate(%), ThroughputDecrease(%)")
        out_file_decrease_malicious.write("# AttackRate(Gbps), TruePositiveRate(%), ThroughputDecrease(%)")

    # Tn = 1
    # Tp from 0 to 1    
    for rate in rates:
        for percentage in percentages:

            if type == "tn":
                throughput_input_benign, timeaxis_input_benign = get_throughput("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn" + percentage + "_tp1/input_throughput_benign.csv.log")
                throughput_output_benign, timeaxis_output_benign = get_throughput("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn" + percentage + "_tp1/output_throughput_benign.csv.log")
                throughput_input_malicious, timeaxis_input_malicious = get_throughput("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn" + percentage + "_tp1/input_throughput_malicious.csv.log")
                throughput_output_malicious, timeaxis_output_malicious = get_throughput("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn" + percentage + "_tp1/output_throughput_malicious.csv.log")
            else:
                throughput_input_benign, timeaxis_input_benign = get_throughput("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn1_tp" + percentage + "/input_throughput_benign.csv.log")
                throughput_output_benign, timeaxis_output_benign = get_throughput("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn1_tp" + percentage + "/output_throughput_benign.csv.log")
                throughput_input_malicious, timeaxis_input_malicious = get_throughput("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn1_tp" + percentage + "/input_throughput_malicious.csv.log")
                throughput_output_malicious, timeaxis_output_malicious = get_throughput("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn1_tp" + percentage + "/output_throughput_malicious.csv.log")

            # We compute the average decrease in throughput (as a percentage) during the attack period
            throughput_decrease_benign = compute_average_decrease(throughput_input_benign, timeaxis_input_benign, throughput_output_benign, timeaxis_output_benign)
            throughput_decrease_malicious = compute_average_decrease(throughput_input_malicious, timeaxis_input_malicious, throughput_output_malicious, timeaxis_output_malicious)

            if (len(percentage) == 2):
                percentage = "0." + percentage.split("0")[1]

            out_file_decrease_benign.write("\n" + str(rate) + "," + str(percentage) + "," + str(throughput_decrease_benign))
            out_file_decrease_malicious.write("\n" + str(rate) + "," + str(percentage) + "," + str(throughput_decrease_malicious))

    out_file_decrease_benign.close()
    out_file_decrease_malicious.close()

# Call analysis functions
analyze_throughput_decrease("tp")
analyze_throughput_decrease("tn")