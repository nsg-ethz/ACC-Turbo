#!/bin/bash
# RUN WITH SUDO!

# Compile first p4 program
. /data/set_sde_9.5.0.sh
./p4_build.sh --with-p4c="/data/bf-sde-9.5.0/install/bin/bf-p4c" p4src/program1.p4

# Compile second p4 program
./p4_build.sh --with-p4c="/data/bf-sde-9.5.0/install/bin/bf-p4c" p4src/program2.p4

# Create a new tmux session (in the background) where we run the code
tmux new -s tmux_session -d
tmux send-keys -t tmux_session '. /data/set_sde_9.5.0.sh' Enter

# Run the first program (forwards to port 1)
tmux send-keys -t tmux_session '../../run_switchd.sh -p program1' Enter

# Configure the ports
tmux send-keys -t tmux_session 'ucli' Enter
tmux send-keys -t tmux_session 'pm port-add 30/- 100G NONE' Enter
tmux send-keys -t tmux_session 'pm an-set 30/- 2' Enter
tmux send-keys -t tmux_session 'pm port-enb 30/-' Enter

tmux send-keys -t tmux_session 'pm port-add 2/0 10G NONE' Enter
tmux send-keys -t tmux_session 'pm an-set 2/0 2' Enter
tmux send-keys -t tmux_session 'pm port-enb 2/0' Enter

tmux send-keys -t tmux_session 'pm show' Enter

# Wait until ports are up
sleep 5

# Add a new window pane for the bfshell
tmux split-window -h -p 50
tmux select-pane -t 2
tmux send-keys -t tmux_session '. /data/set_sde_9.5.0.sh' Enter
tmux send-keys -t tmux_session '../../run_pd_rpc.py pd_rpc/fifo_port1.py' Enter

# Wait 30 seconds (we start sending traffic here from boilover)
printf "Program 1 is ready, start sending traffic" 
sleep 60

# Close session
printf "Closing the session. Reprogramming tofino... "

tmux send-keys -t tmux_session 'exit' Enter
tmux send-keys -t tmux_session 'exit' Enter
tmux send-keys -t tmux_session C-c

# ................ Changing to program 2 ................................

# Run the first program (forwards to port 1)
tmux send-keys -t tmux_session '../../run_switchd.sh -p program2' Enter

# Configure the ports
tmux send-keys -t tmux_session 'ucli' Enter
tmux send-keys -t tmux_session 'pm port-add 30/- 100G NONE' Enter
tmux send-keys -t tmux_session 'pm an-set 30/- 2' Enter
tmux send-keys -t tmux_session 'pm port-enb 30/-' Enter

tmux send-keys -t tmux_session 'pm port-add 2/0 10G NONE' Enter
tmux send-keys -t tmux_session 'pm an-set 2/0 2' Enter
tmux send-keys -t tmux_session 'pm port-enb 2/0' Enter

tmux send-keys -t tmux_session 'pm show' Enter

# Enter to the session
tmux attach-session -t tmux_session