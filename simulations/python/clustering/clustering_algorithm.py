class ClusteringAlgorithm:

    def __init__(self, num_clusters):
        self.cluster_list = []
        self.num_clusters = num_clusters
        self.current_cluster_id = 0
        self.labels = []

    def update_priorities(self, prioritizing_type):

        if prioritizing_type == "Throughput":
            # We set the new priorities, sorting the clusters by throughput
            clusters_by_throughput = {}
            list_position = 0
            for current_cluster in self.cluster_list:
                clusters_by_throughput[list_position] = current_cluster.bits
                list_position = list_position + 1

            clusters_by_throughput = sorted(clusters_by_throughput.items(), key=lambda item: item[1])
            prio = self.num_clusters - 1
            for tuple in clusters_by_throughput:
                self.cluster_list[tuple[0]].set_priority(prio) # smaller throughput, bigger priority
                prio = prio - 1

        elif prioritizing_type == "NumPackets":
            # We set the new priorities, sorting the clusters by throughput
            clusters_by_packets = {}
            list_position = 0
            for current_cluster in self.cluster_list:
                clusters_by_packets[list_position] = current_cluster.packets
                list_position = list_position + 1

            clusters_by_packets = sorted(clusters_by_packets.items(), key=lambda item: item[1])
            prio = self.num_clusters - 1
            for tuple in clusters_by_packets:
                self.cluster_list[tuple[0]].set_priority(prio) # smaller throughput, bigger priority
                prio = prio - 1

        elif prioritizing_type == "NumPacketsSize":
            # We set the new priorities, sorting the clusters by throughput
            clusters_by_weight = {}
            list_position = 0
            for current_cluster in self.cluster_list:

                # We compute the size of the signature
                size = 1
                for feature in current_cluster.feature_list:
                    size = size * (current_cluster.signature[feature][1] + 1 - current_cluster.signature[feature][0])

                clusters_by_weight[list_position] = current_cluster.packets/size
                list_position = list_position + 1

            clusters_by_weight = sorted(clusters_by_weight.items(), key=lambda item: item[1])
            prio = self.num_clusters - 1
            for tuple in clusters_by_weight:
                self.cluster_list[tuple[0]].set_priority(prio) # smaller throughput, bigger priority
                prio = prio - 1

        elif prioritizing_type == "ThroughputSize":
            # We set the new priorities, sorting the clusters by throughput
            clusters_by_weight = {}
            list_position = 0
            for current_cluster in self.cluster_list:
                
                # We compute the size of the signature
                size = 1
                for feature in current_cluster.feature_list:
                    size = size * (current_cluster.signature[feature][1] + 1 - current_cluster.signature[feature][0])

                clusters_by_weight[list_position] = current_cluster.bits/size
                list_position = list_position + 1

            clusters_by_weight = sorted(clusters_by_weight.items(), key=lambda item: item[1])
            prio = self.num_clusters - 1
            for tuple in clusters_by_weight:
                self.cluster_list[tuple[0]].set_priority(prio) # smaller throughput, bigger priority
                prio = prio - 1

        elif prioritizing_type == "ThroughputDirect":
            # Returns directly the rank computed
            for current_cluster in self.cluster_list:
                current_cluster.set_priority(1/current_cluster.bits)

        elif prioritizing_type == "NumPacketsDirect":
            # Returns directly the rank computed
            for current_cluster in self.cluster_list:
                current_cluster.set_priority(1/current_cluster.packets)

        elif prioritizing_type == "ThroughputSizeDirect":
            # Returns directly the rank computed
            for current_cluster in self.cluster_list:

                # We compute the size of the signature
                size = 1
                for feature in current_cluster.feature_list:
                    size = size * (current_cluster.signature[feature][1] + 1 - current_cluster.signature[feature][0])

                current_cluster.set_priority(size/current_cluster.bits)

        elif prioritizing_type == "NumPacketsSizeDirect":
            # Returns directly the rank computed
            for current_cluster in self.cluster_list:

                # We compute the size of the signature
                size = 1
                for feature in current_cluster.feature_list:
                    size = size * (current_cluster.signature[feature][1] + 1 - current_cluster.signature[feature][0])

                current_cluster.set_priority(size/current_cluster.packets)

        else:
            raise Exception("Ranking algorithm not supported: {}".format(prioritizing_type))


    def set_current_cluster_id(self, cluster_id):
        self.current_cluster_id = cluster_id

    def get_current_cluster_id(self):
        return self.current_cluster_id

    def reset_clusters(self):
        # We remove all clusters from the list
        self.cluster_list = []
        
        # We clear the list of packets that were clustered
        self.labels = []

        # We can reset the current_cluster_id back to 0
        self.current_cluster_id = 0

    def reset_labels(self):

        # We clear the list of packets
        self.labels = []

    # Returns a list with all the labels that have been set to packets fit using the clustering algorithm
    def get_labels(self):
        return self.labels

    def append_label(self, label):
        self.labels.append(label)

    def cluster_centers(self):
        centers = []
        for cluster in self.cluster_list:
            centers.append(cluster.get_centroid())
        return centers

    # Used in the signature-evaluation logging to print all signatures of all clusters for a given feature
    def write_cluster_signatures(self, feature):
        text = ""

        # Since clusters can be reseted, it does not matter which one is which. We want to plot
        clusters_by_signature = {}
        cluster_idx = 0
        for current_cluster in self.cluster_list:
            clusters_by_signature[cluster_idx] = current_cluster.get_signature()[feature][0]
            cluster_idx = cluster_idx + 1

        clusters_by_signature = sorted(clusters_by_signature.items(), key=lambda item: item[1])
        for tuple in clusters_by_signature:
            text = text + "," + str(self.cluster_list[tuple[0]].get_signature()[feature][0]) + "," + str(self.cluster_list[tuple[0]].get_signature()[feature][1])
        return text
