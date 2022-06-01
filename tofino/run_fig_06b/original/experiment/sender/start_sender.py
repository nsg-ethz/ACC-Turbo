"""
runs moongen script to replay traffic at a given rate
"""

import os
import argparse

if __name__ == "__main__":

    # Pcap Replication
    dev = 3
    file = "/home/albert/DDoS-AID/code/pcaps/caida_baseline.pcap"
    rate_multiplier = 2 # Read the pcap at twice the speed
    
    os.system("sudo /opt/MoonGen/build/MoonGen moongen/traffic_generation.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))