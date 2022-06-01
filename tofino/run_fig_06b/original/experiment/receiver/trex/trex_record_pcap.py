import os, sys
import time
import argparse
import logging

sys.path.append("/opt/trex/v2.77/trex_client/interactive") # append parent directory to path
from trex_stl_lib.api import STLClient


log = logging.getLogger("record_pcap")
log.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s;%(name)s;%(levelname)s:\t%(message)s", "%Y-%m-%d %H:%M:%S")
ch.setFormatter(formatter)
log.addHandler(ch)


def trex_record_pcap(port,limit,pcap):
    # TRex client
    client = STLClient(server="127.0.0.1")
    client.connect()
    client.reset(ports=port)
    client.set_service_mode(ports = port)

    # start capture
    log.info("starting capture of %i packets at port %i" % (limit,port))
    capture = client.start_capture(rx_ports = port, limit = limit, mode="fixed")

    # check status periodically
    count = 0
    while count < limit:
        status = client.get_capture_status()
        count = status[capture["id"]]["count"]
        log.info("captured: %i / %i" % (count, limit))
        time.sleep(1)

    log.info("stopping capture")
    # Stop capture
    client.stop_capture(capture_id = capture["id"], output=pcap)
    
    # exit service mode on port 0
    client.set_service_mode(ports = 0, enabled = False)
    log.info("capture stopped")


if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description='record a pcap')
    parser.add_argument('--port', type=int, required=True,
                        help='port id')
    parser.add_argument('--limit', type=int, required=False, default=1000000,
                        help='packets to capture')
    parser.add_argument('--pcap', required=True, 
                        help='path to output pcap file')
    args = parser.parse_args()
    
    trex_record_pcap(args.port, args.limit, args.pcap)
