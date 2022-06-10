# Runs with Python2

from __future__ import print_function
import time
from core import CoreAPI
from cluster import Cluster
from time import sleep
import sys
import csv
import schedule


class Controller:

    def read_cluster_statistics_and_update_priorities(self):

        ######################
        # Extract cluster ranges and counters
        ######################

        # We read the [min, max] ranges for each cluster
        for cluster_id in [1,2,3,4]:

            resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_dst0_min", 140)
            data_dict = next(resp)[0].to_dict()
            register_value_min = data_dict["MyIngress.cluster" + str(cluster_id) + "_dst0_min.f1"]
            resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_dst0_max", 140)
            data_dict = next(resp)[0].to_dict()
            register_value_max = data_dict["MyIngress.cluster" + str(cluster_id) + "_dst0_max.f1"]
            if self.enable_logging_clusters:
                print("(Read) cluster" + str(cluster_id) + "_dst0 [min, max] ==> [" + str(register_value_min[1]) + ", " + str(register_value_max[1]) + "]")

            resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_dst1_min", 140)
            data_dict = next(resp)[0].to_dict()
            register_value_min = data_dict["MyIngress.cluster" + str(cluster_id) + "_dst1_min.f1"]
            resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_dst1_max", 140)
            data_dict = next(resp)[0].to_dict()
            register_value_max = data_dict["MyIngress.cluster" + str(cluster_id) + "_dst1_max.f1"]
            if self.enable_logging_clusters:
                print("(Read) cluster" + str(cluster_id) + "_dst1 [min, max] ==> [" + str(register_value_min[1]) + ", " + str(register_value_max[1]) + "]")

            resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_dst2_min", 140)
            data_dict = next(resp)[0].to_dict()
            register_value_min = data_dict["MyIngress.cluster" + str(cluster_id) + "_dst2_min.f1"]
            resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_dst2_max", 140)
            data_dict = next(resp)[0].to_dict()
            register_value_max = data_dict["MyIngress.cluster" + str(cluster_id) + "_dst2_max.f1"]
            if self.enable_logging_clusters:
                print("(Read) cluster" + str(cluster_id) + "_dst2 [min, max] ==> [" + str(register_value_min[1]) + ", " + str(register_value_max[1]) + "]")

            resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_dst3_min", 140)
            data_dict = next(resp)[0].to_dict()
            register_value_min = data_dict["MyIngress.cluster" + str(cluster_id) + "_dst3_min.f1"]
            resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_dst3_max", 140)
            data_dict = next(resp)[0].to_dict()
            register_value_max = data_dict["MyIngress.cluster" + str(cluster_id) + "_dst3_max.f1"]
            if self.enable_logging_clusters:
                print("(Read) cluster" + str(cluster_id) + "_dst3 [min, max] ==> [" + str(register_value_min[1]) + ", " + str(register_value_max[1]) + "]")
                print("...")

        # We read the byte counter for each qid (i.e., each cluster)
        entries = self.core.get_entries("MyIngress.do_bytes_count", False)
        for entry in entries:
            key = entry[0]
            data = entry[1]
            qid = key['queue_id']['value']
            counter_value = data['$COUNTER_SPEC_BYTES']

            for cluster in self.cluster_list:
                if cluster.get_priority() == qid:
                    cluster.update_bytes_count(counter_value)
                    if self.enable_logging_cluster_counters:
                        print("(Read) do_bytes_count ==> cluster_id {}, counter_value {}".format(cluster.get_id(),counter_value))

        ######################
        # Priority computation
        ######################

        # We compute the new priorities, sorting the clusters by throughput
        clusters_by_throughput = {}
        list_position = 0
        for current_cluster in self.cluster_list:
            clusters_by_throughput[list_position] = current_cluster.get_bytes()
            list_position = list_position + 1

        clusters_by_throughput = sorted(clusters_by_throughput.items(), key=lambda item: item[1])
        prio = self.num_clusters - 1
        for tuple in clusters_by_throughput:
            self.cluster_list[tuple[0]].set_priority(prio) # smaller throughput, bigger priority
            prio = prio - 1

        # We deploy the new priorities to the data plane
        for cluster in self.cluster_list:
            self.core.modify_table("MyIngress.cluster_to_prio", [
                ([("meta.rs.cluster_id", cluster.get_id())],
                "MyIngress.set_qid", [("qid", cluster.get_priority())])
            ])
            if self.enable_logging_priorities:
                print("(Write: New priorities) cluster_to_prio <== cluster_id {}, new_assigned_priority {}".format(cluster.get_id(), cluster.get_priority()))

        # We reset the packet counters
        for qid in range(self.num_clusters):
            self.core.clear_counter_bytes("MyIngress.do_bytes_count", "queue_id", qid, 'MyIngress.bytes_count')
        print("------------------------------------------------------")

    def reset_clusters_and_clear_counters(self):

        if self.init: 
            
            # This is a trick such that the first 4 packet will be able to initialize the clusters with the usual methods. 
            # Basically we are inverting the ranges [min, max] = [255, 0], to make sure that the packet will have a smaller value that the min and a bigger than the max
            
            self.core.insert_register_entry("MyIngress.cluster1_dst0_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster1_dst0_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster1_dst1_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster1_dst1_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster1_dst2_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster1_dst2_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster1_dst3_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster1_dst3_max", 140, 0)
        
            self.core.insert_register_entry("MyIngress.cluster2_dst0_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster2_dst0_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster2_dst1_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster2_dst1_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster2_dst2_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster2_dst2_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster2_dst3_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster2_dst3_max", 140, 0)

            self.core.insert_register_entry("MyIngress.cluster3_dst0_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster3_dst0_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster3_dst1_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster3_dst1_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster3_dst2_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster3_dst2_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster3_dst3_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster3_dst3_max", 140, 0)

            self.core.insert_register_entry("MyIngress.cluster4_dst0_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster4_dst0_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster4_dst1_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster4_dst1_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster4_dst2_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster4_dst2_max", 140, 0)
            self.core.insert_register_entry("MyIngress.cluster4_dst3_min", 140, 255)
            self.core.insert_register_entry("MyIngress.cluster4_dst3_max", 140, 0)

        else:
                # We can specified a desired cluster initialization
                self.core.insert_register_entry("MyIngress.cluster1_dst0_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster1_dst0_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster1_dst1_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster1_dst1_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster1_dst2_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster1_dst2_max", 140, 127)
                self.core.insert_register_entry("MyIngress.cluster1_dst3_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster1_dst3_max", 140, 127)

                self.core.insert_register_entry("MyIngress.cluster2_dst0_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster2_dst0_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster2_dst1_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster2_dst1_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster2_dst2_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster2_dst2_max", 140, 127)
                self.core.insert_register_entry("MyIngress.cluster2_dst3_min", 140, 128)
                self.core.insert_register_entry("MyIngress.cluster2_dst3_max", 140, 255)

                self.core.insert_register_entry("MyIngress.cluster3_dst0_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster3_dst0_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster3_dst1_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster3_dst1_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster3_dst2_min", 140, 128)
                self.core.insert_register_entry("MyIngress.cluster3_dst2_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster3_dst3_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster3_dst3_max", 140, 127)

                self.core.insert_register_entry("MyIngress.cluster4_dst0_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster4_dst0_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster4_dst1_min", 140, 0)
                self.core.insert_register_entry("MyIngress.cluster4_dst1_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster4_dst2_min", 140, 128)
                self.core.insert_register_entry("MyIngress.cluster4_dst2_max", 140, 255)
                self.core.insert_register_entry("MyIngress.cluster4_dst3_min", 140, 128)
                self.core.insert_register_entry("MyIngress.cluster4_dst3_max", 140, 255)

        # We set the initialization counter to 1 so that clusters are initialized
        self.core.insert_register_entry("MyIngress.init_counter", 140, 1)
        self.core.insert_register_entry("MyIngress.updateclusters_counter", 140, 0)

        # We reset the packet counters
        for qid in range(self.num_clusters):
            self.core.clear_counter_bytes("MyIngress.do_bytes_count", "queue_id", qid, 'MyIngress.bytes_count')

    def read_throughput(self, file_throughput_benign, file_throughput_malicious):
        print("read_throughput")

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

        # We read the counter for benign traffic (we don't reset the counters at every iteration because otherwise we loose track of the packets between the read and write)
        entries = self.core.get_entries("MyEgress.do_bytes_count_benign_egress", False)
        for entry in entries:
            key = entry[0]
            data = entry[1]
            count_benign = data['$COUNTER_SPEC_BYTES']
            count_benign_bits = int(count_benign)*8
            if self.enable_logging_throughput:
                print("Count benign bits: " + count_benign_bits)

        # If there have been some packets hitting the counters
        if (count_malicious_bits > 0 or count_benign_bits > 0):

            # We compute the relative timestamp
            if self.first_pass:
                self.initial_timestamp = read_timestamp
                self.relative_timestamp = 0 # Relative with respect to origin
                
                relative_count_malicious_bits = count_malicious_bits
                relative_count_benign_bits = count_benign_bits

                self.first_pass = False
            else:
                # We measure the increase in timestamp w.r.t. last iteration, and the increase in each counter (we don't reset them)
                self.relative_timestamp = read_timestamp - self.initial_timestamp
                relative_count_malicious_bits = count_malicious_bits - self.last_count_malicious_bits
                relative_count_benign_bits = count_benign_bits - self.last_count_benign_bits

            file_throughput_malicious.write(str(self.relative_timestamp) + "," + str(relative_count_malicious_bits) + "\n")
            file_throughput_benign.write(str(self.relative_timestamp) + "," + str(relative_count_benign_bits) + "\n")

            self.last_count_malicious_bits = count_malicious_bits
            self.last_count_benign_bits = count_benign_bits

    def __init__(self):

        try:

            # ACC-Turbo configuration
            self.read_cluster_statistics_and_update_priorities_time = 1 # seconds
            self.reset_clusters_and_clear_counters_time = 100 # seconds

            self.num_clusters = 4
            self.feature_list = ["dst0", "dst1", "dst2", "dst3"]
            self.init = True # Whether we want the clusters to be initialized by the first k packets or not

            self.enable_logging_clusters = True
            self.enable_logging_priorities = True
            self.enable_logging_cluster_counters = True

            ## Throughput-measuring configuration            
            self.measure_throughput = True
            self.read_throughput_time = 9 # seconds (this is just for throughput printing, it does not impact performance)
            self.enable_logging_throughput = False

            # We create the log files for throughput plotting
            if self.measure_throughput: 
                file_throughput_benign = open("../run_fig_07b/results/accturbo_throughput_benign.dat", "w")
                file_throughput_benign.write("# Timestamp(ns),Bits\n")
                file_throughput_malicious = open("../run_fig_07b/results/accturbo_throughput_malicious.dat", "w")
                file_throughput_malicious.write("# Timestamp(ns),Bits\n")
                self.first_pass = True

            # We start the API
            self.core = CoreAPI()
            
            # We can list all the tables of the p4 program
            #self.core.list_tables()

            # We select the names of the tables we want to work with
            self.table_names = ["MyIngress.cluster1_dst0_min", "MyIngress.cluster1_dst0_max",
                                "MyIngress.cluster2_dst0_min", "MyIngress.cluster2_dst0_max",  
                                "MyIngress.cluster3_dst0_min", "MyIngress.cluster3_dst0_max", 
                                "MyIngress.cluster4_dst0_min", "MyIngress.cluster4_dst0_max",
                                
                                "MyIngress.cluster1_dst1_min", "MyIngress.cluster1_dst1_max",
                                "MyIngress.cluster2_dst1_min", "MyIngress.cluster2_dst1_max",  
                                "MyIngress.cluster3_dst1_min", "MyIngress.cluster3_dst1_max", 
                                "MyIngress.cluster4_dst1_min", "MyIngress.cluster4_dst1_max",

                                "MyIngress.cluster1_dst2_min", "MyIngress.cluster1_dst2_max",
                                "MyIngress.cluster2_dst2_min", "MyIngress.cluster2_dst2_max",  
                                "MyIngress.cluster3_dst2_min", "MyIngress.cluster3_dst2_max", 
                                "MyIngress.cluster4_dst2_min", "MyIngress.cluster4_dst2_max",
                                
                                "MyIngress.cluster1_dst3_min", "MyIngress.cluster1_dst3_max",
                                "MyIngress.cluster2_dst3_min", "MyIngress.cluster2_dst3_max",  
                                "MyIngress.cluster3_dst3_min", "MyIngress.cluster3_dst3_max", 
                                "MyIngress.cluster4_dst3_min", "MyIngress.cluster4_dst3_max",

                                "MyIngress.cluster_to_prio", "MyIngress.do_bytes_count", 
                                "MyIngress.init_counter", "MyIngress.updateclusters_counter",
                                
                                "MyEgress.timestamp",
                                "MyEgress.do_bytes_count_malicious_egress",
                                "MyEgress.do_bytes_count_benign_egress"]

            # We get the table objects associated to the table names specified
            # This creates a "self.tables = {}" dictionary in core API, with each of the table objects
            self.core.setup_tables(self.table_names)
            
            # We initialize the clusters and counters
            self.reset_clusters_and_clear_counters()
            
            # We initialize the register of the timestamp
            self.core.insert_register_entry("MyEgress.timestamp", 0, 0)

            # We reset the benign and malicious traffic counters
            self.core.clear_counter_bytes("MyEgress.do_bytes_count_malicious_egress", "hdr.ipv4_egress.dst_addr", 0x05050505, 'MyEgress.bytes_count_malicious_egress')
            #self.core.clear_counter_bytes("MyEgress.do_bytes_count_malicious_egress", "hdr.ipv4_egress.src_addr", 0x0a000032, 'MyEgress.bytes_count_malicious_egress') # carpet bombing or adversarial
            self.core.clear_counter_bytes("MyEgress.do_bytes_count_benign_egress", "eg_intr_md.egress_port", 140, 'MyEgress.bytes_count_benign_egress')

            # We initialize the cluster list, reading the priorities assigned from setup.py
            self.cluster_list = []
            empty_signature = {}

            # We read the current cluster_id -> prio mapping
            entries = self.core.get_entries("MyIngress.cluster_to_prio", False)
            for entry in entries:
                key = entry[0]
                data = entry[1]
                cluster_id = key['meta.rs.cluster_id']['value']
                current_priority = data['qid']
                if self.enable_logging_priorities:
                    print("(Read) cluster_to_prio ==> cluster_id {}, current_priority {}".format(cluster_id,current_priority))
                
                # We set the initial priorities to the cluster_id (does not really matter)
                new_cluster = Cluster(empty_signature, cluster_id, current_priority, self.feature_list)
                self.cluster_list.append(new_cluster)

            while(True):

                # We schedule the calls to the tofino API
                #schedule.every(self.reset_clusters_and_clear_counters_time).seconds.do(self.reset_clusters_and_clear_counters)
                schedule.every(self.read_cluster_statistics_and_update_priorities_time).seconds.do(self.read_cluster_statistics_and_update_priorities)
                if self.measure_throughput:
                    schedule.every(self.read_throughput_time).seconds.do(self.read_throughput, file_throughput_benign=file_throughput_benign, file_throughput_malicious=file_throughput_benign)

                while True:
                    schedule.run_pending()
                    time.sleep(1)

            # We close the logging files
            if self.measure_throughput:
                file_throughput_benign.close()
                file_throughput_malicious.close()
            
            # We exit the API
            self.core.tear_down()

        except KeyboardInterrupt:

            print("Caught KeyboardInterrupt. Program is finishing. please wait...")

            if not self.first_pass:

                # We close the logging files
                if self.measure_throughput:
                    file_throughput_benign.close()
                    file_throughput_malicious.close()

                    # We print the final counters, which we will use for evaluation
                    print("Total bps benign: " + str(self.last_count_benign_bits))
                    print("Total bps malicious: " + str(self.last_count_malicious_bits))

                    # We go through the files once again to convert the throughput to bps (not nanoseconds)
                    throughput_malicious = {}
                    throughput_benign = {}
                    total_time_seconds = int(self.relative_timestamp/1000000000) + 1

                    for i in range(0, total_time_seconds):
                        throughput_malicious[i] = 0
                        throughput_benign[i] = 0

                    with open("../run_fig_07b/results/accturbo_throughput_malicious.dat") as file:
                        reader = csv.reader(file)
                        for row in reader:
                            if row[0] != "# Timestamp(ns)":
                                timestamp_ns = int(row[0])
                                bits = int(row[1])
                                slot = int(timestamp_ns/1000000000)
                                throughput_malicious[slot] = throughput_malicious[slot] + bits
                    file.close()

                    with open("../run_fig_07b/results/accturbo_throughput_benign.dat") as file:
                        reader = csv.reader(file)
                        for row in reader:
                            if row[0] != "# Timestamp(ns)":
                                timestamp_ns = int(row[0])
                                bits = int(row[1])
                                slot = int(timestamp_ns/1000000000)
                                throughput_benign[slot] = throughput_benign[slot] + bits
                    file.close()

                    # Write results in file
                    w_malicious = open("../run_fig_07b/results/accturbo_throughput_malicious.dat", 'w')
                    w_malicious.write("# Timestamp(s),Bits\n")

                    w_benign = open("../run_fig_07b/results/accturbo_throughput_benign.dat", 'w')
                    w_benign.write("# Timestamp(s),Bits\n")

                    axis = range(0, total_time_seconds)
                    for line in range(0,len(axis)):
                        w_malicious.write("%s,%s\n" % (axis[line], throughput_malicious[line]))
                        w_benign.write("%s,%s\n" % (axis[line], throughput_benign[line]))

                    w_malicious.close()
                    w_benign.close()

if __name__ == "__main__":

    c = Controller()