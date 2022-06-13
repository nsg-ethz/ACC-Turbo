#!/bin/bash
# RUN WITH SUDO!

# Compile p4 program
. /data/set_sde_9.5.0.sh
./p4_build.sh --with-p4c="/data/bf-sde-9.5.0/install/bin/bf-p4c" p4src/simple_forwarder.p4

sudo /home/nsg/bf-sde-9.2.0/install/bin/bf_kdrv_mod_unload 
sudo /home/nsg/bf-sde-9.5.0/install/bin/bf_kdrv_mod_load /home/nsg/bf-sde-9.5.0/install/

#############
# Real switch
#############

# Create a new tmux session (in the background) where we run the code
tmux new -s tofino -d
tmux send-keys -t tofino '. /data/set_sde_9.5.0.sh' Enter
tmux send-keys -t tofino '../../run_switchd.sh -p simple_forwarder' Enter

# Configure the ports
tmux send-keys -t tofino 'ucli' Enter
tmux send-keys -t tofino 'pm port-add 30/- 100G NONE' Enter
tmux send-keys -t tofino 'pm an-set 30/- 2' Enter
tmux send-keys -t tofino 'pm port-enb 30/-' Enter
tmux send-keys -t tofino 'pm port-add 2/0 10G NONE' Enter
tmux send-keys -t tofino 'pm an-set 2/0 2' Enter
tmux send-keys -t tofino 'pm port-enb 2/0' Enter
tmux send-keys -t tofino 'pm show' Enter

# Add a new window pane for the bfshell
tmux split-window -h -p 75
tmux select-pane -t 2
tmux send-keys -t tofino '. /data/set_sde_9.5.0.sh' Enter
tmux send-keys -t tofino '../../run_bfshell.sh -b bfrt/simple_forwarder_cp_setup.py' Enter

# Add a new window pane for the pd-rpc
tmux split-window -h -p 66
tmux select-pane -t 3
tmux send-keys -t tofino '. set_sde_9.5.0.sh' Enter
tmux send-keys -t tofino '../../run_pd_rpc.py pd_rpc/fifo.py' Enter

# Add a new window pane for the controller
tmux split-window -h -p 50
tmux select-pane -t 4
tmux send-keys -t tofino '. /data/set_sde_9.5.0.sh' Enter
tmux send-keys -t tofino 'cd  python_controller/' Enter
tmux send-keys -t tofino 'python simple_forwarder_controller.py'

# Attach to the session we have just created
tmux attach-session -t tofino