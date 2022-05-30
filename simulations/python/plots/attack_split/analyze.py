# RUN WITH PYTHON 3 !!! OTHERWISE THE apply_async DOES NOT WORK !!!
import sys
import os 

if __name__ == '__main__':

    # We initialize the file
    input_file = open('python/plots/attack_split/clustering_performance_logs.dat', 'r')
    output_file = open('python/plots/attack_split/attack_split.dat', 'w')
    output_file.write("#Attack    Purity_Reflection    Purity_Exploitation\n")

    purity_ntp = "0"
    purity_dns = "0"
    purity_mssql = "0"
    purity_netbios = "0"
    purity_snmp = "0"
    purity_ssdp = "0"
    purity_tftp = "0"
    purity_udp = "0"
    purity_udplag = "0"
    
    for line in input_file.readlines():
        if ("NTP" in line):
            purity_ntp = line.split(",")[1]

        elif ("DNS" in line):
            purity_dns = line.split(",")[1]      
    
        elif ("MSSQL" in line):
            purity_mssql = line.split(",")[1]           

        elif ("NetBIOS" in line):
            purity_netbios = line.split(",")[1] 

        elif ("SNMP" in line):
            purity_snmp = line.split(",")[1] 

        elif ("SSDP" in line):
            purity_ssdp = line.split(",")[1] 

        elif ("TFTP" in line):
            purity_tftp = line.split(",")[1] 

        elif ("UDP" in line and not "UDPLag" in line):
            purity_udp = line.split(",")[1]                                

        elif ("UDPLag" in line):
            purity_udplag = line.split(",")[1]      
    
    input_file.close()
                        
    output_file.write("NTP    " + purity_ntp + "    " + "0 \n")
    output_file.write("DNS    " + purity_dns + "    " + "0 \n")
    output_file.write("MSSQL    " + purity_mssql + "    " + "0 \n")
    output_file.write("NetBIOS    " + purity_netbios + "    " + "0 \n")
    output_file.write("SNMP    " + purity_snmp + "    " + "0 \n")
    output_file.write("SSDP    " + purity_ssdp + "    " + "0 \n")
    output_file.write("TFTP    " + purity_tftp + "    " + "0 \n")
    output_file.write("UDP    0    " + purity_udp + "\n")  #Exploitation
    output_file.write("UDPLag    0    " + purity_udplag + "\n")  #Exploitation
    output_file.close()