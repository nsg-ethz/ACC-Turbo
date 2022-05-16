# RUN WITH PYTHON 3 !!! OTHERWISE THE apply_async DOES NOT WORK !!!
import sys
import os 

if __name__ == '__main__':

    if len(sys.argv) != 2: 
        print("Syntax reguired: analyze.py name_analysis")
    else:

            output_file_features_purity = open('plot_features_purity.dat', 'w')

            # We initialize the file
            output_file_features_purity.write("#    Range_Exhaustive    Range_Fast    Representative_Exhaustive    Representative_Fast\n")

            for features in feature_list:
                average_purity_range_exhaustive = ""
                average_purity_range_fast = ""
                average_purity_representative_exhaustive = ""
                average_purity_representative_fast = ""    

                input_file = open('clustering_performance_logs.dat', 'r')
                for line in input_file.readlines():
                    if ("Online_Range_Exhaustive_10_1_0.3_False_1_" + features) in line:
                        average_purity_range_exhaustive = line.split(",")[1]
            
                    elif ("Online_Range_Fast_10_1_0.3_False_1_" + features) in line:
                        average_purity_range_fast = line.split(",")[1]      
            
                    elif ("Online_Representative_Exhaustive_10_1_0.3_False_1_" + features) in line:
                        average_purity_representative_exhaustive = line.split(",")[1]      
            
                    elif ("Online_Representative_Fast_10_1_0.3_False_1_" + features) in line:
                        average_purity_representative_fast = line.split(",")[1]   

                output_file_features_purity.write(features + "    " + average_purity_range_exhaustive + "    " + average_purity_range_fast + "    " + average_purity_representative_exhaustive + "    " + average_purity_representative_fast + "\n")
                input_file.close()

            output_file_features_purity.close()