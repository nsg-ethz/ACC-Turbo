import csv

if __name__ == '__main__':

    # We create a list with all the csv files we want to analyze
    file_list = []
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_DNS.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_LDAP.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_MSSQL.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_NetBIOS.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_NTP.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_SNMP.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_SSDP.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_UDP.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/Syn.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/TFTP.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/UDPLag.csv')

    for file_name in file_list:     
        print("Analyzing file: " + file_name)
        attack_name = file_name.split('/mnt/fischer/albert/CSV01_12/01_12/')[1].split('.csv')[0]

        # We create the output files where we will store each individual feature that we want to plot (vs. time)
        time_sport = open(attack_name + '/time_sport.dat', 'w+')
        time_dport = open(attack_name + '/time_dport.dat', 'w+')
        
        time_saddr0 = open(attack_name + '/time_saddr0.dat', 'w+') # 1st byte of the src address
        time_saddr1 = open(attack_name + '/time_saddr1.dat', 'w+') # 2nd byte of the src address
        time_saddr2 = open(attack_name + '/time_saddr2.dat', 'w+') # 3rd byte of the src address
        time_saddr3 = open(attack_name + '/time_saddr3.dat', 'w+') # 4th byte of the src address
    
        time_daddr0 = open(attack_name + '/time_daddr0.dat', 'w+') # 1st byte of the dst address
        time_daddr1 = open(attack_name + '/time_daddr1.dat', 'w+') # 2nd byte of the dst address
        time_daddr2 = open(attack_name + '/time_daddr2.dat', 'w+') # 3rd byte of the dst address
        time_daddr3 = open(attack_name + '/time_daddr3.dat', 'w+') # 4th byte of the dst address
        
        time_proto = open(attack_name + '/time_proto.dat', 'w+')
        time_min_packet_length = open(attack_name + '/time_min_packet_length.dat', 'w+')
        time_max_packet_length = open(attack_name + '/time_max_packet_length.dat', 'w+')

        row_counter = 0

        # We read the csv file to extract the feature. Each row is a different flow
        with open(file_name) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:

                # Let's just print the flows that correspond to an attack
                #if row_counter == 0 or row[len(row)-1] == attack_name:
                if row_counter == 0 or row[len(row)-1] == "BENIGN":

                    if row_counter > 5000: 
                        break

                    else:
                        time_sport.write(row[7] + "," + row[3] + "\n")
                        time_dport.write(row[7] + "," + row[5] + "\n")

                        if row_counter == 0: 
                            time_saddr0.write(row[7] + "," + row[2] + "\n")
                            time_saddr1.write(row[7] + "," + row[2] + "\n")
                            time_saddr2.write(row[7] + "," + row[2] + "\n")
                            time_saddr3.write(row[7] + "," + row[2] + "\n")

                            time_daddr0.write(row[7] + "," + row[4] + "\n")
                            time_daddr1.write(row[7] + "," + row[4] + "\n")
                            time_daddr2.write(row[7] + "," + row[4] + "\n")
                            time_daddr3.write(row[7] + "," + row[4] + "\n")

                        else: 
                            time_saddr0.write(row[7] + "," + row[2].split(".")[0] + "\n")
                            time_saddr1.write(row[7] + "," + row[2].split(".")[1] + "\n")
                            time_saddr2.write(row[7] + "," + row[2].split(".")[2] + "\n")
                            time_saddr3.write(row[7] + "," + row[2].split(".")[3] + "\n")

                            time_daddr0.write(row[7] + "," + row[4].split(".")[0] + "\n")
                            time_daddr1.write(row[7] + "," + row[4].split(".")[1] + "\n")
                            time_daddr2.write(row[7] + "," + row[4].split(".")[2] + "\n")
                            time_daddr3.write(row[7] + "," + row[4].split(".")[3] + "\n")
                        
                        time_proto.write(row[7] + "," + row[6] + "\n")
                        time_min_packet_length.write(row[7] + "," + row[45] + "\n")
                        time_max_packet_length.write(row[7] + "," + row[46] + "\n")
                    
                    row_counter = row_counter + 1

        time_sport.close()
        time_dport.close()
        time_saddr0.close()
        time_saddr1.close()
        time_saddr2.close()
        time_saddr3.close()
        time_daddr0.close()
        time_daddr1.close()
        time_daddr2.close()
        time_daddr3.close()        
        time_proto.close()
        time_min_packet_length.close()
        time_max_packet_length.close()

        # We generate the actual plots
        #print('Generating the plots...')
        #os.system(attack_name + '/gnuplot plot.gnuplot') 