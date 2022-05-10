import dpkt
import datetime
import matplotlib
import matplotlib.pyplot as plt
import os
import multiprocessing 
import socket

matplotlib.use('tkagg')

def analyze_file(file_name):

    global dict_throughput

    # We initialize the main variables for the analysis
    attack_in_file = False

    # We analyze the pcap file, reading packet by packet
    print('Started processing ' + file_name)
    f = open(file_name,'rb')
    pcap = dpkt.pcap.Reader(f)
    
    for timestamp, buf in pcap:
        
        # Extract the date and time
        date_time = datetime.datetime.fromtimestamp(timestamp)-datetime.timedelta(hours=5, minutes=0) # There is a difference of 5h with respect to UTC in that dataset
        
        # We only analyze the fragment of the attack
        start_time = datetime.datetime(2018, 12, 1, 13, 25, 00, 000000)
        end_time = datetime.datetime(2018, 12, 1, 13, 26, 00, 000000)

        if date_time < start_time or date_time > end_time: 
            continue # We skip that iteration

        # If it is inside the window, we print the name of the file, just to check that the attack is contained in a single pcap file, otherwise we can do progressive
        attack_in_file = True

        # We extract the packet source and destination port
        eth = dpkt.ethernet.Ethernet(buf)
        str_eth_src = ':'.join('%02x' % dpkt.compat_ord(b) for b in eth.src) # To make easier to read the mac
        str_eth_dst = ':'.join('%02x' % dpkt.compat_ord(b) for b in eth.dst)

        if not isinstance(eth.data, dpkt.ip.IP):
            continue

        ip = eth.data
        if not isinstance(ip.data, dpkt.udp.UDP):
            continue # We only focus on UDP traffic for now

        str_ip_src = str(socket.inet_ntop(socket.AF_INET, ip.src))
        str_ip_dst = str(socket.inet_ntop(socket.AF_INET, ip.dst))

        udp = ip.data

        # If we do not round up the graph making takes too long, we are just grouping ports in groups of 100
        rounded_src = round(udp.sport/100)
        rounded_dst = round(udp.dport/100)

        str_transp_src = str(rounded_src)
        str_transp_dst = str(rounded_dst)

        # We update the throughput for that flow
        key = str_transp_src + "," + str_transp_dst
        if key in dict_throughput:
            dict_throughput[key] = dict_throughput[key] + len(buf) # count bits  
        else:
            dict_throughput[key] = len(buf) # count bits  

    f.close()

    # Once we have processed the pcap file, we save the results in an output file
    if attack_in_file:
        print("Attack encountered in: " + file_name)


if __name__ == '__main__':

    global dict_throughput
    dict_throughput = {}

    # We create a list with all the pcap files we want to analyze
    file_list = []

    for file_id in range(800):
        if file_id == 0:
            file_name = '/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0'
        else:
            file_name = '/mnt/fischer/albert/DDoS2019/SAT-01-12-2018_0' + str(file_id)
        file_list.append(file_name)

    # We check all the files that contain the portion of attack
    for file_name in file_list:
        analyze_file(file_name)

    # We print the results in a file
    print('Saving the results on a file...')
    file = open('11webddos_plotting.dat', 'w+')    
    file.write("#,Throughput\n")


    for src in range(0,655):
        for dst in range (0,655):
            key = str(src) + "," + str(dst)
            if key in dict_throughput:
                file.write("%s,%s\n" % (key, dict_throughput[key]))
            else:
                file.write("%s,%s\n" % (key, "0"))     
        file.write("\n")            
    file.close()