"""
runs moongen script to replay traffic at a given rate
"""

import os
import sys

if __name__ == "__main__":

    os.system("sudo /opt/MoonGen/build/MoonGen reaction_time_receiver.lua")