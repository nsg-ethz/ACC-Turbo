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
            sleep_time = 0
            enable_logging = False
            measure_throughput = True
            BLOOM_FILTER_ENTRIES = 1024
            
            # We create the log files for the evaluation
            if measure_throughput:
                file_throughput_benign = open("analysis/throughput_benign.dat", "w")
                file_throughput_benign.write("# Timestamp(ns),Bits\n")
                file_throughput_malicious = open("analysis/throughput_malicious.dat", "w")
                file_throughput_malicious.write("# Timestamp(ns),Bits\n")
                first_pass = True

            # We start the API
            self.core = CoreAPI()
            self.table_names = ["MyIngress.counting_bloom_filter", 
                                "MyEgress.timestamp",
                                "MyEgress.do_bytes_count_malicious_egress",
                                "MyEgress.do_bytes_count_benign_egress"]
            self.core.setup_tables(self.table_names)

            # We read the intial entries
            if enable_logging:

                # We can't print all entries, so we print the max and the min
                max_counter = 0
                min_counter = 0

                for entry in range(BLOOM_FILTER_ENTRIES):           
                    resp = self.core.get_register_entry("MyIngress.counting_bloom_filter", entry)
                    data_dict = next(resp)[0].to_dict()
                    register_value = data_dict["MyIngress.counting_bloom_filter.f1"]
                    
                    if register_value[1] < min_counter:
                        min_counter = register_value[1]
                    
                    elif register_value[1] > max_counter:
                        max_counter = register_value[1]

                # We print the result
                print("(Read counting_bloom_filter) Max  ==> " + str(max_counter) + "; Min  ==> " + str(min_counter) + "\n ......................................................")

            # We initialize the register of the timestamp
            self.core.insert_register_entry("MyEgress.timestamp", 0, 0)

            # We reset the counters
            if len(sys.argv) > 1 and "carpetbombing" in sys.argv:
                self.core.clear_counter_bytes("MyEgress.do_bytes_count_malicious_egress", "hdr.ipv4_egress.src_addr", 0x0a000032, 'MyEgress.bytes_count_malicious_egress')
            else:
                self.core.clear_counter_bytes("MyEgress.do_bytes_count_malicious_egress", "hdr.ipv4_egress.dst_addr", 0x05050505, 'MyEgress.bytes_count_malicious_egress')
            self.core.clear_counter_bytes("MyEgress.do_bytes_count_benign_egress", "eg_intr_md.egress_port", 140, 'MyEgress.bytes_count_benign_egress')

            while(True):
                sleep(sleep_time)

                if enable_logging:

                    # We initialize the max/min counter values at each iteration
                    max_counter = 0
                    min_counter = 0
                
                # We clear the bloom filter entries
                for entry in range(BLOOM_FILTER_ENTRIES):

                    # We keep track of the top values
                    if enable_logging:

                        # We read their value
                        resp = self.core.get_register_entry("MyIngress.counting_bloom_filter", entry)
                        data_dict = next(resp)[0].to_dict()
                        register_value = data_dict["MyIngress.counting_bloom_filter.f1"]

                        if register_value[1] < min_counter:
                            min_counter = register_value[1]
                        
                        elif register_value[1] > max_counter:
                            max_counter = register_value[1]

                    # We reset its value
                    self.core.insert_register_entry("MyIngress.counting_bloom_filter", entry, 0)            

                # We print the result 
                print("All entries updated")          
                if enable_logging:
                    print("(Read counting_bloom_filter) Max  ==> " + str(max_counter) + "; Min  ==> " + str(min_counter) + "\n......................................................")


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

                    with open("analysis/throughput_malicious.dat") as file:
                        reader = csv.reader(file)
                        for row in reader:
                            if row[0] != "# Timestamp(ns)":
                                timestamp_ns = int(row[0])
                                bits = int(row[1])
                                slot = int(timestamp_ns/1000000000)
                                throughput_malicious[slot] = throughput_malicious[slot] + bits
                    file.close()

                    with open("analysis/throughput_benign.dat") as file:
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
                    w_malicious = open("analysis/throughput_malicious.dat", 'w')
                    w_malicious.write("# Timestamp(s),Bits\n")

                    w_benign = open("analysis/throughput_benign.dat", 'w')
                    w_benign.write("# Timestamp(s),Bits\n")

                    axis = range(0, total_time_seconds)
                    for line in range(0,len(axis)):
                        w_malicious.write("%s,%s,%s\n" % (axis[line], throughput_malicious[line], ma_throughput_malicious[line]))
                        w_benign.write("%s,%s,%s\n" % (axis[line], throughput_benign[line], ma_throughput_benign[line]))

                    w_malicious.close()
                    w_benign.close()

if __name__ == "__main__":
    c = Controller()