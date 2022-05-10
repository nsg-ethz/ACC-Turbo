import math

'''
In this program we analyze the difference between different distance metrics when clustering two clusters {A,B} of different size

    # We use as reference a space C as the one in the figure. Inside this space, we create two clusters, A and B.
    # Then, we generate all possible cluster-size combinations within the space.
    # For each of the combinations, we compute the (absolute) distance between the two clusters by using each of the possible distance metrics.
    # We then compare the differences in result of the different distance metrics.

    # -------------------- #
    #|             |  B   |#
    #|              ------|#
    #|         C          |#
    #|                    |#      ^
    #|------              |#      | y
    #|  A  |              |#      |   x
    # -------------------- #       ------>
    # .   .   .   .   .   .#
    # 0   1   2   3   4   5#

'''

def compute_distance_anime(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By):
    area_A = (max_Ax - min_Ax)*(max_Ay - min_Ay)
    area_B = (max_Bx - min_Bx)*(max_By - min_By)
    area_merged = (max(max_Ax, max_Bx) - min(min_Ax, min_Bx)) * (max(max_Ay, max_By) - min(min_Ay, min_By))
    distance = area_merged - (area_A + area_B)
    return distance

def compute_distance_euclidean_repres(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By):
    repres_Ax = (max_Ax - min_Ax)/2
    repres_Ay = (max_Ay - min_Ay)/2
    repres_Bx = (max_Bx - min_Bx)/2
    repres_By = (max_By - min_By)/2
    distance = math.sqrt(abs(repres_Ax - repres_Bx)**2 + abs(repres_Ay - repres_By)**2)
    return distance

def compute_distance_manhattan_repres(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By):
    repres_Ax = (max_Ax - min_Ax)/2
    repres_Ay = (max_Ay - min_Ay)/2
    repres_Bx = (max_Bx - min_Bx)/2
    repres_By = (max_By - min_By)/2
    distance = abs(repres_Ax - repres_Bx) + abs(repres_Ay - repres_By)
    return distance

def compute_distance_manhattan_ranges(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By):

    distance = 0

    # Feature x
    if (min_Ax > max_Bx):
        distance = distance + (min_Ax - max_Bx)
    if (min_Bx > max_Ax):
        distance = distance + (min_Bx - max_Ax)

    # Feature y
    if (min_Ay > max_By):
        distance = distance + (min_Ay - max_By)
    if (min_By > max_Ay):
        distance = distance + (min_By - max_Ay)

    return distance

def compute_distance_anime_modified(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By):

    # We approximate areas by ranges
    area_approx_A = (max_Ax - min_Ax)+(max_Ay - min_Ay)
    area_approx_B = (max_Bx - min_Bx)+(max_By - min_By)
    area_approx_merged = (max(max_Ax, max_Bx) - min(min_Ax, min_Bx)) + (max(max_Ay, max_By) - min(min_Ay, min_By))
    distance = area_approx_merged - (area_approx_A + area_approx_B)
    return distance

if __name__ == '__main__':

    # Configuration: we define the size of the space C
    min_Cx = 0
    max_Cx = 5

    min_Cy = 0
    max_Cy = 5

    # Configuration output file
    output_file = open("distances.dat", "w+")
    output_file.write("#Cluster_configurations, Distance_anime, Distance_Euclidean_Repres, Distance_Manhattan_Repres, Distance_Manhattan_Ranges, Distance_Anime_Modified\n")

    # We compute the maximum value that each of the possible distances can take
    max_anime = (max_Cx - min_Cx)*(max_Cy - min_Cy) # size of space C
    max_euclidean_repres = math.sqrt(((max_Cx - min_Cx)**2) + ((max_Cy - min_Cy)**2))
    max_manhattan_repres = (max_Cx - min_Cx) + (max_Cy - min_Cy)
    max_manhattan_ranges = (max_Cx - min_Cx) + (max_Cy - min_Cy)
    max_anime_modified = (max_Cx - min_Cx) + (max_Cy - min_Cy)

    # We iterate over all possible cluster A sizes and positions in the space
    for min_Ax in range (min_Cx, max_Cx+1):
        for max_Ax in range (min_Ax, max_Cx+1):

            for min_Ay in range (min_Cy, max_Cy+1):
                for max_Ay in range (min_Ay, max_Cy+1):

                    # We combine each of the cluster A possibilities, with the cluster B possibilities in the space
                    for min_Bx in range (min_Cx, max_Cx+1):
                        for max_Bx in range (min_Bx, max_Cx+1):

                            for min_By in range (min_Cy, max_Cy+1):
                                for max_By in range (min_By, max_Cy+1):

                                    # We compute (and log the distances with each of the mechanism)
                                    distance_anime              = compute_distance_anime(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By)/max_anime
                                    distance_euclidean_repres   = compute_distance_euclidean_repres(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By)/max_euclidean_repres
                                    distance_manhattan_repres   = compute_distance_manhattan_repres(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By)/max_manhattan_repres
                                    distance_manhattan_ranges   = compute_distance_manhattan_ranges(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By)/max_manhattan_ranges
                                    distance_anime_modified     = compute_distance_anime_modified(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By)/max_anime_modified
                                    
                                    # For debugging
                                    abs_distance_anime              = abs(compute_distance_anime(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By)/max_anime)
                                    abs_distance_anime_modified     = abs(compute_distance_anime_modified(min_Ax, max_Ax, min_Ay, max_Ay, min_Bx, max_Bx, min_By, max_By)/max_anime_modified)

                                    # We log the results on a file
                                    configuration = str(min_Ax)+str(max_Ax)+str(min_Ay)+str(max_Ay)+str(min_Bx)+str(max_Bx)+str(min_By)+str(max_By)
                                    output_file.write(configuration + "," + str(distance_anime) + "," + str(distance_euclidean_repres) + "," + str(distance_manhattan_repres) + "," + str(distance_manhattan_ranges) + "," + str(distance_anime_modified) + "," + str(abs_distance_anime) + "," + str(abs_distance_anime_modified) + "\n")

    output_file.close()