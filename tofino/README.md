
# ACC-Turbo: Tofino

## Introduction

In this file we document the artifacts that we used for the hardware-based experiments of our paper. This includes the code required to run the different solutions in the Tofino switch, the code required to send and receive traffic from the respective servers, and the code to process the results and generate the plots. The structure is as follows:

```
ACC-Turbo
├── tofino
│   │
│   ├── p4src
│   ├── bfrt
│   ├── pd_rpc
│   ├── python_controller
│   │
│   ├── experiment
│   │    ├── sender
│   │    └── receiver
│   │
│   ├── run_fig_x/run_fig_x.sh
│   └── README.md
```

* The `p4src` folder contains the p4 codes required to run ACC-Turbo, each of the Jaqen defenses (i.e., heavy-hitter detectors), as well as simple FIFO forwarders.

* The `python_controller`, and `bfrt` folders contains the respective control planes, of each of the p4 programs, as well as their required configuration.

* The `pd_rpc` folder contains the scripts required to configure the Tofino switch to use fifo-forwarding, priority-queues, or port-shaping.

* The `experiment` folder contains the scripts required to generate traffic from the server in charge of sending traffic, and to process traffic from the server in charge of receiving the traffic.

* We have also prepared a set of scripts, `run_fig_x.sh`, which already configure, and execute the required experiments, and analyze and plot the results, for each of the experiments in the paper. We named them `run_fig_x_tofino.sh`, `run_fig_x_sender.sh`, or `run_fig_x_receiver.sh` to indicate from where they should be executed.

---
**💡 Note for the SIGCOMM'22 Artifact Evaluation Process:**   In case you do not have access to a setup like the one required:
- If you have signed the Intel NDA, we will be happy to give you access to our full setup, including the Tofino switch, and both sender and receiver servers, so that you can re-run the experiments. 
- In case you have not signed the Intel NDA, we also got you covered :) Unfortunately, we can not give you access to a Tofino in our lab, but we have prepared a set of screen-recording videos showcasing the reproduction of the Tofino figures in our paper.
---

## Reproducing the results [Section 7: Hardware-based Evaluation]

**Setup requirements:** 

- An [Intel Tofino switch](https://www.intel.com/content/www/us/en/products/network-io/programmable-ethernet-switch/tofino-series.html). We use Intel Tofino Wedge 100BF-32X.
- Two servers with a DPDK-compatible NIC. We used the 100G [NVIDIA Mellanox ConnectX-5 Adapters](https://www.nvidia.com/en-us/networking/ethernet/connectx-5/) for the sending server, and an [Intel X710 4x 10G](https://www.intel.com/content/dam/www/public/us/en/documents/product-briefs/ethernet-x710-brief.pdf) for the receiver.
- Architecture: [Sending Server] -- 100G --> [ Tofino ] -- 10G --> [Receiving Server]
- One cable of 100G connecting the sending server to the Tofino switch. One cable of 10G connecting the Tofino switch (port 140) to the receiving server. 
- We recommend you to configure password free ssh login from your endhost to the servers/switch.

**Software requirements:**
- Install the SDE 9.5.0 on the Tofino switch. 
- Install [DPDK](https://www.dpdk.org/), and [Moongen](https://github.com/emmericp/MoonGen) in both, sender and receiver servers. Place it at `opt/MoonGen/`. Install the drivers such that both, sending, and receiving NICs can be accessed by DPDK. Set up the right device ID in both, the [sender](https://github.com/nsg-ethz/ACC-Turbo/blob/main/tofino/experiment/sender/start_sender.py), and the [receiver](https://github.com/nsg-ethz/ACC-Turbo/blob/main/tofino/experiment/receiver/start_receiver.py).
- Install tmux: `sudo apt install tmux`, on the Tofino switch and both servers.
- Install python 3: `sudo apt install python3`, on the Tofino switch and both servers.
- Install gnuplot: `apt-get install gnuplot`, , on the Tofino switch and the receiving server.

**Initialization:**
- Clone this github repository, and `cd tofino/`.
- Download the slice of the caida trace we use as baseline: [`caida_baseline.pcap`](https://polybox.ethz.ch/index.php/s/cYGvN4uxMUsGDJx). It is a slice of the trace `equinix-nyc.dirA.20180315.pcap`, from [The CAIDA Anonymized Internet Traces](https://www.caida.org/data/passive/passive_dataset_download.xml), year [2018](https://data.caida.org/datasets/passive-2018/). To download the original trace directly from CAIDA, you will need to fill out this [request form](https://www.caida.org/data/passive/passive_dataset_request.xml).
- Decompress the trace, and place it in the `experiment/sender/` folder, at the sender server.


**Figure 6: Mitigation of a pulse-wave DDoS attack**: 

* **Figure 6a: FIFO**:
   * 📹 *Video tutorial:* [https://polybox.ethz.ch/index.php/s/BhZcDKf9qD6xdV4](https://polybox.ethz.ch/index.php/s/BhZcDKf9qD6xdV4)

    * Execute (tofino switch): `sudo ./run_fig_06a/run_fig_06a_tofino.sh`
    * Execute (receiving server): `./run_fig_06a/run_fig_06a_receiver.sh`
    * Execute (sending server): `./run_fig_06a/run_fig_06a_sender.sh`
    
    * Results (receiving server): [`run_fig_06a/results/fifo_throughput_benign.dat`](run_fig_06a/results/fifo_throughput_benign.dat), [`run_fig_06a/results/fifo_throughput_malicious.dat`](run_fig_06a/results/fifo_throughput_malicious.dat)
    * Process results (receiving server): `gnuplot run_fig_06a/results/fifo_in_out_plot.gnuplot`
    * Plot (receiving server): [`run_fig_06a/results/fifo_in_out_plot.pdf`](run_fig_06a/results/fifo_in_out_plot.pdf)

* **Figure 6b: ACC-Turbo**:
   * 📹 *Video tutorial:* [https://polybox.ethz.ch/index.php/s/BhZcDKf9qD6xdV4](https://polybox.ethz.ch/index.php/s/n10SkMDcbAnKlPx)

    * Execute (tofino switch): `sudo ./run_fig_06b/run_fig_06b_tofino.sh`
    * Execute (receiving server): `./run_fig_06b/run_fig_06b_receiver.sh`
    * Execute (sending server): `./run_fig_06b/run_fig_06b_sender.sh`
    
    * Results (receiving server): [`run_fig_06b/results/accturbo_throughput_benign.dat`](run_fig_06b/results/accturbo_throughput_benign.dat), [`run_fig_06a/results/accturbo_throughput_malicious.dat`](run_fig_06b/results/accturbo_throughput_malicious.dat)
    * Process results (receiving server): `gnuplot run_fig_06b/results/accturbo_in_out_plot.gnuplot`
    * Plot (receiving server): [`run_fig_06b/results/accturbo_in_out_plot.pdf`](run_fig_06b/results/accturbo_in_out_plot.pdf)

**Figure 7: Reaction-time evaluation**: 

* **Figure 7a: FIFO**:
   * 📹 *Video tutorial:* [https://polybox.ethz.ch/index.php/s/BhZcDKf9qD6xdV4](https://polybox.ethz.ch/index.php/s/32HF7jTLSnEbgmC)

    * Execute (tofino switch): `sudo ./run_fig_07a/run_fig_07a_tofino.sh`
    * Wait ~15 seconds, until the ports are up. Then you can start the controller (press enter on the right-most tmux window).
    * Execute (sending server): `./run_fig_07a/run_fig_07a_sender.sh`
    * Wait for 100 seconds. Stop the controller and the sender. You can close the tmux session.
    
    * Results (tofino switch): [`run_fig_07a/results/fifo_throughput_benign.dat`](run_fig_07a/results/fifo_throughput_benign.dat), [`run_fig_07a/results/fifo_throughput_malicious.dat`](run_fig_07a/results/fifo_throughput_malicious.dat)
    * Process results (tofino switch): `gnuplot run_fig_07a/results/fifo_plot_throughput.gnuplot`
    * Plot (tofino switch): [`run_fig_07a/results/fifo_output_throughput.pdf`](run_fig_07a/results/fifo_output_throughput.pdf)

* **Figure 7b: ACC-Turbo**:
   * 📹 *Video tutorial:* [https://polybox.ethz.ch/index.php/s/QnVWbRn0ayQYuNg](https://polybox.ethz.ch/index.php/s/QnVWbRn0ayQYuNg)

    * Execute (tofino switch): `sudo ./run_fig_07b/run_fig_07b_tofino.sh`
    * Wait ~15 seconds, until the ports are up. Then you can start the controller (press enter on the right-most tmux window).
    * Execute (sending server): `./run_fig_07b/run_fig_07b_sender.sh`
    * Wait for 100 seconds. Stop the controller and the sender. You can close the tmux session.

    * Results (tofino switch): [`run_fig_07b/results/accturbo_throughput_benign.dat`](run_fig_07b/results/accturbo_throughput_benign.dat), [`run_fig_07b/results/accturbo_throughput_malicious.dat`](run_fig_07b/results/accturbo_throughput_malicious.dat)
    * Process results (tofino switch): `gnuplot run_fig_07b/results/accturbo_plot_throughput.gnuplot`
    * Plot (tofino switch): [`run_fig_07b/results/accturbo_output_throughput.pdf`](run_fig_07b/results/accturbo_output_throughput.pdf)

* **Figure 7c: Reprogramming time**:
   * 📹 *Video tutorial:* [https://polybox.ethz.ch/index.php/s/e2CRBeEBumEi8sf](https://polybox.ethz.ch/index.php/s/e2CRBeEBumEi8sf)

    * Execute (receiving server): `./run_fig_07c/run_fig_07c_receiver.sh`
    * Execute (tofino switch): `sudo ./run_fig_07c/run_fig_07c_tofino.sh`
    * Execute (sending server): `./run_fig_07c/run_fig_07c_sender.sh`
    * Wait until the second program has fully loaded in the Tofino, and its tmux session has started. You can then close the sender, receiver and tofino.

    * Results (receiving server): [`run_fig_07c/results/throughput_program1.dat`](run_fig_07c/results/throughput_program1.dat), [`run_fig_07c/results/throughput_program2.dat`](run_fig_07c/results/throughput_program2.dat)
    * Process results (receiving server): `gnuplot run_fig_07c/results/plot.gnuplot`
    * Plot (receiving server): [`run_fig_07c/results/plot.pdf`](run_fig_07c/results/plot.pdf)

* **Figure 7d: Jaqen**:
    * 📹 *Video tutorial:* [https://polybox.ethz.ch/index.php/s/t6pxxKBHR1bYfPP](https://polybox.ethz.ch/index.php/s/t6pxxKBHR1bYfPP)

    * Execute (tofino switch): `sudo ./run_fig_07d/run_fig_07d_tofino.sh`
    * Wait ~15 seconds, until the ports are up. Then you can start the controller (press enter on the right-most tmux window).
    * Execute (sending server): `./run_fig_07d/run_fig_07d_sender.sh`
    * Wait for 100 seconds. Stop the controller and the sender. You can close the tmux session.

    * Results (tofino switch): [`run_fig_07d/results/jaqen_throughput_benign.dat`](run_fig_07d/results/jaqen_throughput_benign.dat), [`run_fig_07d/results/jaqen_throughput_malicious.dat`](run_fig_07d/results/jaqen_throughput_malicious.dat)
    * Process results (tofino switch): `gnuplot run_fig_07d/results/jaqen_plot_throughput.gnuplot`
    * Plot (tofino switch): [`run_fig_07d/results/jaqen_output_throughput.pdf`](run_fig_07d/results/jaqen_output_throughput.pdf)

**Figure 8: Threshold-configuration sensitivity**:

* **Common to Figure 8a and 8b**:
    * In the Tofino switch, execute either:
        * For ACC-Turbo: `sudo ./run_fig_08/run_fig_08_tofino_accturbo.sh`
        * For FIFO: `sudo ./run_fig_08/run_fig_08_tofino_fifo.sh`
        * For Jaqen: `sudo ./run_fig_08/run_fig_08_tofino_jaqen5tupple.sh`

    * In the sending server, execute: 
        * For UDP flood: `./run_fig_08/run_fig_08_sender_udpflood.sh`
        * For the baseline: `./run_fig_08/run_fig_08_sender_noattack.sh`

    * When the simulation is over, the Tofino script will display the total amount of benign traffic that made it to the egress pipeline of the Tofino switch.
    * Convert it to a percentage taking as reference the the total amount of benign traffic that made it to the egress pipeline of the Tofino switch in the case of no attack.

* **Figure 8a: Threshold setting**:
    * Repeat the process, but setting the following threshold values {1, 10, 10^2, 10^3, 10^4, 10^5, 10^6, 3·10^6, 5·10^6, 7·10^6, 10^7, 10^8} in `python_controller/heavy_hitter_reaction_controller.py`.
    * Place the results in: [`run_fig_08/results_08a/threshold.dat`](run_fig_08/results_08a/threshold.dat). You can take [`run_fig_08/results_08a/paper_threshold.dat`](run_fig_08/results_08a/paper_threshold.dat) as reference for the format.
    * Generate your plot: `gnuplot run_fig_08/results_08a/plot_thresholds.gnuplot`

    * Plot in: [`run_fig_08/results_08a/threshold.pdf`](run_fig_08/results_08a/threshold.pdf)

* **Figure 8b: Speed**:
    * Repeat the process, but setting the following speed values {0, 5, 10, 15, 20} in `python_controller/heavy_hitter_reaction_controller.py`: 
    * Place the results in: [`run_fig_08/results_08b/speed.dat`](run_fig_08/results_08b/speed.dat).
    * Generate your plot: `gnuplot run_fig_08/results_08b/plot_speed.gnuplot`

    * Plot in: [`run_fig_08/results_08b/speed.pdf`](run_fig_08/results_08b/speed.pdf)

**Table 3: Mitigation efficiency under attack variations**:

* In the Tofino switch, execute either:
    * For ACC-Turbo: `sudo ./run_table_03/run_table_03_tofino_accturbo.sh`
    * For FIFO: `sudo ./run_table_03/run_table_03_tofino_fifo.sh`
    * For Jaqen 5 tupple: `sudo ./run_table_03/run_table_03_tofino_jaqen5tupple.sh`
    * For Jaqen src IP: `sudo ./run_table_03/run_table_03_tofino_jaqensrcbased.sh`

* In the sending server, execute either: 
    * For no attack: `./run_table_03/run_table_03_sender_noattack.sh`
    * For single flow: `./run_table_03/run_table_03_sender_udpflood.sh`
    * For carpet bombing: `./run_table_03/run_table_03_sender_carpetbombing.sh`
    * For source spoofing: `./run_table_03/run_table_03_sender_sourcespoofing.sh`

* Whenever the carpet bombing attack is picked at the server, pick the script at the Tofino switch labeled as "carpetbombing". This is:
    * For ACC-Turbo: `sudo ./run_table_03/run_table_03_tofino_carpetbombing_accturbo.sh`. Comment line 2401 and uncomment line 2402 in `accturbo.p4`. 
    * For FIFO: `sudo ./run_table_03/run_table_03_tofino_carpetbombing_fifo.sh`. Comment line 187 and uncomment line 188 in `simple_forwarder.p4`. 
    * For Jaqen 5 tupple: `sudo ./run_table_03/run_table_03_tofino_carpetbombing_jaqen5tupple.sh`. Comment line 291 and uncomment line 292 in `heavy_hitter_5tupple.p4`. 
    * For Jaqen src IP: `sudo ./run_table_03/run_table_03_tofino_carpetbombing_jaqensrcbased.sh`. Comment line 287 and uncomment line 288 in `heavy_hitter_srcbased.p4`. 

* For each {tofino-program, server-script} pair:
    * When the simulation is over, the Tofino script will display the total amount of benign traffic that made it to the egress pipeline of the Tofino switch.
    * Convert it to a percentage taking as reference the the total amount of benign traffic that made it to the egress pipeline of the Tofino switch in the case of no attack.

---
