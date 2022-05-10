import csv
from collections import Counter, OrderedDict

# Here instad of plotting the data, we will list the set of different IPs, ports, protocols, and max packet lengths
if __name__ == '__main__':

    # We create a list with all the csv files we want to analyze
    file_list = []
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_DNS.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_LDAP.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_MSSQL.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_NetBIOS.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_NTP.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_SNMP.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_SSDP.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/DrDoS_UDP.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/Syn.csv')
    #file_list.append('/mnt/fischer/albert/CSV01_12/01_12/TFTP.csv')
    file_list.append('/mnt/fischer/albert/CSV01_12/01_12/UDPLag.csv')

    for file_name in file_list:     
        print("Analyzing file: " + file_name)
        attack_name = file_name.split('/mnt/fischer/albert/CSV01_12/01_12/')[1].split('.csv')[0]
        list_times = []
        first = True

        if attack_name == "UDPLag":
            attack_name = "UDP-lag"

        # We read the csv file to extract the feature. Each row is a different flow
        with open(file_name) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:

                # Let's just print the flows that correspond to an attack
                if row[len(row)-1] == attack_name:
                    if first:
                        print("First flow start: " + row[7])
                        first = False                            

            print("Last flow start: " + row[7] + ", Duration: " + row[8])
