"""
runs moongen script to replay traffic at a given rate
"""

import os
import argparse

if __name__ == "__main__":

    #Usage: libmoon moongen/dump-pkts.lua [-a ip] [-f <file>] [-s <snap_len>] [-t <threads>] [-o <output>] [-h] <dev> [<filter>]

    # Options
    # -f --file", "Write result to a pcap file"
	# -s --snap-len", "Truncate packets to this size"
    # "filter" "A BPF filter expression."

    # Print output pcap
    #os.system("sudo /opt/MoonGen/build/MoonGen moongen/dump_pkts_from_nic_to_pcap.lua -f output.pcap -s 2000 0")
    
    # Compute benign and malicious throughput
    os.system("sudo /opt/MoonGen/build/MoonGen moongen/receiver.lua 0")