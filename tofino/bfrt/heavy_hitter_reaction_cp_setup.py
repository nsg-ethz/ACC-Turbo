# -----------------
# Ingress setup
# -----------------
ingress = bfrt.heavy_hitter_reaction.pipe.MyIngress

BLOOM_FILTER_ENTRIES = 1024

for entry in range(BLOOM_FILTER_ENTRIES):
    ingress.counting_bloom_filter.add(entry)
    #ingress.counting_bloom_filter.mod(entry, 10)

# -----------------
# Egress setup
# -----------------
egress = bfrt.heavy_hitter_reaction.pipe.MyEgress

# We initialize the timer
egress.timestamp.add(0)
egress.timestamp.mod(0, 0)

# We initialize the counters
egress.do_bytes_count_malicious_egress.add_with_bytes_count_malicious_egress("5.5.5.5")    
egress.do_bytes_count_benign_egress.add_with_bytes_count_benign_egress(140)    


bfrt.complete_operations()
print("Finished setting up the control plane interfaces")