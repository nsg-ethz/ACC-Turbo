
# ACC-Turbo: Reproducing the results

## Background 

**Setup requirements**: 

**Figure 6: Mitigation of a pulse-wave DDoS attack**: 

* **Figure 6a: FIFO**:
    * Execute (tofino switch): `./run_fig_06a/run_fig_6a_tofino.sh`
    * Execute (receiving server): `./run_fig_06a/run_fig_6a_receiver.sh`
    * Execute (sending server): `./run_fig_06a/run_fig_6a_sender.sh`
    
    * Results (receiving server): `run_fig_06a/results/fifo_throughput_nic_benign.dat`, `run_fig_06a/results/fifo_throughput_nic_malicious.dat`
    * Process results (receiving server): `gnuplot run_fig_06a/results/fifo_in_out_plot.gnuplot`
    * Plot (receiving server): `run_fig_06a/results/fifo_in_out_plot.pdf`

* **Figure 6b: ACC-Turbo**:
    * Execute (tofino switch): `./run_fig_06b/run_ddos_aid920.sh`
    * Execute (receiving server): ``
    * Execute (sending server): ``
    
    * Results (receiving server): `run_fig_06b/results/accturbo_throughput_nic_benign.dat`, `run_fig_06a/results/accturbo_throughput_nic_malicious.dat`
    * Process results (receiving server): `gnuplot run_fig_06b/results/accturbo_in_out_plot.gnuplot`
    * Plot (receiving server): `run_fig_06b/results/accturbo_in_out_plot.pdf`

**Figure 7: Reaction-time evaluation**: 

* **Figure 7a: FIFO**:
    * Execute (tofino switch): `./run_fig_07a/run_fig_07a_tofino.sh`
    * Execute (sending server): `./run_fig_07a/run_fig_07a_sender.sh`
    
    * Results (tofino switch): `run_fig_07a/results/fifo_throughput_benign.dat`, `run_fig_07a/results/fifo_throughput_malicious.dat`
    * Process results (tofino switch): `gnuplot run_fig_07a/results/fifo_plot_throughput.gnuplot`
    * Plot (tofino switch): `run_fig_07a/results/fifo_output_throughput.pdf`

* **Figure 7b: ACC-Turbo**:
    * Execute (tofino switch): `./run_fig_07b/run_fig_07b_tofino.sh`
    * Execute (sending server): `./run_fig_07b/run_fig_07b_sender.sh`
    
    * Results (tofino switch): `run_fig_07b/results/accturbo_throughput_benign.dat`, `run_fig_07b/results/accturbo_throughput_malicious.dat`
    * Process results (tofino switch): `gnuplot run_fig_07b/results/accturbo_plot_throughput.gnuplot`
    * Plot (tofino switch): `run_fig_07b/results/accturbo_output_throughput.pdf`

* **Figure 7c: Reprogramming time**:
    * Execute (tofino switch): `./run_fig_07c/run_fig_07c_tofino.sh`
    * Execute (receiving server): `./run_fig_07c/run_fig_07c_receiver.sh`
    * Execute (sending server): `./run_fig_07c/run_fig_07c_sender.sh`

    * Results (receiving server): `run_fig_07c/results/throughput_program1.dat`, `run_fig_07c/results/throughput_program2.dat`
    * Process results (receiving server): `gnuplot run_fig_07c/results/plot.gnuplot`
    * Plot (receiving server): `run_fig_07c/results/plot.pdf`

* **Figure 7d: Jaqen**:
    * Execute (tofino switch): `./run_fig_07d/run_fig_07d_tofino.sh`
    * Execute (sending server): `./run_fig_07d/run_fig_07d_sender.sh`
    
    * Results (tofino switch): `run_fig_07d/results/jaqen_throughput_benign.dat`, `run_fig_07d/results/jaqen_throughput_malicious.dat`
    * Process results (tofino switch): `gnuplot run_fig_07d/results/jaqen_plot_throughput.gnuplot`
    * Plot (tofino switch): `run_fig_07d/results/jaqen_output_throughput.pdf`

**Figure 8: Threshold-configuration sensitivity**: 
    * Follow the process for Fig 7a, and Fig 7b
    * Extract the percentage of benign packet drops from `run_fig_07a/results/fifo_throughput_benign.dat`, and `run_fig_07b/results/accturbo_throughput_benign.dat`, respectively

* **Figure 8a: Threshold setting**:
    * Execute the process for Fig 7d
    * Extract the percentage of benign packet drops from `run_fig_07d/results/jaqen_throughput_benign.dat`

    * Repeat the previous two steps, setting the following threshold values {1, 10, 10^2, 10^3, 10^4, 10^5, 10^6, 3·10^6, 5·10^6, 7·10^6, 10^7, 10^8} in `python_controller/heavy_hitter_reaction_controller.py`: 
    * Result: `run_fig_08a/results/threshold.dat`
    * Plot: `run_fig_08a/results/threshold.pdf`

* **Figure 8b: Speed**:
    * Execute the process for Fig 7d
    * Extract the percentage of benign packet drops from `run_fig_07d/results/jaqen_throughput_benign.dat`

    * Repeat the previous two steps, setting the following speed values {0, 5, 10, 15, 20} in `python_controller/heavy_hitter_reaction_controller.py`: 
    * Result: `run_fig_08b/results/speed.dat`
    * Plot: `run_fig_08b/results/speed.pdf`
