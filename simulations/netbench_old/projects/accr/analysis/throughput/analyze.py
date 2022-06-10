import csv
import sys 
import os

##################################
# Analyze throughput
##################################

def analyze_throughput(input_file, output_file):

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
        output_file.write(str((time_axis[line]/1000000000) + 1) + "," + str(throughput[line]/1000000000) + "\n") # In seconds and Gbps
    output_file.close()

def analyze_throughput_merge(input_file1, input_file2, output_file):

    # Initialize the main variables for the analysis
    is_first_packet = True
    current_bucket = 0
    time_axis = {}
    time_axis[0] = None

    throughput = {}
    throughput[current_bucket] = 0

    # We analyze the first file as usual
    with open(input_file1) as csv_file1:
        csv_reader1 = csv.reader(csv_file1, delimiter=',')
        for row in csv_reader1:
            timestamp1 = float(row[0]) # in nanoseconds
            packetSizeBit = float(row[1])

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp1
                is_first_packet = False

            # We add the new packet size to the throughput
            throughput[current_bucket] = throughput[current_bucket] + packetSizeBit

            # We update the time buckets for monitoring
            difference_tracking = timestamp1-time_axis[current_bucket] # Is ns
            if (difference_tracking > 1000000000): #1s monitoring window

                # We initialize a new aggregation bucket
                current_bucket = current_bucket + 1
                time_axis[current_bucket] = timestamp1
                throughput[current_bucket] = 0

    # We then analyze the second file
    with open(input_file2) as csv_file2:
        csv_reader2 = csv.reader(csv_file2, delimiter=',')
        for row in csv_reader2:
            timestamp2 = timestamp1 + float(row[0]) # in nanoseconds (we add the last timestamp of the previous file to all of them (offset))
            packetSizeBit = float(row[1])

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp2
                is_first_packet = False

            # We add the new packet size to the throughput
            throughput[current_bucket] = throughput[current_bucket] + packetSizeBit

            # We update the time buckets for monitoring
            difference_tracking = timestamp2-time_axis[current_bucket] # Is ns
            if (difference_tracking > 1000000000): #1s monitoring window

                # We initialize a new aggregation bucket
                current_bucket = current_bucket + 1
                time_axis[current_bucket] = timestamp2
                throughput[current_bucket] = 0

    # Keep the data for the ground truth
    output_file = open(output_file, 'w+')
    output_file.write("#Time,Throughput\n")

    for line in range(0,current_bucket + 1):
        output_file.write(str((time_axis[line]/1000000000) + 1) + "," + str(throughput[line]/1000000000) + "\n")  # In seconds and Gbps
    output_file.close()

##################################
# Analyze packet drops
##################################

def analyze_drops(input_file, output_file):

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
        output_file.write(str((time_axis[line]/1000000000) + 1) + "," + str(drops[line]) + "\n")  # In seconds
    output_file.close()

def analyze_drops_merge(input_file1, input_file2, output_file):

    # Initialize the main variables for the analysis
    is_first_packet = True
    current_bucket = 0
    time_axis = {}
    time_axis[0] = None

    drops = {}
    drops[current_bucket] = 0

    # We analyze the first file as usual
    with open(input_file1) as csv_file1:
        csv_reader1 = csv.reader(csv_file1, delimiter=',')
        for row in csv_reader1:
            timestamp1 = float(row[0]) # in nanoseconds

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp1
                is_first_packet = False

            # We add the new packet to the drops
            drops[current_bucket] = drops[current_bucket] + 1

            # We update the time buckets for monitoring
            difference_tracking = timestamp1-time_axis[current_bucket] # Is ns
            if (difference_tracking > 1000000000): #1s monitoring window

                # We initialize a new aggregation bucket
                current_bucket = current_bucket + 1
                time_axis[current_bucket] = timestamp1
                drops[current_bucket] = 0

    # We then analyze the second file
    with open(input_file2) as csv_file2:
        csv_reader2 = csv.reader(csv_file2, delimiter=',')
        for row in csv_reader2:
            timestamp2 = timestamp1 + float(row[0]) # in nanoseconds (we add the last timestamp of the previous file to all of them (offset))

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp2
                is_first_packet = False

            # We add the new packet to the drops
            drops[current_bucket] = drops[current_bucket] + 1

            # We update the time buckets for monitoring
            difference_tracking = timestamp2-time_axis[current_bucket] # Is ns
            if (difference_tracking > 1000000000): #1s monitoring window

                # We initialize a new aggregation bucket
                current_bucket = current_bucket + 1
                time_axis[current_bucket] = timestamp2
                drops[current_bucket] = 0

    # Keep the data for the ground truth
    output_file = open(output_file, 'w+')
    output_file.write("#Time,Drops\n")

    for line in range(0,current_bucket + 1):
        output_file.write(str((time_axis[line]/1000000000) + 1) + "," + str(drops[line]) + "\n")  # In seconds
    output_file.close()


# Call analysis functions
if len(sys.argv) == 3:

    # We analyze the input log folder (sys.argv[1]) and store the result in (sys.argv[1])
    analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_benign.dat')
    analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_malicious.dat')

    analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_benign.dat')
    analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_malicious.dat')

    analyze_drops('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/packet_drops_benign.dat')
    analyze_drops('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/packet_drops_malicious.dat')

elif len(sys.argv) == 4:

    # We need to analyze the logs of two different folders (sys.argv[1], sys.argv[2]) and merge the results into one resulting folder (sys.argv[3])
    analyze_throughput_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_benign.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/input_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/input_throughput_benign.dat')
    analyze_throughput_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_malicious.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/input_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/input_throughput_malicious.dat')

    analyze_throughput_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_benign.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/output_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/output_throughput_benign.dat')
    analyze_throughput_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_malicious.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/output_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/output_throughput_malicious.dat')

    analyze_drops_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_benign.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/packet_drops_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/packet_drops_benign.dat')
    analyze_drops_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_malicious.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/packet_drops_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/packet_drops_malicious.dat')

else:
    print("Number of arguments required: 2 or 4")