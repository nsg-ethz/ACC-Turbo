import csv

def get_drops(input_throughput_file, output_throughput_file):

    benign_input = 0
    benign_output = 0

    # Read input-throughput file
    with open(input_throughput_file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            if str(row[0]) != "#Time":
                timestamp = float(row[0])  # in nanoseconds
                timestamp = timestamp/1000000000  # we convert it to seconds
                packet_size_bit = float(row[1])
                flow_id = int(row[2])
                if flow_id < 5:
                    benign_input = benign_input + packet_size_bit
    csv_file.close()

    # Read output-throughput file
    with open(output_throughput_file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            if str(row[0]) != "#Time":
                timestamp = float(row[0])  # in nanoseconds
                timestamp = timestamp/1000000000  # we convert it to seconds
                packet_size_bit = float(row[1])
                flow_id = int(row[2])
                if flow_id < 5:
                    benign_output = benign_output + packet_size_bit
    csv_file.close()

    # Compute drop percentages
    return (benign_input - benign_output)/benign_input * 100


def analyze_accuracy(input_throughput_file, output_throughput_file, results_file, scheduler, fifo_drops, accturbo_drops):

    benign_input = 0
    benign_output = 0

    # Read input-throughput file
    with open(input_throughput_file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            if str(row[0]) != "#Time":
                timestamp = float(row[0])  # in nanoseconds
                timestamp = timestamp/1000000000  # we convert it to seconds
                packet_size_bit = float(row[1])
                flow_id = int(row[2])
                if flow_id < 5:
                    benign_input = benign_input + packet_size_bit
    csv_file.close()

    # Read output-throughput file
    with open(output_throughput_file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            if str(row[0]) != "#Time":
                timestamp = float(row[0])  # in nanoseconds
                timestamp = timestamp/1000000000  # we convert it to seconds
                packet_size_bit = float(row[1])
                flow_id = int(row[2])
                if flow_id < 5:
                    benign_output = benign_output + packet_size_bit
    csv_file.close()

    # Compute drop percentages
    benign_drops = (benign_input - benign_output)/benign_input * 100

    # Save results
    if scheduler == "K10":
        output_file = open(results_file, 'w')
        output_file.write("#K, % Benign Drops, FIFO Drops, ACCTurbo Drops\n")
        output_file.write("{},{},{},{}\n".format(scheduler, benign_drops, fifo_drops, accturbo_drops))
        output_file.close()
    else:
        output_file = open(results_file, 'a')
        output_file.write("{},{},{},{}\n".format(scheduler, benign_drops, fifo_drops, accturbo_drops))
        output_file.close()

# Call analysis functions
if __name__ == "__main__":

    fifo_drops = get_drops('temp/accturbo/acc_accuracy_K/fifo/aggregate_input_throughput.csv.log',
                     'temp/accturbo/acc_accuracy_K/fifo/aggregate_output_throughput.csv.log')

    accturbo_drops =  get_drops('temp/accturbo/acc_accuracy_K/accturbo/aggregate_input_throughput.csv.log',
                             'temp/accturbo/acc_accuracy_K/accturbo/aggregate_output_throughput.csv.log')
    # Call analysis functions
    for scheduler in ["K10", "K25", "K50", "K100", "K250", "K500", "K1000", "K1500", "K2000"]:
        analyze_accuracy('temp/accturbo/acc_accuracy_K/{}/aggregate_input_throughput.csv.log'.format(scheduler),
                         'temp/accturbo/acc_accuracy_K/{}/aggregate_output_throughput.csv.log'.format(scheduler),
                         'projects/accturbo/analysis/acc_accuracy_K/benign_drops.dat', scheduler, fifo_drops, accturbo_drops)