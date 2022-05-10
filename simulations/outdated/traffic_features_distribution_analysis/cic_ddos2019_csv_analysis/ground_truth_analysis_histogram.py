import csv
from collections import Counter, OrderedDict

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
                if row[len(row)-1] == attack_name:

                    #if row_counter > 5000: 
                    if False:
                        break

                    else:
                            list_sport.append(int(row[3]))
                            list_dport.append(int(row[5]))
                            list_saddr.append(row[2])
                            list_daddr.append(row[4])
                            list_proto.append(int(row[6]))
                            list_max_packet_length.append(float(row[46]))
                    
                    row_counter = row_counter + 1

        cnt_saddr = Counter()
        cnt_daddr = Counter()
        cnt_sport = Counter()
        cnt_dport = Counter()
        cnt_proto = Counter()
        cnt_max_packet_length = Counter()

        for saddr in list_saddr:
            cnt_saddr[saddr] += 1

        for daddr in list_daddr:
            cnt_daddr[daddr] += 1

        for sport in list_sport:
            cnt_sport[sport] += 1

        for dport in list_dport:
            cnt_dport[dport] += 1

        for proto in list_proto:
            cnt_proto[proto] += 1

        for max_packet_length in list_max_packet_length:
            cnt_max_packet_length[max_packet_length] += 1

        dict_saddr = OrderedDict(cnt_saddr.most_common())
        dict_daddr = OrderedDict(cnt_daddr.most_common())
        dict_sport = OrderedDict(cnt_sport.most_common())
        dict_dport = OrderedDict(cnt_dport.most_common())
        dict_proto = OrderedDict(cnt_proto.most_common())
        dict_max_packet_length = OrderedDict(cnt_max_packet_length.most_common())

        # We finally print the dictionaries
        file_saddr = open('histograms-result-malicious/' + attack_name + '/saddr.dat', 'w+')
        file_daddr = open('histograms-result-malicious/' + attack_name + '/daddr.dat', 'w+')
        file_sport = open('histograms-result-malicious/' + attack_name + '/sport.dat', 'w+')
        file_dport = open('histograms-result-malicious/' + attack_name + '/dport.dat', 'w+')
        file_proto = open('histograms-result-malicious/' + attack_name + '/proto.dat', 'w+')
        file_max_packet_length = open('histograms-result-malicious/' + attack_name + '/max_packet_length.dat', 'w+')


        file_saddr.write("#Source Address Count\n")
        for key in dict_saddr:
            file_saddr.write(str(key) + "," + str(dict_saddr[key]) + "\n")

        file_daddr.write("#Destination Address Count\n")
        for key in dict_daddr:
            file_daddr.write(str(key) + "," + str(dict_daddr[key]) + "\n")

        file_sport.write("#Source Port Count\n")
        for key in dict_sport:
            file_sport.write(str(key) + "," + str(dict_sport[key]) + "\n")

        file_dport.write("#Destination Port Count\n")
        for key in dict_dport:
            file_dport.write(str(key) + "," + str(dict_dport[key]) + "\n")

        file_proto.write("#Protocol Count\n")
        for key in dict_proto:
            file_proto.write(str(key) + "," + str(dict_proto[key]) + "\n")

        file_max_packet_length.write("#Max packet length Count\n")
        for key in dict_max_packet_length:
            file_max_packet_length.write(str(key) + "," + str(dict_max_packet_length[key]) + "\n")    

        file_saddr.close()
        file_daddr.close()
        file_sport.close()
        file_dport.close()
        file_proto.close()
        file_max_packet_length.close()

