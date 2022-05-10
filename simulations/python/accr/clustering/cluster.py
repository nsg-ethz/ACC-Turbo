class Cluster:

    def __init__(self, signature, id, num_clusters, feature_list, ip_len):
        self.signature = signature
        self.id = id
        self.priority = num_clusters - 1
        self.feature_list = feature_list
        
        # Statistics
        self.packets = 1
        self.bits = int(ip_len)

    #  Updates the cluster statistics when a new cluster is merged to the existing one. Note that the new cluster can be composed of a single packet.
    def update_statistics(self, new_cluster): 
        self.packets = self.packets + new_cluster.packets
        self.bits = self.bits + new_cluster.bits

    # The centroids are the representatives of the clusters, which we compute as the mean point
    def get_centroid(self): 
        centroid = []
        for feature in self.feature_list:
            centroid.append((self.signature[feature][0] + self.signature[feature][1])/2)
        return centroid

    # Cluster id getter
    def get_id(self):
        return self.id

    # Cluster id setter
    def set_id(self, id):
        self.id = id

    # Cluster priority getter
    def get_priority(self):
        return self.priority

    # Cluster priority setter
    def set_priority(self, priority):
        self.priority = priority

    # Cluster signature getter
    def get_signature(self):
        return self.signature

    # Functions for signature analysis
    def print_signature(self):
        if "proto" in self.feature_list:
            if str(self.signature["proto"][0]) == "17" and str(self.signature["proto"][1]) == "17": 
                print("UDP    " + str(self.packets) + " packets")
            elif str(self.signature["proto"][0]) == "6" and str(self.signature["proto"][1]) == "6": 
                print("TCP    " + str(self.packets) + " packets")
            else:
                print("TCP + UDP    " + str(self.packets) + " packets")

            if ("src0" in self.feature_list  and "src1" in self.feature_list and 
            "src2" in self.feature_list  and "src3" in self.feature_list and 
            "dst0" in self.feature_list  and "dst1" in self.feature_list and 
            "dst2" in self.feature_list  and "dst3" in self.feature_list and 
            "sport" in self.feature_list and "dport" in self.feature_list and "ttl" in self.feature_list):
                print("(" + str(self.signature["src0"][0]) + "-" + str(self.signature["src0"][1]) + ")." + 
                      "(" + str(self.signature["src1"][0]) + "-" + str(self.signature["src1"][1]) + ")." + 
                      "(" + str(self.signature["src2"][0]) + "-" + str(self.signature["src2"][1]) + ")." +
                      "(" + str(self.signature["src3"][0]) + "-" + str(self.signature["src3"][1]) + ")    to    " + 
                      "(" + str(self.signature["dst0"][0]) + "-" + str(self.signature["dst0"][1]) + ")." + 
                      "(" + str(self.signature["dst1"][0]) + "-" + str(self.signature["dst1"][1]) + ")." + 
                      "(" + str(self.signature["dst2"][0]) + "-" + str(self.signature["dst2"][1]) + ")." +
                      "(" + str(self.signature["dst3"][0]) + "-" + str(self.signature["dst3"][1]) + ") \n" + 
                      "(" + str(self.signature["sport"][0]) + "-" + str(self.signature["sport"][1]) + ")    to    " + 
                      "(" + str(self.signature["dport"][0]) + "-" + str(self.signature["dport"][1]) + ") \n" +
                      "(" + str(self.signature["ttl"][0]) + "-" + str(self.signature["ttl"][1]) + ") \n"
                )

    def print_signature_detail(self):
        print("Cluster " + str(self.id) + " \n")
        for feature in self.feature_list:
            if (feature == "sport" or feature == "dport"):
                print("t " + str(feature) + ":        (min: " + str(self.signature[feature][0]) + ", max: " + str(self.signature[feature][1]) + ")\n")
            else:
                print("ip " + str(feature) + ":        (min: " + str(self.signature[feature][0]) + ", max: " + str(self.signature[feature][1]) + ")\n")
        print("Packets: " + str(self.packets))