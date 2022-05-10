import csv 

first = True
with open('attack_pifo_range_fast_manhattan_10_allfeatures/output_throughput_benign.dat') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    throughput_in = 0
    for row in csv_reader:
        if first:
            first = False
            continue

        timestamp = float(row[0])
        throughput_s = float(row[1])
        throughput_in = throughput_in + throughput_s

    print(throughput_in)