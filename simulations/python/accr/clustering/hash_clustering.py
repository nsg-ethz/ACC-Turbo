import sys
from clustering import cluster, clustering_algorithm, crc8

class HashClustering(clustering_algorithm.ClusteringAlgorithm):

    def __init__(self, num_clusters, feature_set):
        self.feature_list = feature_set.split(",") # List of features that we want to use
        clustering_algorithm.ClusteringAlgorithm.__init__(self, num_clusters) 

	# Computes the result of clustering one new packet
    def fit(self, packet, ip_len):

        i = 0
        packet_signature = {}
        hash_input = ""
        assert len(packet) == len(self.feature_list)
        for feature in self.feature_list:
            packet_signature[feature] = (packet[i],packet[i])
            hash_input = hash_input + str(packet[i])
            i = i + 1

        # Compute the hash of the packet signature to obtain the cluster_id
        hash_input_as_bytes = str.encode(hash_input)
        hash = crc8.crc8()
        hash.update(hash_input_as_bytes)
        bytes_index = hash.digest()
        index = int.from_bytes(bytes_index, byteorder=sys.byteorder)
        assert index <= 255

        # If a cluster with that index already exists, we append the packet.
        exists = False
        for read_cluster in self.cluster_list:

            if read_cluster.get_id() == index: 
                
                # Merge the new cluster to the closest one
                new_cluster = cluster.Cluster(packet_signature, index, self.num_clusters, self.feature_list, ip_len)
                read_cluster.update_statistics(new_cluster)
                selected_cluster = read_cluster
                exists = True

        # Otherwise, we create the cluster for the new packet
        if exists == False:
            
            new_cluster = cluster.Cluster(packet_signature, index, self.num_clusters, self.feature_list, ip_len)
            self.cluster_list.append(new_cluster)
            selected_cluster = new_cluster

        # We append the label (cluster_id) to the list 
        self.append_label(selected_cluster.get_id())
        return selected_cluster