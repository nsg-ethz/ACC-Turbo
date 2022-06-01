#!/bin/bash
# RUN WITH SUDO!

# Compile p4 program
#../../../p4_build_albert.sh p4src/simple_forwarder.p4

#############
# Real switch
#############

# Create a new tmux session (in the background) where we run the code
tmux new -s tofino -d
tmux send-keys -t tofino '. set_sde_9.2.0.sh' Enter
tmux send-keys -t tofino '/home/nsg/albert/run_switchd.sh -p simple_forwarder' Enter

# Configure the ports
tmux send-keys -t tofino 'ucli' Enter
tmux send-keys -t tofino 'pm port-add 8/- 100G NONE' Enter
tmux send-keys -t tofino 'pm port-enb 8/-' Enter
tmux send-keys -t tofino 'pm port-add 26/- 100G NONE' Enter
tmux send-keys -t tofino 'pm an-set 26/- 2' Enter
tmux send-keys -t tofino 'pm port-enb 26/-' Enter
tmux send-keys -t tofino 'pm port-add 29/- 100G NONE' Enter
tmux send-keys -t tofino 'pm an-set 29/- 2' Enter
tmux send-keys -t tofino 'pm port-enb 29/-' Enter
tmux send-keys -t tofino 'pm port-add 31/- 100G NONE' Enter
tmux send-keys -t tofino 'pm port-enb 31/-' Enter
tmux send-keys -t tofino 'pm port-add 32/- 100G NONE' Enter
tmux send-keys -t tofino 'pm port-enb 32/-' Enter
tmux send-keys -t tofino 'pm port-add 2/0 10G NONE' Enter
tmux send-keys -t tofino 'pm an-set 2/0 2' Enter
tmux send-keys -t tofino 'pm port-enb 2/0' Enter
tmux send-keys -t tofino 'pm port-add 2/1 10G NONE' Enter
tmux send-keys -t tofino 'pm an-set 2/1 2' Enter
tmux send-keys -t tofino 'pm port-enb 2/1' Enter
tmux send-keys -t tofino 'pm port-add 2/2 10G NONE' Enter
tmux send-keys -t tofino 'pm an-set 2/2 2' Enter
tmux send-keys -t tofino 'pm port-enb 2/2' Enter
tmux send-keys -t tofino 'pm port-add 2/3 10G NONE' Enter
tmux send-keys -t tofino 'pm an-set 2/3 2' Enter
tmux send-keys -t tofino 'pm port-enb 2/3' Enter
tmux send-keys -t tofino 'pm show' Enter

# Add a new window pane for the bfshell
tmux split-window -h -p 50
tmux select-pane -t 2
tmux send-keys -t tofino '. set_sde_9.2.0.sh' Enter
tmux send-keys -t tofino '/home/nsg/albert/run_pd_rpc.py ~/albert/DDoS-AID/code/tofino/pd_rpc/simple_forwarder.py' Enter

# Attach to the session we have just created
tmux attach-session -t tofino