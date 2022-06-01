import dpkt
import socket
import sys
import datetime

if __name__ == '__main__':

    if len(sys.argv) != 3: 
        print("The number of arguments required is 3: input_file, output_file")
    else:

        # Configuration
        monitoring_window = 1 # In seconds
        file_name = sys.argv[1]

        # Analyze each pcap file, reading packet by packet
        print('Started processing ' + file_name)
        input_file = open(file_name,'rb')
        pcap = dpkt.pcap.Reader(input_file)

        # Initialize the main variables for the analysis
        is_first_packet = True
        current_bucket = 0
        
        time_axis = {}
        time_axis[current_bucket] = None

        throughput = {}    
        throughput[current_bucket] = 0

        for timestamp, buf in pcap:

            date_time = datetime.datetime.fromtimestamp(timestamp)

            # We define the initial time reference
            if is_first_packet == True:

                # We initialize the time counters
                time_axis[0] = date_time
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
            throughput[current_bucket] = throughput[current_bucket] + (int(ip.len)*8) # ip.len is in bytes

            # We update the time buckets for monitoring
            difference_tracking = (date_time - time_axis[current_bucket]).total_seconds()
            if (difference_tracking > monitoring_window):
                current_bucket = current_bucket + 1
                time_axis[current_bucket] = date_time
                throughput[current_bucket] = 0

        input_file.close()

        # Once we have processed all the pcaps, we write the results in a file
        print('Saving the results on a file...')
        output_file = open(sys.argv[2], 'w+')
        output_file.write("#,Throughput\n")
        for line in range(0,current_bucket + 1):
            output_file.write(str(line + 1)+ "," + str(throughput[line]/1000000000)+ "\n") # In seconds and Gbps
        output_file.close()