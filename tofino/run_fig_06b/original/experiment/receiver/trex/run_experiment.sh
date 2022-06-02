# IMPORTANT!! There is a config file for trex: /etc/trex_cfg.yaml
# Make sure that it contains the interfaces we want 
# We can get the interface information from: /opt/MoonGen/libmoon/deps/dpdk/usertools/dpdk-devbind.py --status

# In our case we want to use: 
#0000:81:00.0 'Ethernet Controller X710 for 10GbE SFP+ 1572' if=ens787f0 drv=i40e unused=igb_uio *Active* (ens787f0 = 3c:fd:fe:b4:97:80)
#0000:81:00.1 'Ethernet Controller X710 for 10GbE SFP+ 1572' if=ens787f1 drv=i40e unused=igb_uio *Active* (ens787f1 = 3c:fd:fe:b4:97:81)
#0000:81:00.2 'Ethernet Controller X710 for 10GbE SFP+ 1572' if=ens787f2 drv=i40e unused=igb_uio *Active* (ens787f2 = 3c:fd:fe:b4:97:82)
#0000:81:00.3 'Ethernet Controller X710 for 10GbE SFP+ 1572' if=ens787f3 drv=i40e unused=igb_uio *Active* (ens787f3 = 3c:fd:fe:b4:97:83)

## Trex_cfg.yaml
#- port_limit      : 4
#  version         : 2
#List of interfaces. Change to suit your setup. Use ./dpdk_setup_ports.py -s to see available options
#  interfaces    : ["0000:81:00.0","0000:81:00.1","0000:81:00.2","0000:81:00.3"]
#  port_info       :  # Port IPs. Change to suit your needs. In case of loopback, you can leave as is.
#          - ip         : 15.15.15.15
#            dest_mac   : '3c:fd:fe:b4:97:80'
#          - ip         : 16.16.16.16
#            dest_mac   : '3c:fd:fe:b4:97:81'
#          - ip         : 17.17.17.17
#            dest_mac   : '3c:fd:fe:b4:97:82'
#          - ip         : 18.18.18.18
#            dest_mac   : '3c:fd:fe:b4:97:83'

# Create a new tmux session (in the background)
tmux new -s arak -d

# On the first pane we run 

tmux send-keys -t arak 'cd /opt/trex/v2.77' Enter
tmux send-keys -t arak 'sudo ./t-rex-64 -i' Enter

# If it fails, try opening sudo ./trex-console, and then closing and starting `sudo ./t-rex-64 -i` again

# We run the experiment
tmux split-window -v -p 50
tmux select-pane -t 2
tmux send-keys -t arak 'sudo python3 trex_record_pcap.py --port 0 --pcap test.pcap' Enter

# I also had to follow https://github.com/pypa/pipenv/issues/187 to solve the locale issue

# Attach to the session we have just created
tmux attach-session -t arak

