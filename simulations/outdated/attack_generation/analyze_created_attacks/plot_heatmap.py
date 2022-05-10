import dpkt
import socket
import sys
import datetime

if __name__ == '__main__':


    if len(sys.argv) != 3: 
        print("The number of arguments required is 3")
    else:

        # Configuration
        monitoring_window = 1 # In seconds
        input_file_name = sys.argv[1]

        # We analyze the pcap file, reading packet by packet
        print('Started processing ' + input_file_name)
        input_file = open(input_file_name,'rb')
        pcap = dpkt.pcap.Reader(input_file)
        
        # Initialize the main variables for the analysis
        is_first_packet = True
        current_bucket = 0
        time_axis = 0

        throughput = {}
        throughput[current_bucket] = {}
        total_throughput = 0

        for ip_dst3 in range(256):
            throughput[current_bucket][ip_dst3] = 0
        
        for timestamp, buf in pcap:

            date_time = datetime.datetime.fromtimestamp(timestamp)

            # We define the initial time reference
            if is_first_packet:

                # We initialize the time counters
                time_axis = date_time
                is_first_packet = False

            # Unpack the data within the Ethernet frame (the IP packet)
            try:
                eth = dpkt.ethernet.Ethernet(buf)
            except Exception:
                import traceback
                traceback.print_exc()
                continue 

            # Make sure the Ethernet data contains an IP packet
            if not isinstance(eth.data, dpkt.ip.IP):
                print("Not IP")
                continue

            # Unpack the data within the Ethernet frame (the IP packet)
            ip = eth.data

            str_ip_src = str(socket.inet_ntop(socket.AF_INET, ip.src))
            str_ip_dst = str(socket.inet_ntop(socket.AF_INET, ip.dst))

            # We extract the ip destination third byte
            ip_dst3 = int(str_ip_dst.split(".")[3])

            # We update the throughput
            throughput[current_bucket][ip_dst3] = throughput[current_bucket][ip_dst3] + (int(ip.len)*8) # ip.len is in bytes
            total_throughput = total_throughput + (int(ip.len)*8)

            # We update the time buckets for monitoring
            difference_tracking = (date_time - time_axis).total_seconds()
            if (difference_tracking > monitoring_window):

                print("Time: " + str(current_bucket) + ", Throughput: " + str(total_throughput))
                total_throughput = 0
                current_bucket = current_bucket + 1
                time_axis = date_time

                # We initialize a new bucket
                throughput[current_bucket] = {}
                for ip_dst3 in range(256):
                    throughput[current_bucket][ip_dst3] = 0

        input_file.close()

        # Once we have processed all the pcaps, we write the results in a file
        print('Saving the results on a file...')
        output_file = open(sys.argv[2], 'w+')    
        output_file.write("#, Throughput\n")

        for time in range(current_bucket+1):
            for ip_dst3 in range (256):
                output_file.write(str(time) + "," + str(ip_dst3) + "," + str(throughput[time][ip_dst3])+ "\n") # In seconds and bps
            output_file.write("\n")            
        output_file.close()