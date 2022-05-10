import random
from clustering import cluster, clustering_algorithm

class RandomClustering(clustering_algorithm.ClusteringAlgorithm):

    def __init__(self, num_clusters, feature_set):
        self.feature_list = feature_set.split(",") # List of features that we want to use
        clustering_algorithm.ClusteringAlgorithm.__init__(self, num_clusters) 

	# Computes the result of clustering one new packet
    def fit(self, packet, ip_len):

        i = 0
        packet_signature = {}
        assert len(packet) == len(self.feature_list)
        for feature in self.feature_list:
            packet_signature[feature] = (packet[i],packet[i])
            i = i + 1

        # Create new cluster for the packet
        new_cluster = cluster.Cluster(packet_signature, self.current_cluster_id, self.num_clusters, self.feature_list, ip_len)
        self.current_cluster_id = self.current_cluster_id + 1

        # If the cluster list has less than num_clusters clusters, we can just add the new cluster to the list
        if len(self.cluster_list) < self.num_clusters:

            # Append the new cluster directly to the list
            self.cluster_list.append(new_cluster)
            selected_cluster = new_cluster

        else:
            # We just assign the new packet to an existing cluster, selected at random
            r = random.randint(0,self.num_clusters-1)
            existing_cluster = self.cluster_list[r]

            # Merge the new cluster to the closest one
            existing_cluster.update_statistics(new_cluster)
            selected_cluster = existing_cluster

        # We append the label (cluster_id) to the list 
        self.append_label(selected_cluster.get_id())
        return selected_cluster