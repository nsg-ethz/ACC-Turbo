import os
import numpy as np
from numpy import random
from sklearn.cluster import KMeans

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

if __name__ == '__main__':  # At every second, we generate a new set of packets (in order). Then we cluster and evaluate false positives.

    # Configuration
    num_clusters = 2
    num_periods = 1
    num_packets_per_period = 100000
    percentage_benign = 0.5  # percentage_malicious = 1 - percentage_benign
    first_period = True # will be done only for the first combination

    w = open("overlap_purity.dat", 'w')
    w.write("#overlap   purity\n")

    # We repeat the experiment for multiple feature combinations
    distrib_benign = "normal"
    mean_benign = 32500
    std_dev_benign = 5000
    min_benign = mean_benign - 2*std_dev_benign
    max_benign = mean_benign + 2*std_dev_benign

    benign_distribution_model = {
        "sport"                  : (distrib_benign, mean_benign, std_dev_benign, min_benign, max_benign),
    }

    distrib_attack = "normal"
    std_dev_attack = 5000
    for mean_attack in range(10000, 55001, 500):
        min_attack = mean_attack - 2*std_dev_attack
        max_attack = mean_attack + 2*std_dev_attack

        attack_distribution_model = {
            "sport"                  : (distrib_attack, mean_attack, std_dev_attack, min_attack, max_attack),
        }

        generated_packets = []
        original_labels_packets = []
        purities = []

        # Repeat for the periods
        for i in range(num_periods):

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

            for j in range(num_packets_per_period):
                
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

            # We keep track of the distributions for the period to later compute the areas
            # We compute the optimal centroids

            sport_centroid_sum_benign = 0
            sport_centroid_cnt_benign = 0

            sport_centroid_sum_attack = 0
            sport_centroid_cnt_attack = 0
            
            for p in range(len(array_generated_packets)):
                if (original_labels_packets[p] == True):
                    sport_distrib_benign[array_generated_packets[p][0]] = sport_distrib_benign[array_generated_packets[p][0]] + 1
                    sport_centroid_sum_benign = sport_centroid_sum_benign + array_generated_packets[p][0]
                    sport_centroid_cnt_benign = sport_centroid_cnt_benign + 1
                    #dport_distrib_benign[array_generated_packets[p][1]] = dport_distrib_benign[array_generated_packets[p][1]] + 1
                else:
                    sport_distrib_attack[array_generated_packets[p][0]] = sport_distrib_attack[array_generated_packets[p][0]] + 1
                    #dport_distrib_attack[array_generated_packets[p][1]] = dport_distrib_attack[array_generated_packets[p][1]] + 1
                    sport_centroid_sum_attack = sport_centroid_sum_attack + array_generated_packets[p][0]
                    sport_centroid_cnt_attack = sport_centroid_cnt_attack + 1
            
            centroid_benign_cluster = [[sport_centroid_sum_benign / sport_centroid_cnt_benign]]
            centroid_attack_cluster = [[sport_centroid_sum_attack / sport_centroid_cnt_attack]]
            centroids = [centroid_benign_cluster, centroid_attack_cluster]

            # We then just assign each packet to its closer centroid
            result_labels = {}
            for p in range(len(array_generated_packets)):
                if (abs(array_generated_packets[p][0] - centroid_benign_cluster[0]) > abs(array_generated_packets[p][0] - centroid_attack_cluster[0])):
                    result_labels[p] = 0 # Attack
                else:
                    result_labels[p] = 1 # Benign

            # We print as example the results of the first period
            if first_period:
                first_period = False
                r = open("clustering_results.dat", 'w')
                # r.write("#    sport    dport    ground_truth    assigned_label\n")
                r.write("#    sport    ground_truth    assigned_label\n")
                for k in range(len(array_generated_packets)):
                    r.write("%s   %s   %s\n" % (array_generated_packets[k][0], original_labels_packets[k], result_labels[k]))
                    # r.write("%s   %s   %s   %s\n" % (array_generated_packets[k][0], array_generated_packets[k][1], original_labels_packets[k], result_labels[k]))
                r.close()

                c = open("centroids.dat", 'w')
                #c.write("#    centroid_sport    centroid_dport\n")
                c.write("#    centroid_sport\n")
                for l in range(len(centroids)):
                    #c.write("%s   %s\n" % (centroids[l][0], centroids[l][1]))
                    c.write("%s \n" % (centroids[l][0]))
                c.close()

                # We also plot the generated distributions for the first period
                s = open("sport_distrib.dat", 'w')
                s.write("#    sport_distrib_benign    sport_distrib_attack\n")
                for line in range(0,len(sport_distrib_benign)):
                    s.write("%s   %s   %s\n" % (line, sport_distrib_benign[line], sport_distrib_attack[line]))
                s.close()

                #d = open("dport_distrib.dat", 'w')
                #d.write("#    dport_distrib_benign    dport_distrib_attack\n")
                #for line in range(0,len(dport_distrib_benign)):
                #    d.write("%s   %s   %s\n" % (line, dport_distrib_benign[line], dport_distrib_attack[line]))
                #d.close()    

            # We first assign each cluster to the class which is most frequent in the cluster
            purity = 0
            benign_counter = {}
            malicious_counter = {}
            
            for n in range(num_clusters):
                benign_counter[n] = 0
                malicious_counter[n] = 0
            
            # We count the number of benign and malicious packets clustered in each cluster
            for p in range(len(array_generated_packets)):
                if (original_labels_packets[p] == True):
                    benign_counter[result_labels[p]] = benign_counter[result_labels[p]] + 1
                else:
                    malicious_counter[result_labels[p]] = malicious_counter[result_labels[p]] + 1
            
            for n in range(num_clusters):
                if (benign_counter[n] >= malicious_counter[n]):

                    # The cluster is classified as benign
                    purity = purity + benign_counter[n]

                else:

                    # The cluster is classified as malicious
                    purity = purity + malicious_counter[n]
            
            purity = (purity/num_packets_per_period)*100
            print("Purity for the period: " + str(purity))
            purities.append(purity)

        # We extract statistics from the results
        array_purities = np.array(purities)
        mean_purities = np.mean(array_purities)
        variance_purities = np.var(array_purities)
        print("Mean purity over all periods: " + str(mean_purities))
        print("Variance purity over all periods: " + str(variance_purities))

        # We compute the theoretical overlap of the two distributions
        if (max_attack < min_benign) or (min_attack > max_benign):
            overlap = 0
        else:

            # Upper limit computation
            if (max_attack > max_benign):
                upper_limit = max_benign
            else:
                upper_limit = max_attack
        
            # Lower limit computation
            if (min_attack < min_benign):
                lower_limit = min_benign
            else:
                lower_limit = min_attack

            # We now need to integrate the area between lower_limit and upper_limit (the region of overlap) for the two distributions
            # One way is to use the distrib. of the first period as example (what we do). The other would be to do it with the theoretical function.
            overlapped_area_benign = 0    
            overlapped_area_attack = 0 
            for idx in range(lower_limit,upper_limit + 1):
                overlapped_area_benign = overlapped_area_benign + sport_distrib_benign[idx]
                overlapped_area_attack = overlapped_area_attack + sport_distrib_attack[idx]

            overlap = ((overlapped_area_benign + overlapped_area_attack)/num_packets_per_period)*100 # Percentage

        # We write the resulting purity for that distribution
        print("Overlap: " + str(overlap) + ", Purity: " + str(mean_purities))
        w.write("%s   %s\n" % (overlap, mean_purities))
w.close()

# We can repeat for different distributions and see how does the performance evolve..
#os.system('gnuplot plot_clustering_results.gnuplot')
#os.system('gnuplot plot_distributions.gnuplot')
#os.system('evince clustering_results.pdf')
#os.system('evince dport_distrib.pdf')
#os.system('evince sport_distrib.pdf')

