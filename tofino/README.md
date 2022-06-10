
# ACC-Turbo: Reproducing the results

## Introduction

```
ACC-Turbo
├── tofino
│   │
│   ├── bfrt
│   ├── p4src
│   ├── pd_rpc
│   ├── python_controller
│   │
│   ├── experiment
│   │    ├── sender
│   │    └── receiver
│   │
│   ├── run_fig_x/run_fig_x.sh
│   └── README.md
│   
└── paper.pdf
```


## Reproducing the results [Section 7: Hardware-based Evaluation]

**Setup requirements**: 
- Architecture: [Sending Server] -- 100G --> [ Tofino ] -- 10G --> [Receiving Server]
- Download the slice of the caida trace we use as baseline: [`caida_baseline.pcap`](https://polybox.ethz.ch/index.php/s/cYGvN4uxMUsGDJx). It is a slice of the trace `equinix-nyc.dirA.20180315.pcap`, from [The CAIDA Anonymized Internet Traces](https://www.caida.org/data/passive/passive_dataset_download.xml), year [2018](https://data.caida.org/datasets/passive-2018/). To download the original trace directly from CAIDA, you will need to fill out this [request form](https://www.caida.org/data/passive/passive_dataset_request.xml).
- Decompress the trace, and place it in the `experiment/sender/` folder, at the sender server.
- Install Moongen in both, sender and receiver servers. We place it at `opt/MoonGen/`.
- Install the corresponding NICs in the servers, with DPKT. 
- Install the Tofino 1, with SDE . /data/set_sde_9.5.0.sh
- Install tmux on the Tofino switch. 

**Figure 6: Mitigation of a pulse-wave DDoS attack**: 

* **Figure 6a: FIFO**:
    * Execute (tofino switch): `./run_fig_06a/run_fig_06a_tofino.sh`
    * Execute (receiving server): `./run_fig_06a/run_fig_06a_receiver.sh`
    * Execute (sending server): `./run_fig_06a/run_fig_06a_sender.sh`
    
    * Results (receiving server): [`run_fig_06a/results/fifo_throughput_benign.dat`](run_fig_06a/results/fifo_throughput_benign.dat), [`run_fig_06a/results/fifo_throughput_malicious.dat`](run_fig_06a/results/fifo_throughput_malicious.dat)
    * Process results (receiving server): `gnuplot run_fig_06a/results/fifo_in_out_plot.gnuplot`
    * Plot (receiving server): [`run_fig_06a/results/fifo_in_out_plot.pdf`](run_fig_06a/results/fifo_in_out_plot.pdf)

* **Figure 6b: ACC-Turbo**:
    * Execute (tofino switch): `./run_fig_06b/run_fig_06b_tofino.sh`
    * Execute (receiving server): `./run_fig_06b/run_fig_06b_receiver.sh`
    * Execute (sending server): `./run_fig_06b/run_fig_06b_sender.sh`
    
    * Results (receiving server): [`run_fig_06b/results/accturbo_throughput_benign.dat`](run_fig_06b/results/accturbo_throughput_benign.dat), [`run_fig_06a/results/accturbo_throughput_malicious.dat`](run_fig_06b/results/accturbo_throughput_malicious.dat)
    * Process results (receiving server): `gnuplot run_fig_06b/results/accturbo_in_out_plot.gnuplot`
    * Plot (receiving server): [`run_fig_06b/results/accturbo_in_out_plot.pdf`](run_fig_06b/results/accturbo_in_out_plot.pdf)

**Figure 7: Reaction-time evaluation**: 

* **Figure 7a: FIFO**:
    * Execute (tofino switch): `./run_fig_07a/run_fig_07a_tofino.sh`
    * Wait ~15 seconds, until the ports are up. Then you can start the controller (press enter on the right-most tmux window).
    * Execute (sending server): `./run_fig_07a/run_fig_07a_sender.sh`
    * Wait for 100 seconds. Stop the controller and the sender. You can close the tmux session.
    
    * Results (tofino switch): [`run_fig_07a/results/fifo_throughput_benign.dat`](run_fig_07a/results/fifo_throughput_benign.dat), [`run_fig_07a/results/fifo_throughput_malicious.dat`](run_fig_07a/results/fifo_throughput_malicious.dat)
    * Process results (tofino switch): `gnuplot run_fig_07a/results/fifo_plot_throughput.gnuplot`
    * Plot (tofino switch): [`run_fig_07a/results/fifo_output_throughput.pdf`](run_fig_07a/results/fifo_output_throughput.pdf)

* **Figure 7b: ACC-Turbo**:
    * Execute (tofino switch): `./run_fig_07b/run_fig_07b_tofino.sh`
    * Wait ~15 seconds, until the ports are up. Then you can start the controller (press enter on the right-most tmux window).
    * Execute (sending server): `./run_fig_07b/run_fig_07b_sender.sh`
    * Wait for 100 seconds. Stop the controller and the sender. You can close the tmux session.

    * Results (tofino switch): [`run_fig_07b/results/accturbo_throughput_benign.dat`](run_fig_07b/results/accturbo_throughput_benign.dat), [`run_fig_07b/results/accturbo_throughput_malicious.dat`](run_fig_07b/results/accturbo_throughput_malicious.dat)
    * Process results (tofino switch): `gnuplot run_fig_07b/results/accturbo_plot_throughput.gnuplot`
    * Plot (tofino switch): [`run_fig_07b/results/accturbo_output_throughput.pdf`](run_fig_07b/results/accturbo_output_throughput.pdf)

* **Figure 7c: Reprogramming time**:
    * Execute (receiving server): `./run_fig_07c/run_fig_07c_receiver.sh`
    * Execute (tofino switch): `./run_fig_07c/run_fig_07c_tofino.sh`
    * Execute (sending server): `./run_fig_07c/run_fig_07c_sender.sh`
    * Wait until the second program has fully loaded in the Tofino, and its tmux session has started. You can then close the sender, receiver and tofino.

    * Results (receiving server): [`run_fig_07c/results/throughput_program1.dat`](run_fig_07c/results/throughput_program1.dat), [`run_fig_07c/results/throughput_program2.dat`](run_fig_07c/results/throughput_program2.dat)
    * Process results (receiving server): `gnuplot run_fig_07c/results/plot.gnuplot`
    * Plot (receiving server): [`run_fig_07c/results/plot.pdf`](run_fig_07c/results/plot.pdf)

* **Figure 7d: Jaqen**:
    * Execute (tofino switch): `./run_fig_07d/run_fig_07d_tofino.sh`
    * Wait ~15 seconds, until the ports are up. Then you can start the controller (press enter on the right-most tmux window).
    * Execute (sending server): `./run_fig_07d/run_fig_07d_sender.sh`
    * Wait for 100 seconds. Stop the controller and the sender. You can close the tmux session.

    * Results (tofino switch): [`run_fig_07d/results/jaqen_throughput_benign.dat`](run_fig_07c/results/throughput_program2.dat), [`run_fig_07d/results/jaqen_throughput_malicious.dat`](run_fig_07c/results/throughput_program2.dat)
    * Process results (tofino switch): `gnuplot run_fig_07d/results/jaqen_plot_throughput.gnuplot`
    * Plot (tofino switch): [`run_fig_07d/results/jaqen_output_throughput.pdf`](run_fig_07d/results/jaqen_output_throughput.pdf)

**Figure 8: Threshold-configuration sensitivity**:

* **Common to Figure 8a and 8b**:
    * Follow the process for Fig 7a, and Fig 7b
    * Extract the percentage of benign packet drops from [`run_fig_07a/results/fifo_throughput_benign.dat`](run_fig_07a/results/fifo_throughput_benign.dat), and [`run_fig_07b/results/accturbo_throughput_benign.dat`](run_fig_07b/results/accturbo_throughput_benign.dat), respectively

* **Figure 8a: Threshold setting**:
    * Execute the process for Fig 7d
    * Extract the percentage of benign packet drops from [`run_fig_07d/results/jaqen_throughput_benign.dat`](run_fig_07d/results/jaqen_throughput_benign.dat)

    * Repeat the previous two steps, setting the following threshold values {1, 10, 10^2, 10^3, 10^4, 10^5, 10^6, 3·10^6, 5·10^6, 7·10^6, 10^7, 10^8} in `python_controller/heavy_hitter_reaction_controller.py`: 
    * Result: [`run_fig_08a/results/threshold.dat`](run_fig_08a/results/threshold.dat)
    * Plot: [`run_fig_08a/results/threshold.pdf`](run_fig_08a/results/threshold.pdf)

* **Figure 8b: Speed**:
    * Execute the process for Fig 7d
    * Extract the percentage of benign packet drops from [`run_fig_07d/results/jaqen_throughput_benign.dat`](run_fig_07d/results/jaqen_throughput_benign.dat)

    * Repeat the previous two steps, setting the following speed values {0, 5, 10, 15, 20} in `python_controller/heavy_hitter_reaction_controller.py`: 
    * Result: [`run_fig_08b/results/speed.dat`](run_fig_08b/results/speed.dat)
    * Plot: [`run_fig_08b/results/speed.pdf`](run_fig_08b/results/speed.pdf)
