##################################
# Motivation analysis
##################################

def analyze_true_positives():

    rates = ['0', '2', '4', '6', '8', '10']
    percentages = ['0', '02', '06', '04', '06', '08', '1']

    # We create and initialize the three output files
    output_drops_benign = open("netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_benign.dat", "w")
    output_drops_malicious = open("netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_malicious.dat", "w")
    output_drops_total = open("netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_total.dat", "w")

    output_drops_benign.write("# AttackRate(Gbps), TruePositiveRate(%), DropsBenign(%)")
    output_drops_malicious.write("# AttackRate(Gbps), TruePositiveRate(%), DropsMalicious(%)")
    output_drops_total.write("# AttackRate(Gbps), TruePositiveRate(%), DropsTotal(%)")

    # Tn = 1
    # Tp from 0 to 1    
    for rate in rates:
        for percentage in percentages:
            input_file_first = open("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn1_tp" + percentage + "/statistics.log", "r")
            for line in input_file_first:

                # We read the statistics
                if line.split(": ")[0] == "BENIGN_PACKETS_SENT":
                    benign_sent = float(line.split(": ")[1])
                if line.split(": ")[0] == "BENIGN_PACKETS_DROPPED":
                    benign_dropped = float(line.split(": ")[1])      
                if line.split(": ")[0] == "MALICIOUS_PACKETS_SENT":
                    malicious_sent = float(line.split(": ")[1])
                if line.split(": ")[0] == "MALICIOUS_PACKETS_DROPPED":
                    malicious_dropped = float(line.split(": ")[1])
                if line.split(": ")[0] == "PACKETS_SENT":
                    total_sent = float(line.split(": ")[1])   
                if line.split(": ")[0] == "PACKETS_DROPPED":
                    total_dropped = float(line.split(": ")[1]) 
            input_file_first.close()

            if rate != '0':
                drop_percentage_malicious = (malicious_dropped/malicious_sent)*100
            else: 
                drop_percentage_malicious = 0

            drop_percentage_benign = (benign_dropped/benign_sent)*100
            drop_percentage_total = (total_dropped/total_sent)*100

            if (len(percentage) == 2):
                percentage = "0." + percentage.split("0")[1]

            output_drops_benign.write("\n" + str(rate) + "," + str(percentage) + "," + str(drop_percentage_benign))
            output_drops_malicious.write("\n" + str(rate) + "," + str(percentage) + "," + str(drop_percentage_malicious))
            output_drops_total.write("\n" + str(rate) + "," + str(percentage) + "," + str(drop_percentage_total))  

    output_drops_benign.close()
    output_drops_malicious.close()
    output_drops_total.close()

def analyze_true_negatives():

    rates = ['0', '2', '4', '6', '8', '10']
    percentages = ['0', '02', '06', '04', '06', '08', '1']

    # We create and initialize the three output files
    output_drops_benign = open("netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_benign.dat", "w")
    output_drops_malicious = open("netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_malicious.dat", "w")
    output_drops_total = open("netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_total.dat", "w")

    output_drops_benign.write("# AttackRate(Gbps), TrueNegativeRate(%), DropsBenign(%)")
    output_drops_malicious.write("# AttackRate(Gbps), TrueNegativeRate(%), DropsMalicious(%)")
    output_drops_total.write("# AttackRate(Gbps), TrueNegativeRate(%), DropsTotal(%)")

    # Tn = 1
    # Tp from 0 to 1    
    for rate in rates:
        for percentage in percentages:
            input_file_first = open("netbench_ddos/temp/ddos-aid/motivation/" + rate + "Gbps/tn" + percentage + "_tp1/statistics.log", "r")
            for line in input_file_first:

                # We read the statistics
                if line.split(": ")[0] == "BENIGN_PACKETS_SENT":
                    benign_sent = float(line.split(": ")[1])
                if line.split(": ")[0] == "BENIGN_PACKETS_DROPPED":
                    benign_dropped = float(line.split(": ")[1])      
                if line.split(": ")[0] == "MALICIOUS_PACKETS_SENT":
                    malicious_sent = float(line.split(": ")[1])
                if line.split(": ")[0] == "MALICIOUS_PACKETS_DROPPED":
                    malicious_dropped = float(line.split(": ")[1])
                if line.split(": ")[0] == "PACKETS_SENT":
                    total_sent = float(line.split(": ")[1])   
                if line.split(": ")[0] == "PACKETS_DROPPED":
                    total_dropped = float(line.split(": ")[1]) 
            input_file_first.close()

            if rate != '0':
                drop_percentage_malicious = (malicious_dropped/malicious_sent)*100
            else: 
                drop_percentage_malicious = 0

            drop_percentage_benign = (benign_dropped/benign_sent)*100
            drop_percentage_total = (total_dropped/total_sent)*100

            if (len(percentage) == 2):
                percentage = "0." + percentage.split("0")[1]

            output_drops_benign.write("\n" + str(rate) + "," + str(percentage) + "," + str(drop_percentage_benign))
            output_drops_malicious.write("\n" + str(rate) + "," + str(percentage) + "," + str(drop_percentage_malicious))
            output_drops_total.write("\n" + str(rate) + "," + str(percentage) + "," + str(drop_percentage_total))  

    output_drops_benign.close()
    output_drops_malicious.close()
    output_drops_total.close()


if __name__ == "__main__":
    analyze_true_positives()
    analyze_true_negatives()