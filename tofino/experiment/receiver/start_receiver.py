"""
runs moongen script to replay traffic at a given rate
"""

import os
import sys

if __name__ == "__main__":

    #Usage: libmoon moongen/dump-pkts.lua [-a ip] [-f <file>] [-s <snap_len>] [-t <threads>] [-o <output>] [-h] <dev> [<filter>]

    # Options
    # -f --file", "Write result to a pcap file"
	# -s --snap-len", "Truncate packets to this size"
    # "filter" "A BPF filter expression."

    # Print output pcap
    #os.system("sudo /opt/MoonGen/build/MoonGen moongen/dump_pkts_from_nic_to_pcap.lua -f output.pcap -s 2000 0")
    
    # The receiver of the original DDoS-AID paper (NSDI '21 version)
    if len(sys.argv) == 2:
        if sys.argv[1] == "fifo":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/receiver/receiver_fifo.lua 2")
        elif sys.argv[1] == "accturbo":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/receiver/receiver_accturbo.lua 2")
