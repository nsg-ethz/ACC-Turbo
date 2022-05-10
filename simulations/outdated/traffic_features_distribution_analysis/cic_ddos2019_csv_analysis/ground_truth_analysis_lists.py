import csv

# Here instad of plotting the data, we will list the set of different IPs, ports, protocols, and max packet lengths
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

        # We create the lists
        list_sport = []
        list_dport = []  
        list_saddr = []
        list_daddr = []
        list_proto = []
        list_max_packet_length = []

        row_counter = 0

        # We read the csv file to extract the feature. Each row is a different flow
        with open(file_name) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:

                # Let's just print the flows that correspond to an attack
                if row[len(row)-1] == 'BENIGN':

                    if row_counter > 5000: 
                        break

                    else:
                        if int(row[3]) not in list_sport:
                            list_sport.append(int(row[3]))

                        if int(row[5]) not in list_dport:
                            list_dport.append(int(row[5]))

                        if row[2] not in list_saddr:
                            list_saddr.append(row[2])

                        if row[4] not in list_daddr:
                            list_daddr.append(row[4])

                        if int(row[6]) not in list_proto:
                            list_proto.append(int(row[6]))

                        if float(row[46]) not in list_max_packet_length:
                            list_max_packet_length.append(float(row[46]))
                    
                    row_counter = row_counter + 1

        list_saddr.sort()
        list_daddr.sort()
        list_sport.sort()
        list_dport.sort()
        list_proto.sort()
        list_max_packet_length.sort()

        file_results = open('list-results-benign/' + attack_name + 'results_lists.dat', 'w+') # 1st byte of the src address
        file_results.write("Source Port\n")
        file_results.write(','.join([str(elem) for elem in list_sport]))
        file_results.write("\nDestination Port\n")
        file_results.write(','.join([str(elem) for elem in list_dport]))
        file_results.write("\nSource Address\n")
        file_results.write(','.join([str(elem) for elem in list_saddr]))
        file_results.write("\nDestination Address\n")
        file_results.write((','.join([str(elem) for elem in list_daddr])))
        file_results.write("\nProtocol\n")
        file_results.write((','.join([str(elem) for elem in list_proto])))
        file_results.write("\nMax packet length\n")
        file_results.write((','.join([str(elem) for elem in list_max_packet_length])))
        file_results.close()

