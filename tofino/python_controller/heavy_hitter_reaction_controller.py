# Runs with Python2

from __future__ import print_function
import time
from core import CoreAPI
from cluster import Cluster
from time import sleep
import sys
import csv

class Controller:

    def __init__(self):

        try:

            # Configuration
            measure_throughput = True
            BLOOM_FILTER_ENTRIES = 1024
            threshold = 5000000
            threshold_hit_once = False
            entry_updated = False
            relative_timestamp = 0
            last_time_check = 0
            
            # We create the log files for the evaluation
            if measure_throughput:
                file_throughput_benign = open("../run_fig_07d/results/jaqen_throughput_benign.dat", "w")
                file_throughput_benign.write("# Timestamp(ns),Bits\n")
                file_throughput_malicious = open("../run_fig_07d/results/jaqen_throughput_malicious.dat", "w")
                file_throughput_malicious.write("# Timestamp(ns),Bits\n")
                first_pass = True

            # We start the API
            self.core = CoreAPI()
            self.table_names = ["MyIngress.counting_bloom_filter",
                                "MyIngress.tbl_drop",
                                "MyEgress.timestamp",
                                "MyEgress.do_bytes_count_malicious_egress",
                                "MyEgress.do_bytes_count_benign_egress"]

            self.core.setup_tables(self.table_names)
            #self.core.list_tables()

            # We initialize the register of the timestamp
            self.core.insert_register_entry("MyEgress.timestamp", 0, 0)

            # We reset the counters
            self.core.clear_counter_bytes("MyEgress.do_bytes_count_malicious_egress", "hdr.ipv4_egress.dst_addr", 0x05050505, 'MyEgress.bytes_count_malicious_egress')
            self.core.clear_counter_bytes("MyEgress.do_bytes_count_benign_egress", "eg_intr_md.egress_port", 140, 'MyEgress.bytes_count_benign_egress')

            while(True):
                
                # We clear the bloom filter entries
                #for entry in range(BLOOM_FILTER_ENTRIES):
                entry = 9 # We directly set the entry of the attack, otherwise gets slow

                if (relative_timestamp - last_time_check) > 5000000000: # Every 5 seconds, we check the counter

                    last_time_check = relative_timestamp

                    # We read their value of the counters and reset it and see if it reaches threshold. If yes, then we drop
                    resp = self.core.get_register_entry("MyIngress.counting_bloom_filter", entry)
                    data_dict = next(resp)[0].to_dict()
                    register_value = data_dict["MyIngress.counting_bloom_filter.f1"]
                    print("-> " + str(register_value[1]))
                    
                    # We check if it reaches the threshold one time
                    if int(register_value[1]) > threshold and threshold_hit_once == False:
                        print("Threshold hit once" + str(relative_timestamp))
                        threshold_hit_once = True

                    # Then we verify if it reaches the threshold another time
                    elif int(register_value[1]) > (threshold) and threshold_hit_once == True and entry_updated == False:
                        self.core.program_table("MyIngress.tbl_drop", [([("hdr.ipv4.dst_addr", 0x05050505)], "MyIngress.drop",[])])
                        print("Malicious traffic blocked" + str(relative_timestamp))
                        entry_updated = True

                    # We reset its value
                    self.core.insert_register_entry("MyIngress.counting_bloom_filter", entry, 0)            

                # We measure the throughput obtained by benign and malicious traffic
                if measure_throughput == True:

                    # We read the latest timestamp
                    resp = self.core.get_register_entry("MyEgress.timestamp", 0)
                    data_dict = next(resp)[0].to_dict()
                    read_timestamp = data_dict["MyEgress.timestamp.f1"][1]

                    # We need to multiply by 2^16, since we have shifted 16 bits to the right in the tofino
                    read_timestamp = int(read_timestamp) << 16 # Now we have it in nanoseconds

                    # We read the counter for malicious traffic
                    entries = self.core.get_entries("MyEgress.do_bytes_count_malicious_egress", False)
                    for entry in entries:
                        key = entry[0]
                        data = entry[1]
                        count_malicious = data['$COUNTER_SPEC_BYTES']
                        count_malicious_bits = int(count_malicious)*8

                    # We read the counter for benign traffic
                    entries = self.core.get_entries("MyEgress.do_bytes_count_benign_egress", False)
                    for entry in entries:
                        key = entry[0]
                        data = entry[1]
                        count_benign = data['$COUNTER_SPEC_BYTES']
                        count_benign_bits = int(count_benign)*8
                        print(count_benign_bits)


                    # We don't reset the counters at every iteration because otherwise we loose track of the packets in between

                    # If there have been some packets hitting the counters
                    if (count_malicious_bits > 0 or count_benign_bits > 0):

                        # We compute the relative timestamp
                        if first_pass:
                            initial_timestamp = read_timestamp
                            relative_timestamp = 0 # Relative with respect to origin
                            
                            relative_count_malicious_bits = count_malicious_bits
                            relative_count_benign_bits = count_benign_bits

                            first_pass = False
                        else:

                            # We measure the increase in timestamp w.r.t. last iteration, and the increase in each counter (we don't reset them)
                            relative_timestamp = read_timestamp - initial_timestamp
                            relative_count_malicious_bits = count_malicious_bits - last_count_malicious_bits
                            relative_count_benign_bits = count_benign_bits - last_count_benign_bits

                        file_throughput_malicious.write(str(relative_timestamp) + "," + str(relative_count_malicious_bits) + "\n")
                        file_throughput_benign.write(str(relative_timestamp) + "," + str(relative_count_benign_bits) + "\n")

                        last_count_malicious_bits = count_malicious_bits
                        last_count_benign_bits = count_benign_bits

            # We close the logging files
            if measure_throughput:
                file_throughput_benign.close()
                file_throughput_malicious.close()

            # We exit the API       
            self.core.tear_down()

        except KeyboardInterrupt:

            print("Caught KeyboardInterrupt. Program is finishing. please wait...")

            if not first_pass:

                # We close the logging files
                if measure_throughput:
                    file_throughput_benign.close()
                    file_throughput_malicious.close()

                    # We print the final counters, which we will use for evaluation
                    print("Total bps benign: " + str(last_count_benign_bits))
                    print("Total bps malicious: " + str(last_count_malicious_bits))

                    # We go through the files once again to convert the throughput to bps (not nanoseconds)
                    throughput_malicious = {}
                    throughput_benign = {}
                    ma_throughput_malicious = {}
                    ma_throughput_benign = {}
                    total_time_seconds = int(relative_timestamp/1000000000) + 1

                    for i in range(0, total_time_seconds):
                        throughput_malicious[i] = 0
                        throughput_benign[i] = 0
                        ma_throughput_malicious[i] = 0
                        ma_throughput_benign[i] = 0

                    with open("../run_fig_07d/results/jaqen_throughput_malicious.dat") as file:
                        reader = csv.reader(file)
                        for row in reader:
                            if row[0] != "# Timestamp(ns)":
                                timestamp_ns = int(row[0])
                                bits = int(row[1])
                                slot = int(timestamp_ns/1000000000)
                                throughput_malicious[slot] = throughput_malicious[slot] + bits
                    file.close()

                    with open("../run_fig_07d/results/jaqen_throughput_benign.dat") as file:
                        reader = csv.reader(file)
                        for row in reader:
                            if row[0] != "# Timestamp(ns)":
                                timestamp_ns = int(row[0])
                                bits = int(row[1])
                                slot = int(timestamp_ns/1000000000)
                                throughput_benign[slot] = throughput_benign[slot] + bits
                    file.close()

                    # We compute a simple moving average (just a window of 2 samples) to smoothen the throughput variation
                    for slot in range(1,total_time_seconds):
                        ma_throughput_malicious[slot] = (throughput_malicious[slot-1] + throughput_malicious[slot])/2
                        ma_throughput_benign[slot] = (throughput_benign[slot-1] + throughput_benign[slot])/2

                    # Write results in file
                    w_malicious = open("../run_fig_07d/results/jaqen_throughput_malicious.dat", 'w')
                    w_malicious.write("# Timestamp(s),Bits\n")

                    w_benign = open("../run_fig_07d/results/jaqen_throughput_benign.dat", 'w')
                    w_benign.write("# Timestamp(s),Bits\n")

                    axis = range(0, total_time_seconds)
                    for line in range(0,len(axis)):
                        w_malicious.write("%s,%s,%s\n" % (axis[line], throughput_malicious[line], ma_throughput_malicious[line]))
                        w_benign.write("%s,%s,%s\n" % (axis[line], throughput_benign[line], ma_throughput_benign[line]))

                    w_malicious.close()
                    w_benign.close()

if __name__ == "__main__":
    c = Controller()