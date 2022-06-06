from clustering import cluster, clustering_algorithm

class RangeBasedClustering(clustering_algorithm.ClusteringAlgorithm):

    def __init__(self, num_clusters, feature_set):
        self.feature_list = feature_set.split(",") # List of features that we want to use
        clustering_algorithm.ClusteringAlgorithm.__init__(self, num_clusters) 

	# Computes the distance between two clusters. Used to decide which clusters to merge during the clustering process.
    # Distance follows the cost function proposed in "Automatic Inference of High-Level Network Intents by Mining Forwarding Patterns".
    # Helper: d(c_a, c_b) = delta(c_a u c_b) - (delta(c_a) + delta(c_b))
    def compute_distance_anime(self, cluster_a, cluster_b):        

        # We first compute the signature of the merged cluster (c_a u c_b)
        signature_merged_cluster = {}
        for feature in self.feature_list:
            
            # We merge the ranges of cluster_a.signature[feature] and cluster_b.signature[feature]
            if feature in self.ordinal_features:
                signature_merged_cluster[feature] = [min(cluster_a.signature[feature][0], cluster_b.signature[feature][0]), max(cluster_a.signature[feature][1], cluster_b.signature[feature][1])]
            
            # We merge the sets of src_cluster.signature[feature] and dst_cluster.signature[feature]
            elif feature in self.nominal_features:
                signature_merged_cluster[feature] = []
                for key in cluster_a.signature[feature]:
                    signature_merged_cluster[feature].append(key)
                for key in cluster_b.signature[feature]:
                    if not key in signature_merged_cluster[feature]:
                        signature_merged_cluster[feature].append(key)
            
            else:
                raise Exception("Feature must be nominal or ordinal. It is not the case for feature: {}".format(feature))

        # We compute: delta(c_a u c_b)
        delta_merged_cluster = 1 # We initialize the cost
        for feature in self.feature_list:
            if feature in self.ordinal_features:
                delta_merged_cluster = delta_merged_cluster * ((signature_merged_cluster[feature][1]+1) - signature_merged_cluster[feature][0])

            elif feature in self.nominal_features:
                set_size = len(signature_merged_cluster[feature])
                delta_merged_cluster = delta_merged_cluster * (set_size)

            else:
                raise Exception("Feature must be nominal or ordinal. It is not the case for feature: {}".format(feature))

        # We compute: delta(c_a)
        delta_cluster_a = 1 # We initialize the cost
        for feature in self.feature_list:
            if feature in self.ordinal_features:
                delta_cluster_a = delta_cluster_a * ((cluster_a.signature[feature][1]+1) - cluster_a.signature[feature][0])

            elif feature in self.nominal_features:
                set_size = len(cluster_a.signature[feature])
                delta_cluster_a = delta_cluster_a * (set_size)

            else:
                raise Exception("Feature must be nominal or ordinal. It is not the case for feature: {}".format(feature))

        # We compute: delta(c_b)
        delta_cluster_b = 1 # We initialize the cost
        for feature in self.feature_list:
            if feature in self.ordinal_features:
                delta_cluster_b = delta_cluster_b * ((cluster_b.signature[feature][1]+1) - cluster_b.signature[feature][0])

            elif feature in self.nominal_features:
                set_size = len(cluster_b.signature[feature])
                delta_cluster_b = delta_cluster_b * (set_size)

            else:
                raise Exception("Feature must be nominal or ordinal. It is not the case for feature: {}".format(feature))

        # We compute: d(c_a, c_b)
        distance = delta_merged_cluster - (delta_cluster_a + delta_cluster_b)
        
        assert (distance >= 0)
        return distance

	## Computes the distance between two clusters. Used to decide which clusters to merge during the clustering process.
    def compute_distance_manhattan(self, cluster_a, cluster_b): 

        distance = 0
        for feature in self.feature_list:

            distance_feature = 0

            if feature in self.ordinal_features:
                # Helper: | min(cluster_a) ...... max(cluster_a) |   <->   | min(cluster_b) ...... max(cluster_b) |
                # if max(cluster_a) < min(cluster_b): distance = min(cluster_b) - max(cluster_a)
                if (cluster_a.signature[feature][1] < cluster_b.signature[feature][0]):
                    distance_feature = cluster_b.signature[feature][0] - cluster_a.signature[feature][1]

                # Helper: | min(cluster_b) ...... max(cluster_b) |   <->   | min(cluster_a) ...... max(cluster_a) |
                # if min(cluster_a) > max(cluster_b): distance = min(cluster_a) - max(cluster_b)
                elif (cluster_a.signature[feature][0] > cluster_b.signature[feature][1]):
                    distance_feature = cluster_a.signature[feature][0] - cluster_b.signature[feature][1]

            elif feature in self.nominal_features:
                # Helper: signature(cluster_a) = {x, y, z}   <->   signature(cluster_b) = {x, q, s}
                # Distance is: the numbers on cluster_a's set which are not included in cluster_b's set, plus the numbers on cluster_b's set which are not included in cluster_a's set
                for key in cluster_a.signature[feature]:
                    if not key in cluster_b.signature[feature]:
                        distance_feature = distance_feature + 1 

                for key in cluster_b.signature[feature]:
                    if not key in cluster_a.signature[feature]:
                        distance_feature = distance_feature + 1
            
            else:
                raise Exception("Feature must be nominal or ordinal. It is not the case for feature: {}".format(feature))

            distance = distance + distance_feature

        assert (distance >= 0)
        return distance

    # Method to merge cluster "src_cluster" into "dst_cluster"
    def merge_cluster(self, src_cluster, dst_cluster):

        signature_merged_cluster = {}
        for feature in self.feature_list:
            
            # We merge the ranges of src_cluster.signature[feature] and dst_cluster.signature[feature]
            if feature in self.ordinal_features:
                signature_merged_cluster[feature] = [min(dst_cluster.signature[feature][0], src_cluster.signature[feature][0]), max(dst_cluster.signature[feature][1], src_cluster.signature[feature][1])]
            
            # We merge the sets of src_cluster.signature[feature] and dst_cluster.signature[feature]
            elif feature in self.nominal_features:
                signature_merged_cluster[feature] = []
                for key in src_cluster.signature[feature]:
                    signature_merged_cluster[feature].append(key)
                for key in dst_cluster.signature[feature]:
                    if not key in signature_merged_cluster[feature]:
                        signature_merged_cluster[feature].append(key)
            
            else:
                raise Exception("Feature must be nominal or ordinal. It is not the case for feature: {}".format(feature))
        
        # We return the merged cluster
        dst_cluster.signature = signature_merged_cluster
	
	## Computes the result of clustering one new packet following the exhaustive version of the range_based clustering algorithm	
    def fit_exhaustive(self, packet, ip_len, distance_type):

        # It makes no sense to measure distances across existing clusters if num_clusters = 1
        assert self.num_clusters > 1

        i = 0
        packet_signature = {}
        assert len(packet) == len(self.feature_list)
        for feature in self.feature_list:
            if feature in self.ordinal_features:
                packet_signature[feature] = [packet[i],packet[i]] # We initialize the range with the packet's feature value
            elif feature in self.nominal_features:
                packet_signature[feature] = [packet[i]] # We initialize the set
            else:
                raise Exception("Feature must be nominal or ordinal. It is not the case for feature: {}".format(feature))
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
            # Compute the distances of the new (virtual) cluster with all existing clusters
            i = 0
            for existing_cluster in self.cluster_list:
                if distance_type == "manhattan":
                    distance = self.compute_distance_manhattan(existing_cluster, new_cluster)
                else:
                    distance = self.compute_distance_anime(existing_cluster, new_cluster)

                if (i == 0):
                    min_distance = distance
                    min_cluster = existing_cluster
                    i = i + 1
                else:
                    if (distance < min_distance):
                        min_distance = distance
                        min_cluster = existing_cluster

            # We need to check the distances across all the existing clusters
            i = 0            
            for j in range(len(self.cluster_list)):
                for k in range(j+1, len(self.cluster_list)):
                    if distance_type == "manhattan":
                        existing_distance = self.compute_distance_manhattan(self.cluster_list[j], self.cluster_list[k])
                    else:
                        existing_distance = self.compute_distance_anime(self.cluster_list[j], self.cluster_list[k])
        
                    if (i == 0):
                        existing_min_distance = existing_distance
                        existing_min_cluster_a = self.cluster_list[j]
                        existing_min_cluster_b = self.cluster_list[k]
                        i = i + 1
                    else:
                        if(existing_distance < existing_min_distance):
                            existing_min_distance = existing_distance
                            existing_min_cluster_a = self.cluster_list[j]
                            existing_min_cluster_b = self.cluster_list[k]                                

            # We then use the distances to decide what to merge
            if (min_distance < existing_min_distance):
                self.merge_cluster(new_cluster, min_cluster)
                min_cluster.update_statistics(new_cluster)
                selected_cluster = min_cluster
                
            else:
                # We merge cluster b to cluster a and remove cluster b from the list
                self.merge_cluster(existing_min_cluster_b, existing_min_cluster_a)
                existing_min_cluster_a.update_statistics(existing_min_cluster_b)

                # Before removing b from the list, we check which was its id, which we will reuse for the newly created cluster
                id_to_reuse = existing_min_cluster_b.get_id()
                self.cluster_list.remove(existing_min_cluster_b)

                # We also re-label all the packets of the removed cluster to the id of the cluster they are merged to
                # This is just so that the purity computation does not get polluted
                for l in range(len(self.labels)):
                    if self.labels[l] == id_to_reuse:
                        self.labels[l] = existing_min_cluster_a.get_id()

                # We then add the new cluster to the list
                new_cluster.set_id(id_to_reuse)
                self.cluster_list.append(new_cluster)
                selected_cluster = new_cluster
            
        # We append the label (cluster_id) to the list 
        self.append_label(selected_cluster.get_id())
        return selected_cluster
	
	# Computes the result of clustering one new packet following the fast version of the range_based clustering algorithm.
    def fit_fast(self, packet, ip_len, distance_type):

        i = 0
        packet_signature = {}
        assert len(packet) == len(self.feature_list)
        for feature in self.feature_list:
            if feature in self.ordinal_features:
                packet_signature[feature] = [packet[i],packet[i]] # We initialize the range with the packet's feature value
            elif feature in self.nominal_features:
                packet_signature[feature] = [packet[i]] # We initialize the set
            else:
                raise Exception("Feature must be nominal or ordinal. It is not the case for feature: {}".format(feature))
            i = i + 1

        # Create new cluster for the packet (note that we do not update current_cluster_id straight away, since we will only use that cluster id if the new cluster is selected.
        # If the new cluster is merged to an existing one, we don't need to update the current_cluster_id)
        new_cluster = cluster.Cluster(packet_signature, self.current_cluster_id, self.num_clusters, self.feature_list, ip_len)

        # If the cluster list is empty, we just add the new custer to the list
        if len(self.cluster_list) == 0:

            # Append the new cluster directly to the list
            self.cluster_list.append(new_cluster)
            selected_cluster = new_cluster
            self.current_cluster_id = self.current_cluster_id + 1

        # If it is not empty, we compute the minimum distance (to the clusters in the list)
        else:
            # Compute the distances of the new (virtual) cluster with all existing clusters
            i = 0
            for existing_cluster in self.cluster_list:
                if distance_type == "manhattan":
                    distance = self.compute_distance_manhattan(existing_cluster, new_cluster)
                else:
                    distance = self.compute_distance_anime(existing_cluster, new_cluster)

                if (i == 0):
                    min_distance = distance
                    min_cluster = existing_cluster
                    i = i + 1
                else:
                    if (distance < min_distance):
                        min_distance = distance
                        min_cluster = existing_cluster

            # Then we decide. If the list is already full, then we merge to the closest distance
            if len(self.cluster_list) >= self.num_clusters:

                # Merge the new cluster to the closest one
                self.merge_cluster(new_cluster, min_cluster)
                min_cluster.update_statistics(new_cluster)
                selected_cluster = min_cluster

            # If the list is not full, we decide whether we want to create a new cluster or merge to the closest one.
            else:

                if (min_distance == 0):

                    # Merge the new cluster to the closest one
                    self.merge_cluster(new_cluster, min_cluster)
                    min_cluster.update_statistics(new_cluster)
                    selected_cluster = min_cluster

                else:

                    # Append the new cluster directly to the list
                    self.cluster_list.append(new_cluster)
                    selected_cluster = new_cluster
                    self.current_cluster_id = self.current_cluster_id + 1

        # We append the label (cluster_id) to the list 
        self.append_label(selected_cluster.get_id())
        return selected_cluster