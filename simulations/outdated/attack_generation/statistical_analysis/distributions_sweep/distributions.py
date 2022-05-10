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

    w = open("purities.dat", 'w')
    w.write("#theoretical_purity   achieved_purity\n")

    # We repeat the experiment for multiple feature combinations
    distrib_benign = "uniform"
    mean_benign = 32500
    std_dev_benign = 5000
    min_benign = mean_benign - std_dev_benign
    max_benign = mean_benign + std_dev_benign

    benign_distribution_model = {
        "sport"                  : (distrib_benign, mean_benign, std_dev_benign, min_benign, max_benign),
    }

    distrib_attack = "normal"
    std_dev_attack = 5000
    for mean_attack in range(15000, 50001, 500):
        min_attack = mean_attack - 3*std_dev_attack
        max_attack = mean_attack + 3*std_dev_attack

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
            for p in range(len(array_generated_packets)):
                if (original_labels_packets[p] == True):
                    sport_distrib_benign[array_generated_packets[p][0]] = sport_distrib_benign[array_generated_packets[p][0]] + 1
                    #dport_distrib_benign[array_generated_packets[p][1]] = dport_distrib_benign[array_generated_packets[p][1]] + 1
                else:
                    sport_distrib_attack[array_generated_packets[p][0]] = sport_distrib_attack[array_generated_packets[p][0]] + 1
                    #dport_distrib_attack[array_generated_packets[p][1]] = dport_distrib_attack[array_generated_packets[p][1]] + 1

            # We then can feed it to the clustering algorithm
            kmeans = KMeans(n_clusters=num_clusters)
            kmeans.fit(array_generated_packets)
            centroids = kmeans.cluster_centers_
            result_labels = kmeans.labels_

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

        # We compute the theoretical "overlap" of the two distributions
        # Note that this is not the "physical overlap"
        
        # Given two distribs, can we know the clustering performance? Yes. How? This way:
        
        # First we compute the means of the distributions
        min_feature_value = 0
        max_feature_value = 65535
        distributions = [sport_distrib_benign, sport_distrib_attack]
        means = [mean_benign, mean_attack]
        
        # Second we sort distributions by their mean value
        # For a big number of distribs we would do: array_means = np.array(means), array_means.sort()
        if (mean_benign > mean_attack):
            distributions = [sport_distrib_attack, sport_distrib_benign]
            means = [mean_attack, mean_benign]
        print("Means: " + str(means))

        # Then we compute the middle points between the means
        middle_points = []
        for i in range(len(means)-1):

            # We assume all feature values are positive
            middle_point = int((means[i] + means[i+1])/2)
            middle_points.append(middle_point)
        print("Middle points: " + str(middle_points))
        
        # Then we compute the theoretical purity by integrating distributions over the interval, and selecting the one with max. number of packets in the interval
        # Interval 0 = Min_feature_value  <-> Middle 0
        # Interval 1 = Middle 0 <-> Middle 1
        # Interval 2 = Middle 1 <-> Middle 2
        # ...
        # Interval N = Middle N <-> Max_feature_value

        theoretical_purity = 0

        #####
        # Classic purity computation
        #####

        # First interval
        counter_0 = 0
        counter_1 = 0

        for idx in range(min_feature_value,middle_points[0]):
            counter_0 = counter_0 + distributions[0][idx]
            counter_1 = counter_1 + distributions[1][idx]
        
        if (counter_0 > counter_1):
            theoretical_purity = theoretical_purity + counter_0
            print("We integrate distribution 0 from " + str(min_feature_value) + " to " + str(middle_points[0]))

        else:
            theoretical_purity = theoretical_purity + counter_1
            print("We integrate distribution 1 from " + str(min_feature_value) + " to " + str(middle_points[0]))

        # Last interval
        counter_0 = 0
        counter_1 = 0

        for idx in range(middle_points[len(middle_points)-1], max_feature_value):
            counter_0 = counter_0 + distributions[0][idx]
            counter_1 = counter_1 + distributions[1][idx]

        if (counter_0 > counter_1):
            theoretical_purity = theoretical_purity + counter_0
            print("We integrate distribution 0 from " + str(middle_points[len(middle_points)-1]) + " to " + str(max_feature_value))
        else:
            theoretical_purity = theoretical_purity + counter_1
            print("We integrate distribution 1 from " + str(middle_points[len(middle_points)-1]) + " to " + str(max_feature_value))
                        
        # Intervals in between
        if len(middle_points) > 1:
            for item in range(len(middle_points)-1):
                counter_0 = 0
                counter_1 = 0

                for idx in range(middle_points[item], middle_points[item + 1]):
                    counter_0 = counter_0 + distributions[0][idx]
                    counter_1 = counter_1 + distributions[1][idx]

                if (counter_0 > counter_1):
                    theoretical_purity = theoretical_purity + counter_0
                    print("We integrate distribution 0 from " + str(middle_points[item]) + " to " + str(middle_points[item + 1]))    
                else:
                    theoretical_purity = theoretical_purity + counter_1
                    print("We integrate distribution 1 from " + str(middle_points[item]) + " to " + str(middle_points[item + 1]))    

        theoretical_purity = (theoretical_purity/num_packets_per_period)*100 # Percentage

        '''
        #####
        # Modified purity computation
        #####
        
        theoretical_purity = 0

        # First interval
        for idx in range(min_feature_value,middle_points[0]):
            theoretical_purity = theoretical_purity + distributions[0][idx]
        print("We integrate distribution " + str(0) + " from " + str(min_feature_value) + " to " + str(middle_points[0]))
        
        # Last interval
        for idx in range(middle_points[len(middle_points)-1], max_feature_value):
            theoretical_purity = theoretical_purity + distributions[len(distributions)-1][idx]
        print("We integrate distribution " + str(len(distributions)-1) + " from " + str(middle_points[len(middle_points)-1]) + " to " + str(max_feature_value))

        # Intervals in between
        if len(middle_points) > 1:
            for item in range(len(middle_points)-1):
                for idx in range(middle_points[item], middle_points[item + 1]):
                    theoretical_purity = theoretical_purity + distributions[item][idx]
                print("We integrate distribution " + str(item) + " from " + str(middle_points[item]) + " to " + str(middle_points[item + 1]))    

        theoretical_purity = (theoretical_purity/num_packets_per_period)*100 # Percentage
        '''


        # We write the resulting purity for that distribution
        print("Theoretical purity: " + str(theoretical_purity) + ", Achieved purity: " + str(mean_purities))
        w.write("%s   %s\n" % (theoretical_purity, mean_purities))
w.close()

# We can repeat for different distributions and see how does the performance evolve..
#os.system('gnuplot plot_clustering_results.gnuplot')
#os.system('gnuplot plot_distributions.gnuplot')
#os.system('evince clustering_results.pdf')
#os.system('evince dport_distrib.pdf')
#os.system('evince sport_distrib.pdf')