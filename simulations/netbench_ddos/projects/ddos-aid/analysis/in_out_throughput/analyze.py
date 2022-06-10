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
            output_file.write(str((time_axis[line])) + "," + str(throughput[line]) + "\n") # In seconds and bps
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
        if(time_axis[line] != None):
            output_file.write(str((time_axis[line])) + "," + str(throughput[line]) + "\n") # In seconds and bps
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
            packetSizeBit = float(row[1])

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp
                is_first_packet = False

            # We add the new packet to the drops
            drops[current_bucket] = drops[current_bucket] + packetSizeBit

            # We update the time buckets for monitoring
            difference_tracking = timestamp-time_axis[current_bucket] # Is ns
            if (difference_tracking > 1000000000): #1s monitoring window

                # We initialize a new aggregation bucket
                current_bucket = current_bucket + packetSizeBit
                time_axis[current_bucket] = timestamp
                drops[current_bucket] = 0

    # Keep the data for the ground truth
    output_file = open(output_file, 'w+')
    output_file.write("#Time,Drops\n")

    for line in range(0,current_bucket + 1):
        if(time_axis[line] != None):
            output_file.write(str((time_axis[line])) + "," + str(drops[line]) + "\n")  # In seconds
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
            packetSizeBit = float(row[1])

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp1
                is_first_packet = False

            # We add the new packet to the drops
            drops[current_bucket] = drops[current_bucket] + packetSizeBit

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
            packetSizeBit = float(row[1])

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = timestamp2
                is_first_packet = False

            # We add the new packet to the drops
            drops[current_bucket] = drops[current_bucket] + packetSizeBit

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
        if(time_axis[line] != None):
            output_file.write(str((time_axis[line])) + "," + str(drops[line]) + "\n") # In seconds and bps
    output_file.close()

##################################
# Analyze throughput decrease
##################################

def analyze_throughput_decrease(input_throughput_file_name, output_throughput_file_name, results_file_name):

    # The two files where we get the throughput from
    input_throughput_file = open(input_throughput_file_name, "r")
    output_throughput_file = open(output_throughput_file_name, "r")

    # The file where we will store the throughput decrease
    results_file = open(results_file_name, "w+")
    results_file.write("#Time,Throughput_decrease\n")

    # Skip first line
    first_line = True

    # We read the input throughput at each time slot
    for input_throughput_line in input_throughput_file:

        # We read the output throughput at each time slot
        output_throughput_line = output_throughput_file.readline()

        input_throughput_line = str(input_throughput_line).split("\n")[0]
        output_throughput_line = str(output_throughput_line).split("\n")[0]
        print(output_throughput_line)

        if first_line == True:
            first_line = False
            continue
        
        # We parse the line (string)
        if (len(input_throughput_line.split(",")) != 2 or len(output_throughput_line.split(",")) != 2):
            continue

        input_throughput_value = input_throughput_line.split(",")[1]
        output_throughput_value = output_throughput_line.split(",")[1]
        output_time = output_throughput_line.split(",")[0]

        # We convert to float the values
        input_throughput_value = float(input_throughput_value)
        output_throughput_value = float(output_throughput_value)

        # We compute the throughput decrease
        throughput_decrease = 100 - ((output_throughput_value/input_throughput_value)*100)
        
        # We store the results on a file
        results_file.write(str((output_time)) + "," + str(throughput_decrease) + "\n")
    results_file.close()


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

    #analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_benign.dat')
    #analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_malicious.dat')
    #add_padding(0,30,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_benign.dat')
    #add_padding(0,30,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_malicious.dat')

    #analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_benign.dat')
    #analyze_throughput('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_malicious.dat')
    #add_padding(0,30,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_benign.dat')
    #add_padding(0,30,'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_malicious.dat')

    #analyze_drops('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/packet_drops_benign.dat')
    #analyze_drops('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/packet_drops_malicious.dat')

    analyze_throughput_decrease('netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_benign.dat', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_benign.dat', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_decrease_benign.dat')
    analyze_throughput_decrease('netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/input_throughput_malicious.dat', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_malicious.dat', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[2] + '/output_throughput_decrease_malicious.dat')


elif len(sys.argv) == 4:

    # Input throughput processing (benign and malicious)
    #analyze_throughput_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_benign.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/input_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/input_throughput_benign.dat')
    #analyze_throughput_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/input_throughput_malicious.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/input_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/input_throughput_malicious.dat')

    # Output throughput processing (benign and malicious)
    #analyze_throughput_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_benign.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/output_throughput_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/output_throughput_benign.dat')
    #analyze_throughput_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/output_throughput_malicious.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/output_throughput_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/output_throughput_malicious.dat')

    # Packet drops processing (benign and malicious)
    analyze_drops_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_benign.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/packet_drops_benign.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/packet_drops_benign.dat')
    analyze_drops_merge('netbench_ddos/temp/ddos-aid/' + sys.argv[1] + '/packet_drops_malicious.csv.log', 'netbench_ddos/temp/ddos-aid/' + sys.argv[2] + '/packet_drops_malicious.csv.log', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/packet_drops_malicious.dat')

    #analyze_throughput_decrease('netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/input_throughput_benign.dat', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/output_throughput_benign.dat', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/throughput_decrease_benign.dat')
    #analyze_throughput_decrease('netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/input_throughput_malicious.dat', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/output_throughput_malicious.dat', 'netbench_ddos/projects/ddos-aid/analysis/' + sys.argv[3] + '/throughput_decrease_malicious.dat')

else:
    print("Number of arguments required: 3 or 4")

