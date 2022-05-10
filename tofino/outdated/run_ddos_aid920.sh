#!/bin/bash
# RUN WITH SUDO!

# Compile p4 program
. /data/set_sde_9.2.0.sh
#sudo ~/tools/clean_sde.sh
#sudo /home/nsg/bf-sde-9.5.0/install/bin/bf_kdrv_mod_unload 
#sudo /home/nsg/bf-sde-9.2.0/install/bin/bf_kdrv_mod_load /home/nsg/bf-sde-9.2.0/install/

#../../../p4_build_albert.sh --with-p4c="/data/bf-sde-9.2.0/install/bin/bf-p4c" p4src/ddos_aid_4x4_singlepipe_p4_16_modified.p4


#############
# Real switch
#############

# Create a new tmux session (in the background) where we run the code
tmux new -s tofino -d
tmux send-keys -t tofino '. /data/set_sde_9.2.0.sh' Enter
tmux send-keys -t tofino '/home/nsg/albert/run_switchd.sh -p ddos_aid_4x4_singlepipe_p4_16_modified' Enter

# Configure the ports
#tmux send-keys -t tofino 'ucli' Enter
#tmux send-keys -t tofino 'pm port-add 30/- 100G NONE' Enter
#tmux send-keys -t tofino 'pm an-set 30/- 2' Enter
#tmux send-keys -t tofino 'pm port-enb 30/-' Enter
#tmux send-keys -t tofino 'pm port-add 2/0 10G NONE' Enter
#tmux send-keys -t tofino 'pm an-set 2/0 2' Enter
#tmux send-keys -t tofino 'pm port-enb 2/0' Enter
#tmux send-keys -t tofino 'pm show' Enter

# Add a new window pane for the bfshell
tmux split-window -h -p 75
tmux select-pane -t 2
tmux send-keys -t tofino '. /data/set_sde_9.2.0.sh' Enter
tmux send-keys -t tofino '/home/nsg/albert/run_bfshell.sh -b ~/albert/ddos-aid/code/tofino/bfrt/ddosaid_modified_cp_setup.py'

# Add a new window pane for the pd-rpc
tmux split-window -h -p 66
tmux select-pane -t 3
tmux send-keys -t tofino '. /data/set_sde_9.2.0.sh' Enter
tmux send-keys -t tofino '/home/nsg/albert/run_pd_rpc.py ~/albert/ddos-aid/code/tofino/pd_rpc/priority_queueing.py'

# Add a new window pane for the controller
tmux split-window -h -p 50
tmux select-pane -t 4
tmux send-keys -t tofino '. /data/set_sde_9.2.0.sh' Enter
tmux send-keys -t tofino 'cd  ~/albert/ddos-aid/code/tofino/python_controller/' Enter
tmux send-keys -t tofino 'python ddosaidmodified_controller.py'

#tmux send-keys -t tofino 'make' Enter # Compile the controller
#tmux send-keys -t tofino './controller' Enter # Load the controller

# Attach to the session we have just created
tmux attach-session -t tofino


'''

#############
# Tofino model
#############

# Create a new tmux session (in the background) where we run the tofino_model
tmux new -s tofinomodel -d
tmux send-keys -t tofinomodel '. /home/nsg/albert/set_sde_9.5.0.sh' Enter
tmux send-keys -t tofinomodel '/home/nsg/albert/run_tofino_model.sh -p ddos_aid_4x4_singlepipe_p4_16_modified > output_model.log'

# Add a new window pane for the run_switchd
tmux split-window -h -p 75
tmux select-pane -t 2
tmux send-keys -t tofinomodel '. /home/nsg/albert/set_sde_9.5.0.sh' Enter
tmux send-keys -t tofinomodel '/home/nsg/albert/run_switchd.sh -p ddos_aid_4x4_singlepipe_p4_16_modified'

# Add a new window pane for the bfshell (bfrt commands)
tmux split-window -h -p 66
tmux select-pane -t 3
tmux send-keys -t tofinomodel '. /home/nsg/albert/set_sde_9.5.0.sh' Enter
tmux send-keys -t tofinomodel '/home/nsg/albert/run_bfshell.sh -b ~/albert/ddos-aid/code/tofino/bfrt/setup_modified.py'

# Add a new window pane for the scapy (send packets)
tmux split-window -h -p 50
tmux select-pane -t 4
tmux send-keys -t tofinomodel 'sudo ipython' Enter
tmux send-keys -t tofinomodel 'from scapy.all import sendp, sniff, Ether, IP, UDP, TCP' Enter
tmux send-keys -t tofinomodel 'pkt = Ether()/IP(src="0.0.0.8", dst="0.0.0.0", ttl=0, len=1024, id=0)/TCP(sport=0,dport=0)' Enter
tmux send-keys -t tofinomodel 'sendp(pkt, iface="veth0", count=1)'

# Add a new window pane for the scapy (receive packets)
tmux split-window -v
tmux select-pane -t 5
tmux send-keys -t tofinomodel 'sudo ipython' Enter
tmux send-keys -t tofinomodel 'from scapy.all import sendp, sniff, Ether, IP, UDP, TCP' Enter
tmux send-keys -t tofinomodel 'sniff(iface="veth0", prn=lambda x: x.show())' Enter

tmux attach-session -t tofinomodel
'''