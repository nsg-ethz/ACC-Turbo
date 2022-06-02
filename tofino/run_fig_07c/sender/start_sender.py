"""
runs moongen script to replay traffic at a given rate
"""

import os
import sys

if __name__ == "__main__":

    # Configuration
    dev = 1
    
    os.system("sudo /opt/MoonGen/build/MoonGen run_fig_07c/sender/reaction_time_sender.lua {}".format(dev))