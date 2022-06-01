"""
runs moongen script to replay traffic at a given rate
"""

import os
import sys

if __name__ == "__main__":

    # Add the ethernet headers to the pcap
    #tcprewrite --dlt=enet --enet-dmac=00:11:22:33:44:55 --enet-smac=66:77:88:99:AA:BB --infile="/home/albert/DDoS-AID/code/pcaps/fixed_equinix-nyc.dirA.20180315.pcap" --outfile="/home/albert/DDoS-AID/code/pcaps/caida_baseline.pcap"

    # Configuration
    dev = 1
    file = "experiment/sender/caida_baseline.pcap"
    rate_multiplier = 2 # Read the pcap at twice the speed
    
    if len(sys.argv) == 1:
        print("Two arguments are required")
    
    else:
        if sys.argv[1] == "no_attack":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/sender/moongen/no_attack.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "udp_single_flow_reactiontime":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/sender/moongen/udp_single_flow_reactiontime.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "morphing":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/sender/moongen/morphing.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "original":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/sender/moongen/original.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "udp_carpet_bombing":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/sender/moongen/udp_carpet_bombing.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "udp_single_flow":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/sender/moongen/udp_single_flow.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "udp_source_spoof":
            os.system("sudo /opt/MoonGen/build/MoonGen experiment/sender/moongen/udp_source_spoof.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))