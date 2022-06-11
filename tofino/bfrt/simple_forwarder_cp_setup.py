import sys

# -----------------
# Egress setup
# -----------------
egress = bfrt.simple_forwarder.pipe.MyEgress

# We initialize the timer
egress.timestamp.add(0)
egress.timestamp.mod(0, 0)

# We initialize the counters
if len(sys.argv) > 1 and "carpetbombing" in sys.argv:
    egress.do_bytes_count_malicious_egress.add_with_bytes_count_malicious_egress("10.0.0.50")   
else:
    egress.do_bytes_count_malicious_egress.add_with_bytes_count_malicious_egress("5.5.5.5")

egress.do_bytes_count_benign_egress.add_with_bytes_count_benign_egress(140)    


bfrt.complete_operations()
print("Finished setting up the control plane interfaces")