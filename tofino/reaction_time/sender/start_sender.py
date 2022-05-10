"""
runs moongen script to replay traffic at a given rate
"""

import os
import sys

if __name__ == "__main__":

    # Configuration
    dev = 4
    
    os.system("sudo /opt/MoonGen/build/MoonGen reaction_time_sender.lua {}".format(dev))