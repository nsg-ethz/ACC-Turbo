# Runs with Python2

from __future__ import print_function
import time
from core import CoreAPI
from cluster import Cluster
from time import sleep
import sys

class Controller:

    def __init__(self):

        self.core = CoreAPI()
        
        # We can instantiate a logger
        range_evolution = open("range_evolution.dat", 'w')
        range_evolution.write("#iteration_number, c1_id, c2_id, c3_id, c4_id")
        iteration = 0
        
        # We can first list all the tables of the p4 program
        #self.core.list_tables()

        # We select the names of the tables we want to work with
        self.table_names = ["MyIngress.cluster1_len_min", "MyIngress.cluster1_len_max",
                            "MyIngress.cluster2_len_min", "MyIngress.cluster2_len_max",  
                            "MyIngress.cluster3_len_min", "MyIngress.cluster3_len_max", 
                            "MyIngress.cluster4_len_min", "MyIngress.cluster4_len_max",
                            
                            "MyIngress.cluster1_ttl_min", "MyIngress.cluster1_ttl_max",
                            "MyIngress.cluster2_ttl_min", "MyIngress.cluster2_ttl_max",  
                            "MyIngress.cluster3_ttl_min", "MyIngress.cluster3_ttl_max", 
                            "MyIngress.cluster4_ttl_min", "MyIngress.cluster4_ttl_max",

                            "MyIngress.cluster1_proto_min", "MyIngress.cluster1_proto_max",
                            "MyIngress.cluster2_proto_min", "MyIngress.cluster2_proto_max",  
                            "MyIngress.cluster3_proto_min", "MyIngress.cluster3_proto_max", 
                            "MyIngress.cluster4_proto_min", "MyIngress.cluster4_proto_max",

                            "MyIngress.cluster1_id_min", "MyIngress.cluster1_id_max",
                            "MyIngress.cluster2_id_min", "MyIngress.cluster2_id_max",  
                            "MyIngress.cluster3_id_min", "MyIngress.cluster3_id_max", 
                            "MyIngress.cluster4_id_min", "MyIngress.cluster4_id_max",
                              
                            "MyIngress.cluster_to_prio", 
                            
                            "MyEgress.do_packet_count", 
                            "MyEgress.do_bytes_count"]

        # We get the table objects associated to the table names specified
        # This creates a "self.tables = {}" dictionary in core API, with each of the table objects
        self.core.setup_tables(self.table_names)
        
        # We initialize the cluster list, reading the priorities assigned from setup.py
        self.num_clusters = 4
        self.cluster_list = []
        feature_list = ["id", "ttl", "proto", "len"]
        empty_signature = {}

        # We read the current cluster_id -> prio mapping
        #self.core.print_table_info("MyIngress.cluster_to_prio")
        entries = self.core.get_entries("MyIngress.cluster_to_prio", False)
        for entry in entries:
            key = entry[0]
            data = entry[1]
            cluster_id = key['meta.cluster_id']['value']
            current_priority = data['qid']
            print("(Read) cluster_to_prio ==> cluster_id {}, current_priority {}".format(cluster_id,current_priority))
            
            # We set the initial priorities to the cluster_id (does not really matter)
            new_cluster = Cluster(empty_signature, cluster_id, current_priority, feature_list)
            self.cluster_list.append(new_cluster)

        # Every 1ms:
        while(True):
            sleep(5) #5s

            # We need to read the [min, max] ranges for each cluster, and the cluster size
            for cluster_id in [1,2,3,4]:
                cluster_signature = {}

                resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_len_min", 140)
                data_dict = next(resp)[0].to_dict()
                register_value_min = data_dict["MyIngress.cluster" + str(cluster_id) + "_len_min.f1"]
                resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_len_max", 140)
                data_dict = next(resp)[0].to_dict()
                register_value_max = data_dict["MyIngress.cluster" + str(cluster_id) + "_len_max.f1"]
                print("(Read) cluster" + str(cluster_id) + "_len [min, max] ==> [" + str(register_value_min) + ", " + str(register_value_max) + "]")

                resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_ttl_min", 140)
                data_dict = next(resp)[0].to_dict()
                register_value_min = data_dict["MyIngress.cluster" + str(cluster_id) + "_ttl_min.f1"]
                resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_ttl_max", 140)
                data_dict = next(resp)[0].to_dict()
                register_value_max = data_dict["MyIngress.cluster" + str(cluster_id) + "_ttl_max.f1"]
                print("(Read) cluster" + str(cluster_id) + "_ttl [min, max] ==> [" + str(register_value_min) + ", " + str(register_value_max) + "]")

                resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_proto_min", 140)
                data_dict = next(resp)[0].to_dict()
                register_value_min = data_dict["MyIngress.cluster" + str(cluster_id) + "_proto_min.f1"]
                resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_proto_max", 140)
                data_dict = next(resp)[0].to_dict()
                register_value_max = data_dict["MyIngress.cluster" + str(cluster_id) + "_proto_max.f1"]
                print("(Read) cluster" + str(cluster_id) + "_proto [min, max] ==> [" + str(register_value_min) + ", " + str(register_value_max) + "]")

                resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_id_min", 140)
                data_dict = next(resp)[0].to_dict()
                register_value_min = data_dict["MyIngress.cluster" + str(cluster_id) + "_id_min.f1"]
                resp = self.core.get_register_entry("MyIngress.cluster" + str(cluster_id) + "_id_max", 140)
                data_dict = next(resp)[0].to_dict()
                register_value_max = data_dict["MyIngress.cluster" + str(cluster_id) + "_id_max.f1"]
                print("(Read) cluster" + str(cluster_id) + "_id [min, max] ==> [" + str(register_value_min) + ", " + str(register_value_max) + "]")

            # We read the packet counter for each qid
            #self.core.print_table_info("MyEgress.do_packet_count")
            entries = self.core.get_entries("MyEgress.do_packet_count", False)
            for entry in entries:
                key = entry[0]
                data = entry[1]
                qid = key['queue_id']['value']
                counter_value = data['$COUNTER_SPEC_PKTS']
                print("(Read) do_packet_count ==> queue_id {}, counter_value {}".format(qid,counter_value))

                # We update the statistics of the cluster which currently is mapped to that queue (= priority)
                for cluster in self.cluster_list:
                    if cluster.get_priority() == qid:
                        cluster.update_packets_count(counter_value)

            # We read the byte counter for each qid
            #self.core.print_table_info("MyEgress.do_bytes_count")
            entries = self.core.get_entries("MyEgress.do_bytes_count", False)
            for entry in entries:
                key = entry[0]
                data = entry[1]
                qid = key['queue_id']['value']
                counter_value = data['$COUNTER_SPEC_BYTES']
                print("(Read) do_bytes_count ==> queue_id {}, counter_value {}".format(qid,counter_value))

                # We update the statistics of the cluster which currently is mapped to that queue (= priority)
                for cluster in self.cluster_list:
                    if cluster.get_priority() == qid:
                        cluster.update_bytes_count(counter_value)
            
            # We compute the new priorities, sorting the clusters by throughput
            # TODO: Different mechanisms of computing priorities
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

            print("......................................................")

            # We re-program the cluster_to_prio table with the new mapping
            for cluster in self.cluster_list:
                self.core.modify_table("MyIngress.cluster_to_prio", [
                    ([("meta.cluster_id", cluster.get_id())],
                    "MyIngress.set_qid", [("qid", cluster.get_priority())])
                ])
                print("(Write) cluster_to_prio <== cluster_id {}, current_priority {}".format(cluster.get_id(), cluster.get_priority()))

            # We need to reset the counters
            for qid in range(self.num_clusters):

                # Reset do_packet_count
                self.core.clear_counter_packets("MyEgress.do_packet_count", "queue_id", qid, 'MyEgress.packet_count')
                print("(Write) do_packet_count <== queue_id {}, counter_value 0".format(qid))

                # Reset do_bytes_count
                self.core.clear_counter_bytes("MyEgress.do_bytes_count", "queue_id", qid, 'MyEgress.bytes_count')
                print("(Write) do_bytes_count <== queue_id {}, counter_value 0".format(qid))

            print("......................................................")
            
            # TODO: We decide whether reseting the cluster signatures as well or not

            # We may want to log the information to build plots
            #range_evolution.write(iteration + "," + c1_id + "," + c2_id + "," + c3_id + "," + c4_id + "\n")
            iteration = iteration + 1

        # We exit the API
        self.core.tear_down()

if __name__ == "__main__":

    c = Controller()