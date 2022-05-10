import csv
import sys 
import os

##################################
# Analyze throughput
##################################

def analyze_throughput(input_file, output_file):

    print("Analyzing throughput of: " + str(input_file))

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

    # Keep the data for the ground truth
    output_file = open(output_file, 'w+')
    output_file.write("#Time,Throughput\n")

    for line in range(0,current_bucket + 1):
        if(time_axis[line] != None):
            output_file.write(str((time_axis[line]/1000000000)) + "," + str(throughput[line]/1000000000) + "\n") # In seconds and Gbps
    output_file.close()

##################################
# Analyze packet drops
##################################

def analyze_drops(input_file, output_file):

    print("Analyzing drops of: " + str(input_file))

    # Initialize the main variables for the analysis
    is_first_packet = True
    current_bucket = 0
    time_axis = {}
    time_axis[0] = None

    drops = {}
    drops[current_bucket] = 0

    with open(input_file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            timestamp = float(row[0]) # in nanoseconds

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp
                is_first_packet = False

            # We add the new packet to the drops
            drops[current_bucket] = drops[current_bucket] + 1

            # We update the time buckets for monitoring
            difference_tracking = timestamp-time_axis[current_bucket] # Is ns
            if (difference_tracking > 1000000000): #1s monitoring window

                # We initialize a new aggregation bucket
                current_bucket = current_bucket + 1
                time_axis[current_bucket] = timestamp
                drops[current_bucket] = 0

    # Keep the data for the ground truth
    output_file = open(output_file, 'w+')
    output_file.write("#Time,Drops\n")

    for line in range(0,current_bucket + 1):
        if(time_axis[line] != None):
            output_file.write(str((time_axis[line]/1000000000)) + "," + str(drops[line]) + "\n")  # In seconds
    output_file.close()


def add_padding(start_time, end_time, file):

    print("Adding padding to : " + str(file))

    throughput = {}
    for current_time in range(start_time, end_time):
        throughput[current_time] = 0

        with open(file) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:
                if str(row[0]) != "#Time":
                    timestamp = float(row[0]) # in seconds
                    th = float(row[1])
                    
                    if (timestamp >= current_time and timestamp < (current_time + 1)):
                        throughput[current_time] = throughput[current_time] + th
                    elif (timestamp >= (current_time + 1)):
                        break
        csv_file.close()

    output_file = open(file, 'w+')
    output_file.write("#Time, Throughput\n")
    for current_time in range(start_time, end_time):
        output_file.write(str(current_time) + "," + str(throughput[current_time]) + "\n") # In seconds and Gbps
    output_file.close()

# Call analysis functions
if len(sys.argv) == 3:

    # We analyze the input log folder (sys.argv[1]) and store the result in (sys.argv[1])
    analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_benign.dat')
    analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_malicious.dat')
    add_padding(0,45,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_benign.dat')
    add_padding(0,45,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_malicious.dat')

    analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_benign.dat')
    analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_malicious.dat')
    add_padding(0,45,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_benign.dat')
    add_padding(0,45,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_malicious.dat')

    analyze_drops('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/packet_drops_benign.dat')
    analyze_drops('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/packet_drops_malicious.dat')
    add_padding(0,45,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/packet_drops_benign.dat')
    add_padding(0,45,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/packet_drops_malicious.dat')

else:
    print("Number of arguments required: 2 or 4")