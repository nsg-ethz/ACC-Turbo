
# In this file we analyze the convergence of online k-means approach to the offline version of the algorithm after all samples have been received

import os, sys
import numpy as np
from numpy import random
from sklearn.cluster import KMeans

sys.path.append('/home/albert/DDoS-AID_private/code/clustering_analysis/')
from clustering import range_based_clustering, representative_based_clustering

def generate_packet(distribution):

    # We generate a new random value from the distribution for each feature

    if (distribution["sport"][0] == "normal"): 
        sport = int(random.normal(distribution["sport"][1] , distribution["sport"][2]))
        while sport < distribution["sport"][3] or sport > distribution["sport"][4]:
            sport = int(random.normal(distribution["sport"][1], distribution["sport"][2]))

    # Uniform: Samples are uniformly distributed over the half-open interval [low, high) (includes low, but excludes high)
    if (distribution["sport"][0] == "uniform"): 
        sport = int(random.uniform(distribution["sport"][3] , distribution["sport"][4]))
        
    # dport = int(random.normal(distribution["dport"][0] , distribution["dport"][1]))
    # while dport > distribution["dport"][2] or dport < 0:
    #    dport = int(random.normal(distribution["dport"][0], distribution["dport"][1]))

    packet = [sport]
    return packet

if __name__ == '__main__':

    # Configuration
    clustering_algo = "representative_based_fast"
    learning_rate = 0.6 # Only used in the representative-based
    num_clusters = 2
    num_periods = 1
    num_packets = 200
    percentage_benign = 0.5  # percentage_malicious = 1 - percentage_benign
    first_period = True # will be done only for the first combination

    # We repeat the experiment for multiple feature combinations
    distrib_benign = "uniform"
    mean_benign = 32500
    std_dev_benign = 5000
    min_benign = mean_benign - std_dev_benign
    max_benign = mean_benign + std_dev_benign

    benign_distribution_model = {
        "sport"                  : (distrib_benign, mean_benign, std_dev_benign, min_benign, max_benign),
    }

    distrib_attack = "uniform"
    std_dev_attack = 5000
    mean_attack = 32500
    min_attack = mean_attack - std_dev_attack
    max_attack = mean_attack + std_dev_attack

    attack_distribution_model = {
        "sport"                  : (distrib_attack, mean_attack, std_dev_attack, min_attack, max_attack),
    }

    # We will have f files, one per feature. In this case we only have one feature (sport), so we only create one file
    sport_file = open("sport_convergence.dat", 'w')

    # The file will have a first column with iteration number, then n columns with the sport value for the centroids of the n clusters for the offline case (reference), 
    # and the same for the online case which we want to analyze
    sport_file.write("#iteration_number")
    for cluster in range(num_clusters):
        sport_file.write("   centroid_offline_k_means_" + str(cluster))
    for cluster in range(num_clusters):
        sport_file.write("   centroid_online_k_means_" + str(cluster))    
    sport_file.write("\n")    

    generated_packets = []
    original_labels_packets = []

    # Monitoring of the traffic distributions
    sport_distrib_benign = {}
    #dport_distrib_benign = {}
    sport_distrib_attack = {}
    #dport_distrib_attack = {}

    for a in range(0, 65536):
        sport_distrib_benign[a] = 0
        #dport_distrib_benign[a] = 0
        sport_distrib_attack[a] = 0
        #dport_distrib_attack[a] = 0

    # We generate the set of packets
    for j in range(num_packets):
        
        # We generate random value to define if benign or malicious
        benign_or_attack = random.uniform(0,1)
        benign = True

        if benign_or_attack < percentage_benign:
            packet = generate_packet(benign_distribution_model)
        else:
            packet = generate_packet(attack_distribution_model)
            benign = False

        # We create a list of packets for the period
        generated_packets.append(packet)
        original_labels_packets.append(benign)
            
    # We cluster the packets generated over the period
    # We first need to convert the list to a numpy array
    array_generated_packets = np.array(generated_packets)

    # We can keep track of the generated packet distributions
    for p in range(len(array_generated_packets)):
        if (original_labels_packets[p] == True):
            sport_distrib_benign[array_generated_packets[p][0]] = sport_distrib_benign[array_generated_packets[p][0]] + 1
            #dport_distrib_benign[array_generated_packets[p][1]] = dport_distrib_benign[array_generated_packets[p][1]] + 1
        else:
            sport_distrib_attack[array_generated_packets[p][0]] = sport_distrib_attack[array_generated_packets[p][0]] + 1
            #dport_distrib_attack[array_generated_packets[p][1]] = dport_distrib_attack[array_generated_packets[p][1]] + 1

    # We first compute the offline k-means centroids as baseline
    kmeans = KMeans(n_clusters=num_clusters)
    kmeans.fit(array_generated_packets)
    centroids_baseline = kmeans.cluster_centers_
    print("Baseline centroids: " + str(centroids_baseline))

    # And then we compute the centroids obtained in each iteration, as computed by range-based or representative-based algorithms
    if "range_based" in clustering_algo:
        range_based = range_based_clustering.RangeBasedClustering(num_clusters)

        # It is an online clustering algorithm, so packets are fit one by one
        cnt_packets = 0
        for packet in array_generated_packets:
            if clustering_algo == "range_based_exhaustive":
                range_based.fit_exhaustive(packet)
            else:
                range_based.fit_fast(packet)
            cnt_packets = cnt_packets + 1
            
            # We obtain the centroids for the iteration
            if (cnt_packets >= num_clusters): # Otherwise we will get a number of centroids smaller than the number of clusters
                centroids = range_based.cluster_centers()

                # We write the centroids for the iteration to the file
                sport_file.write(str(cnt_packets))
                for cluster in range(num_clusters):
                    sport_file.write("   " + str(centroids_baseline[cluster][0]))
                for cluster in range(num_clusters):
                    sport_file.write("   " + str(centroids[cluster][0]))    
                sport_file.write("\n")    
    
    else:
        representative_based = representative_based_clustering.RepresentativeBasedClustering(num_clusters)

        # It is an online clustering algorithm, so packets are fit one by one
        cnt_packets = 0
        for packet in array_generated_packets:
            if clustering_algo == "representative_based_exhaustive":
                representative_based.fit_exhaustive(packet, learning_rate)
            else:
                representative_based.fit_fast(packet, learning_rate)
            cnt_packets = cnt_packets + 1

            # We obtain the centroids for the iteration
            if (cnt_packets >= num_clusters): # Otherwise we will get a number of centroids smaller than the number of clusters
                centroids = representative_based.cluster_centers()

                # We write the centroids for the iteration to the file
                sport_file.write(str(cnt_packets))
                for cluster in range(num_clusters):
                    sport_file.write("   " + str(centroids_baseline[cluster][0]))
                for cluster in range(num_clusters):
                    sport_file.write("   " + str(centroids[cluster][0]))    
                sport_file.write("\n")

    # We just print out the result for comparison        
    print("Online-algorithm last-iteration centroids: " + str(centroids))

    # We can print as reference the generated distribution
    if first_period:
        first_period = False

        # We also plot the generated distributions for the first period
        s = open("sport_distrib.dat", 'w')
        s.write("#    sport_distrib_benign    sport_distrib_attack\n")
        for line in range(0,len(sport_distrib_benign)):
            s.write("%s   %s   %s\n" % (line, sport_distrib_benign[line], sport_distrib_attack[line]))
        s.close()

sport_file.close()
