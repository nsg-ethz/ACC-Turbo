import csv
import sys


##################################
# Analyze throughput
##################################

def analyze_throughput(input_file, output_file, type, start_time, end_time):

    # Read file
    total_throughput = {}
    throughput = {}
    for i in [1, 2, 3, 4, 5]:
        throughput[i] = {}

    for current_time in range(start_time, end_time):
        total_throughput[current_time] = 0
        for i in [1, 2, 3, 4, 5]:
            throughput[i][current_time] = 0

        with open(input_file) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:
                if str(row[0]) != "#Time":
                    timestamp = float(row[0])  # in nanoseconds
                    timestamp = timestamp/1000000000  # we convert it to seconds
                    packet_size_bit = float(row[1])
                    flow_id = int(row[2])
                    if timestamp >= current_time and timestamp < (current_time + 1):
                        # We add the new packet size to the throughput
                        throughput[flow_id][current_time] = throughput[flow_id][current_time] + packet_size_bit
                        total_throughput[current_time] = total_throughput[current_time] + packet_size_bit
                    elif timestamp >= (current_time + 1):
                        break
    csv_file.close()

    # Save results
    output_file = open(output_file, 'w+')
    output_file.write("#Time,Throughput1,Throughput2,Throughput3,Throughput4,Throughput5,TotalThroughput\n")
    if type == "input":
        for current_time in range(start_time, end_time):
            output_file.write(str(current_time*1000000000) + ",")
            for i in [1, 2, 3, 4, 5]:
                output_file.write(str((throughput[i][current_time])) + ",")
            output_file.write(str(total_throughput[current_time]) + "\n")
    else:  # We normalize the output to the link capacity
        for current_time in range(start_time, end_time):
            output_file.write(str(current_time*1000000000) + ",")
            for i in [1, 2, 3, 4, 5]:
                output_file.write(str((throughput[i][current_time] / 500000)) + ",")
            output_file.write(str(total_throughput[current_time] / 500000) + "\n")
    output_file.close()

def analyze_total_throughput(input_file, output_file, start_time, end_time):

    # Read file
    throughput = {}
    for current_time in range(start_time, end_time):
        throughput[current_time] = 0

        with open(input_file) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:
                if str(row[0]) != "#Time":
                    timestamp = float(row[0])  # it is in nanoseconds
                    timestamp = timestamp/1000000000  # we convert it to seconds
                    th = float(row[1])

                    if timestamp >= current_time and timestamp < (current_time + 1):
                        throughput[current_time] = throughput[current_time] + th
                    elif timestamp >= (current_time + 1):
                        break
        csv_file.close()

    # Save results
    out_file = open(output_file, 'w+')
    out_file.write("#Time, Throughput\n")
    for current_time in range(start_time, end_time):
        out_file.write(str(current_time*1000000000) + "," + str(throughput[current_time]) + "\n")  # In ns and Gbps
    out_file.close()


def analyze_drop_rate(input_throughput_file, drops_file, droprate_file, start_time, end_time):

    # Read the input throughput's log file
    total_input_throughput = {}

    for current_time in range(start_time, end_time):
        total_input_throughput[current_time] = 0

        with open(input_throughput_file) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:
                if str(row[0]) != "#Time":
                    timestamp = float(row[0])  # it is in nanoseconds
                    timestamp = timestamp/1000000000  # we convert it to seconds
                    th = float(row[6])

                    if timestamp >= current_time and timestamp < float(current_time + 1):
                        total_input_throughput[current_time] = total_input_throughput[current_time] + th
                    elif timestamp >= (current_time + 1):
                        break
        csv_file.close()

    # Read the packet drops log file
    total_drops_throughput = {}
    for current_time in range(start_time, end_time):
        total_drops_throughput[current_time] = 0

        with open(drops_file) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:
                if str(row[0]) != "#Time":
                    timestamp = float(row[0])  # it is in nanoseconds
                    timestamp = timestamp/1000000000  # we convert it to seconds
                    th = float(row[1])

                    if timestamp >= current_time and timestamp < (current_time + 1):
                        total_drops_throughput[current_time] = total_drops_throughput[current_time] + th
                    elif timestamp >= (current_time + 1):
                        break
    csv_file.close()

    # Save results
    output_file = open(droprate_file, 'w+')
    output_file.write("#Time,DropRate\n")
    for current_time in range(start_time, end_time):
        drop_rate = total_drops_throughput[current_time] / total_input_throughput[current_time]
        output_file.write(str(current_time*1000000000) + "," + str(drop_rate) + "\n")
    output_file.close()

# Call analysis functions
if __name__ == "__main__":

    print(sys.argv)

    # Call analysis functions
    for K in [10, 15, 20, 25, 30, 35]:

        analyze_throughput('temp/accturbo/acc_reactiontime/K{}/aggregate_input_throughput.csv.log'.format(K),
                           'projects/accturbo/analysis/acc_reactiontime/K{}/aggregate_input_throughput.dat'.format(K),
                           "input", 0, 50)

        analyze_throughput('temp/accturbo/acc_reactiontime/K{}/aggregate_output_throughput.csv.log'.format(K),
                           'projects/accturbo/analysis/acc_reactiontime/K{}/aggregate_output_throughput.dat'.format(K), "output", 0, 50)

        analyze_total_throughput('temp/accturbo/acc_reactiontime/K{}/aggregate_drops.csv.log'.format(K),
                                 'projects/accturbo/analysis/acc_reactiontime/K{}/aggregate_total_drops.dat'.format(K), 0, 50)

        analyze_drop_rate('projects/accturbo/analysis/acc_reactiontime/K{}/aggregate_input_throughput.dat'.format(K),
                          'projects/accturbo/analysis/acc_reactiontime/K{}/aggregate_total_drops.dat'.format(K),
                          'projects/accturbo/analysis/acc_reactiontime/K{}/aggregate_droprate.dat'.format(K),
                          0, 50)