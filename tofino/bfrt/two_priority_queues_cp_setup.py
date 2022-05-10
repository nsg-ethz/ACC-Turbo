# -----------------
# Ingress setup
# -----------------
ingress = bfrt.two_priority_queues.pipe.MyIngress

# We map the malicious traffic to the low priority queue
ingress.select_queue.add_with_set_qid("5.5.5.5", 0) 

# -----------------
# Egress setup
# -----------------
egress = bfrt.two_priority_queues.pipe.MyEgress

# We initialize the timer
egress.timestamp.add(0)
egress.timestamp.mod(0, 0)

# We initialize the counters
egress.do_bytes_count_malicious_egress.add_with_bytes_count_malicious_egress("5.5.5.5")
egress.do_bytes_count_benign_egress.add_with_bytes_count_benign_egress(140)    

bfrt.complete_operations()
print("Finished setting up the control plane interfaces")