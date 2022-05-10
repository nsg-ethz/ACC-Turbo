"""
runs moongen script to replay traffic at a given rate
"""

import os, sys
import random
import time
from scapy.all import *
import argparse
import datetime
import pandas as pd
import numpy as np

import json
import logging
import pickle

log = logging.getLogger("main")
log.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s;%(levelname)s;\t%(message)s", "%Y-%m-%d %H:%M:%S")
ch.setFormatter(formatter)
log.addHandler(ch)


def run_moongen(rate, pcap):

    possible_rates = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

    """
    configuration:
    device 0,1,2,3 is cloned once
    device 4,5,6 is not cloned
    """

    rate_to_devices = {
        0:   [], 
        10:  [4], 
        20:  [0], 
        30:  [0, 4], 
        40:  [0, 1], 
        50:  [0, 1, 4], 
        60:  [0, 1, 2], 
        70:  [0, 1, 2, 4], 
        80:  [0, 1, 2, 3], 
        90:  [0, 1, 2, 3, 4], 
        100: [0, 1, 2, 3, 4, 5],
    }

    if rate not in possible_rates:
        log.error("rate %i is not possible" % rate)
        return
    
    log.info("using devices %s" % str(rate_to_devices[rate]))

    if len(rate_to_devices[rate]) == 0:
        command = "sleep infinity"
    elif len(rate_to_devices[rate]) == 1:
        command = "sudo /opt/MoonGen/build/MoonGen /home/meierrol/volume_obfuscation_src/moongen/replay_and_pad_pcap.lua {ports_list} {pcap} -l"\
        .format(ports_list = " ".join(map(str, rate_to_devices[rate])), pcap = pcap)
    else:
        command = "sudo /opt/MoonGen/build/MoonGen /home/meierrol/volume_obfuscation_src/moongen/replay_and_pad_pcap_{num_ports}ports.lua {ports_list} {pcap} -l"\
            .format(num_ports = str(len(rate_to_devices[rate])), ports_list = " ".join(map(str,rate_to_devices[rate])), pcap = pcap)
    
    log.info("running %s" % command)

    os.system(command)


    




if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='replay traffic from a pcap at a given rate')
    parser.add_argument('--pcap', required=True, help='path to the pcap file')
    # parser.add_argument('--rate', type=int, required=True, help='rate in Gbps (in steps of 10 Gbps)')
    parser.add_argument('--rate', required=True, nargs='+', default=1, help='rates in Gbps, will iterate over them')
    # parser.add_argument('--summary', dest='summary', action='store_true', help='store the size of each packet')

    args = parser.parse_args()

    rates = list(map(int, args.rate))

    for rate in rates:
        os.system("clear")


        log.info("pcap: %s" % args.pcap)
        log.info("rate: %s" % rate)

        run_moongen(rate, args.pcap)

