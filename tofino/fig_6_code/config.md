# Tofino Configuration

 ## Introduction
 In this documentation we will explain step by step how to configure our testbed.


 ## Hardware set up
 
 ![](config.png?raw=true)

We have Arak - Tofino5 - Boilover.



## Arak configuration

```
sudo ifconfig ens787f0 192.168.5.0 netmask 255.255.255.0
sudo ifconfig ens787f1 192.168.5.1 netmask 255.255.255.0
sudo ifconfig ens787f2 192.168.5.2 netmask 255.255.255.0
sudo ifconfig ens787f3 192.168.5.3 netmask 255.255.255.0

sudo arp -s 192.168.5.4 -i ens787f0 98:03:9b:4d:d8:8c
sudo arp -s 192.168.5.5 -i ens787f0 98:03:9b:4d:d8:8d
```

## Boilover configuration

```
sudo ifconfig enp130s0f0 192.168.5.4 netmask 255.255.255.0
sudo ifconfig enp130s0f1 192.168.5.5 netmask 255.255.255.0

sudo arp -s 192.168.5.0 -i enp130s0f0 3c:fd:fe:b4:97:80
sudo arp -s 192.168.5.1 -i enp130s0f0 3c:fd:fe:b4:97:81
sudo arp -s 192.168.5.2 -i enp130s0f0 3c:fd:fe:b4:97:82
sudo arp -s 192.168.5.3 -i enp130s0f0 3c:fd:fe:b4:97:83
```

## Tofino configuration

```
cd ~/bf-sde-9.2.0
. ~/tools/set_sde.bash; sde
```

2. Compile the program (don't use sudo or smth like that)
```
./p4_build_albert.sh ~/albert/ddos_aid/p4src/ddos_aid.p4
```

3. Execute the program
```
./run_switchd.sh -p simple_l3
```

3. Open bfshell in a new iterm window
```
. ~/tools/set_sde.bash; sde
. ~/bf-sde-9.2.0/run_bfshell.sh
```

 4. Port configuration: Go to port manager and set the ports between Arak/Pisco and Tofino 1/2. We define a new port with connection_id=2 and selecting all four 10G channels with the slash(-) option. We select NONE to skip FEC, and we set up auto-negotiation. 

 ```
 ucli

    pm show

    pm port-add 8/- 100G NONE
    pm port-enb 8/-

    pm port-add 26/- 100G NONE

    pm an-set 26/- 2
    pm port-enb 26/-

    pm port-add 29/- 100G NONE
    pm an-set 29/- 2
    pm port-enb 29/-

    pm port-add 31/- 100G NONE
    pm port-enb 31/-
    pm port-add 32/- 100G NONE
    pm port-enb 32/-

    pm port-add 2/0 10G NONE
    pm an-set 2/0 2
    pm port-enb 2/0

    pm port-add 2/1 10G NONE
    pm an-set 2/1 2
    pm port-enb 2/1

    pm port-add 2/2 10G NONE
    pm an-set 2/2 2
    pm port-enb 2/2

    pm port-add 2/3 10G NONE
    pm an-set 2/3 2
    pm port-enb 2/3

```

Note that ports will not be up until both switches have their connecting link configured. We can see then the tofino (internal) ports allocated to each physical interface.

 ![](pm.png?raw=true)

```
exit
bfrt_python
from netaddr import IPAddress
bfrt.single_pass.pipe.MyIngress.ipv4_host
add_with_send(IPAddress('1.1.1.1'), 1)
add_with_send(IPAddress('192.168.5.1'), 141)
add_with_send(IPAddress('192.168.5.2'), 142)
add_with_send(IPAddress('192.168.5.3'), 143)
add_with_send(IPAddress('192.168.5.4'), 144)
add_with_send(IPAddress('192.168.5.5'), 176)
```

 We can also write a script and run it, and continue interactive:

 ```
 ./run_bfshell.sh -b ~/albert/simple_l3/bfrt_python/setup.py -i 
  ```


To test the system we can send packets with scapy: 

 ```
sudo ipython
import argparse
import sys
import socket
import random
import struct
import time
 
from scapy.all import sendp, get_if_list, get_if_hwaddr
from scapy.all import Ether, IP, UDP, TCP
 
def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"0X
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print "Cannot find eth0 interface"
        exit(1)
    return iface 

pkt = Ether()/IP(src="0.0.0.8", dst="192.168.5.5")/TCP(sport=5)
sendp(pkt, iface="ens787f1", count=100)
 ```

 ```
sniff(iface="veth2", prn=lambda x: x.show())
 ```

 ```
sudo tcpdump -i p803p2 -v
 ```

And now we check that it is correct. It is important to verify that ports are open for TCP and UDP if we want applications to detect incomming packets. For `iperf` testing we have opened ports from `3000` to `3016`.


bfrt.single_pass.pipe.MyIngress.cluster1_sport> get(0xB0)




IMPORTANTISIIM!!

dump(from_hw=True) per pillar el valor del switch, sino dona l ultim que hem agafat!!!

Currently, bf-switchd uses the following algorithm: if it can find and load libpltfm_mgr.so (the BSP that is), then it switches to the ASIC mode, otherwise it chooses the MODEL mode. 

Note, that this is how bf_switchd (i.e. the sample test application) is implemented there is nothing special about this algorithm and you can replace it with your own (including, for example, the ability to select the mode via the command line).

And also, to work with the model, you have to unload the driveeer!!


:10-28 13:05:23.734169:        :0x1:-:<0,0,1>:	     Before stateful alu execution: 0x00000000
:10-28 13:05:23.734180:        :0x1:-:<0,0,1>:	     After stateful alu execution: 0x0000fffb
:10-28 13:05:23.734196:        :0x1:-:<0,0,1>:Next Table = tbl_single_pass207
:10-28 13:05:23.734233:    :0x1:-:<0,0,->:------------ Stage 2 ------------
:10-28 13:05:23.735778:    :0x1:-:<0,0,2>:Ingress : Table tbl_single_pass207 is miss
:10-28 13:05:23.735804:        :0x1:-:<0,0,2>:Key:
:10-28 13:05:23.736108:        :0x1:-:<0,0,2>:Executed StatefulALU 3 with instruction 0
:10-28 13:05:23.736145:        :0x1:-:<0,0,2>:Execute Default Action: single_pass207
:10-28 13:05:23.736190:        :0x1:-:<0,0,2>:Action Results:
:10-28 13:05:23.736202:        :0x1:-:<0,0,2>:	----- ExecuteStatefulAluPrimitive -----
:10-28 13:05:23.736212:        :0x1:-:<0,0,2>:	----- BlackBox: squared_distance_0 -----
:10-28 13:05:23.736223:        :0x1:-:<0,0,2>:	----- register: MyIngress.test2 -----
:10-28 13:05:23.736344:        :0x1:-:<0,0,2>:	--- SALU Condition ---
:10-28 13:05:23.736357:        :0x1:-:<0,0,2>:	  Not supplied by program.
:10-28 13:05:23.736367:        :0x1:-:<0,0,2>:	    SALU ConditionLo: FALSE
:10-28 13:05:23.736378:        :0x1:-:<0,0,2>:	    SALU ConditionHi: FALSE
:10-28 13:05:23.736388:        :0x1:-:<0,0,2>:	--- SALU Update ---
:10-28 13:05:23.736399:        :0x1:-:<0,0,2>:	  None
:10-28 13:05:23.736409:        :0x1:-:<0,0,2>:	--- SALU Output ---
:10-28 13:05:23.736420:        :0x1:-:<0,0,2>:	    Output predicate not supplied by program
:10-28 13:05:23.736430:        :0x1:-:<0,0,2>:	    Output PredicateResult: TRUE
:10-28 13:05:23.736441:        :0x1:-:<0,0,2>:	    Output Destination Field: hdr.ipv4.id = 0x0
:10-28 13:05:23.736451:        :0x1:-:<0,0,2>:	---  SALU Register ---
:10-28 13:05:23.736462:        :0x1:-:<0,0,2>:	   Register Index: 0
:10-28 13:05:23.736473:        :0x1:-:<0,0,2>:	     Before stateful alu execution: 0x00000000
:10-28 13:05:23.736483:        :0x1:-:<0,0,2>:	     After stateful alu execution: 0x00000000