"""
runs moongen script to replay traffic at a given rate
"""

import os
import sys

if __name__ == "__main__":

    # Add the ethernet headers to the pcap
    #tcprewrite --dlt=enet --enet-dmac=00:11:22:33:44:55 --enet-smac=66:77:88:99:AA:BB --infile="/home/albert/DDoS-AID/code/pcaps/fixed_equinix-nyc.dirA.20180315.pcap" --outfile="/home/albert/DDoS-AID/code/pcaps/caida_baseline.pcap"

    # Configuration
    dev = 4
    file = "caida_baseline.pcap"
    rate_multiplier = 2 # Read the pcap at twice the speed
    
    # The morphing attack of the original DDoS-AID paper (NSDI '21 version)
    if len(sys.argv) == 1:
        os.system("sudo /opt/MoonGen/build/MoonGen moongen/nsdi_traffic_gen.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))
    
    else:
        if sys.argv[1] == "no_attack":
            os.system("sudo /opt/MoonGen/build/MoonGen moongen/no_attack.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "udp_carpet_bombing":
            os.system("sudo /opt/MoonGen/build/MoonGen moongen/udp_carpet_bombing.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "udp_single_flow":
            os.system("sudo /opt/MoonGen/build/MoonGen moongen/udp_single_flow.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "udp_source_spoof":
            os.system("sudo /opt/MoonGen/build/MoonGen moongen/udp_source_spoof.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "adversarial":
            os.system("sudo /opt/MoonGen/build/MoonGen moongen/adversarial.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))
    
        elif sys.argv[1] == "udp_two_flows":
            os.system("sudo /opt/MoonGen/build/MoonGen moongen/udp_two_flows.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))

        elif sys.argv[1] == "randomized_udp":
            os.system("sudo /opt/MoonGen/build/MoonGen moongen/randomized_udp.lua --pcap-rate-multiplier {} {} {}".format(rate_multiplier, dev, file))