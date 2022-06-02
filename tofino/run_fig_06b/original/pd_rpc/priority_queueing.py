# General settings
a_dev = 0
a_port = 140

# Queue identifiers
a_queue0 = 0
a_queue1 = 1
a_queue2 = 2
a_queue3 = 3

# Obtaining and printing the default configuration of port 140
a_mapping_default = tm.thrift.tm_get_port_q_mapping(a_dev, a_port)
print('Default configuration: {}'.format(a_mapping_default))

# Setting 4 priority queues (higher value means higher priority)
a_qmap = tm.q_map_t(0,1,2,3)
a_numqueues = 4
tm.thrift.tm_set_port_q_mapping(a_dev, a_port, a_numqueues, a_qmap)
tm.thrift.tm_set_q_sched_priority(a_dev, a_port, a_queue0, 0)
tm.thrift.tm_set_q_sched_priority(a_dev, a_port, a_queue1, 1)
tm.thrift.tm_set_q_sched_priority(a_dev, a_port, a_queue2, 2)
tm.thrift.tm_set_q_sched_priority(a_dev, a_port, a_queue3, 3)

# Obtaining and printing the updated configuration
a_mapping_new = tm.thrift.tm_get_port_q_mapping(a_dev,a_port)
print ('Updated configuration: {}'.format(a_mapping_new))

tm.thrift.tm_enable_port_shaping(0,140)
tm.thrift.tm_set_port_shaping_rate(0,140,False,100000,10000000) #high burst rate is important, otherwise we have losses

#tm_disable_port_shaping(self, dev, port):


#Settings for port X: No queues allocated
# a_qmap_0 = q_map_t(0)
# a_numqueues_0 = 0
# tm.thrift.tm_set_port_q_mapping(a_dev, a_port_0, a_numqueues_0, a_qmap_0)

#Trying to modify the global output rate for generating congestion
#a_pps = bool(0)
#tm.thrift.tm_set_port_shaping_rate(a_dev, a_port_1, a_pps, 8192, 100000)
#a_shapingrate_new_1 = tm.thrift.tm_get_port_shaping_rate(a_dev, a_port_1)
#print a_shapingrate_new_1
#tm.thrift.tm_enable_port_shaping(a_dev, a_port_1)