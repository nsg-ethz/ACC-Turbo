
# ACC-Turbo: Simulations

## Introduction

In this file we document the artifacts that we used for the software-based experiments of our paper. They consist of two big components. First, a set of simulation scenarios built on top of [NetBench](https://github.com/ndal-eth/netbench), a packet-level simulator. Second, a set of python scripts that pre-process the pcap files of the dataset (i.e., clusters packets and labels them with the clusters they are mapped to and the priorities they are assigned), such that the process can be paralelized and finish faster than e.g., if running everything on Netbench.

The structure of the folder is as follows:
```
ACC-Turbo
├── simulations 
│   │
│   ├── netbench
│   │    ├── projects/accturbo
│   │    │   ├── runs
│   │    │   └── analysis
│   │    └── src/main/java/ch/ethz/systems/netbench/xpt/ports
│   │        ├── ACC
│   │        └── ACCTurbo
│   │
│   ├── python
│   │    ├── main.py
│   │    ├── clustering
│   │    └── plots
│   │
│   ├── run_fig_x.sh
│   └── README.md
```

* The `netbench` folder contains all the materials regarding the simulator. We took the same setup from [SP-PIFO](https://github.com/nsg-ethz/sp-pifo), and extended it to include [ACC](https://github.com/nsg-ethz/ACC-Turbo/tree/main/simulations/netbench/src/main/java/ch/ethz/systems/netbench/xpt/ports/ACC) and [ACCTurbo](https://github.com/nsg-ethz/ACC-Turbo/tree/main/simulations/netbench/src/main/java/ch/ethz/systems/netbench/xpt/ports/ACCTurbo). The run configurations can be found in `projects/accturbo/runs`. The results from the simulations and post-processing scripts (e.g., result analysis and plotting) can be found in  `projects/accturbo/analysis`.

* The `python` folder contains the pre-processing python scripts needed for the experiments involving the CICDDoS dataset. The scripts are named `main.py` and `analyzer.py`. The different clustering algorithms are implemented in `clustering`. The post processing-scripts and results can be found in `plots`.

* We have prepared a set of scripts, `run_fig_x.sh`, which already configure, and execute the required experiments, and analyze and plot the results, for each of the experiments in the paper. 

## Reproducing the results [Section 2: Background]

**Requirements**:

- Clone this github repository, and `cd simulations/`
- Install gnuplot: `apt-get install gnuplot`

**Figure 2: Comparison between ACC and ACC-Turbo**: 

* Execute: `./run_fig_02.sh`

* **Figure 2a: No ACC**:
    * Result: `netbench/temp/accturbo/acc_original/slowgrow`
    * Plots: 
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow/droprate_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow/droprate_aggregate.pdf)

* **Figure 2b: ACC**:
    * Result: `netbench/temp/accturbo/acc_original/slowgrow_acc`
    * Plots: 
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/droprate_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/droprate_aggregate.pdf)

* **Figure 2c: ACC: Impact of K**:
    * Result: `netbench/temp/accturbo/acc_reactiontime`
    * Plots: 
        * [`netbench/projects/accturbo/analysis/acc_reactiontime/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_reactiontime/output_aggregate.pdf)
        * [`netbench/projects/accturbo/analysis/acc_reactiontime/droprate_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_reactiontime/droprate_aggregate.pdf)

* **Figure 2d: ACC-Turbo**:
    * Result: `netbench/temp/accturbo/acc_original/slowgrow_accturbo`
    * Plots: 
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow_accturbo/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_accturbo/output_aggregate.pdf)
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow_accturbo/droprate_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_accturbo/droprate_aggregate.pdf)

**Figure 3: Performance under morphing attack**: 

* Execute: `./run_fig_03.sh`

* **Figure 3a: No ACC**:
    * Result: `netbench/temp/accturbo/acc_morphing/fifo`
    * Plot: [`netbench/projects/accturbo/analysis/acc_morphing/fifo/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_morphing/fifo/output_aggregate.pdf)

* **Figure 3b: ACC**:
    * Result: `netbench/temp/accturbo/acc_morphing/acc`
    * Plot: [`netbench/projects/accturbo/analysis/acc_morphing/acc/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_morphing/acc/output_aggregate.pdf)

* **Figure 3c: Speed vs accuracy**:
    * Result: `netbench/temp/accturbo/acc_accuracy_K`
    * Plots: [`netbench/projects/accturbo/analysis/acc_accuracy_K/benign_drops.pdf`](netbench/projects/accturbo/analysis/acc_accuracy_K/benign_drops.pdf)

* **Figure 3d: ACC-Turbo**:
    * Result: `netbench/temp/accturbo/acc_morphing/accturbo`
    * Plot: [`netbench/projects/accturbo/analysis/acc_morphing/accturbo/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_morphing/accturbo/output_aggregate.pdf)

## Reproducing the results [Section 8: Simulation-based Evaluation]

**Requirements**:

- Clone this github repository, and `cd simulations/`
- Install dpkt: `pip3 install dpkt`
- Install matplotlib: `pip3 install matplotlib`. If you get the error "Failed building wheel for pillow", you can fix it by `sudo apt-get install libjpeg-dev zlib1g-dev`
- Install sklearn: `pip3 install sklearn`
- Download the [CIC DDoS2019 dataset](https://www.unb.ca/cic/datasets/ddos-2019.html). We only use the second day (i.e., testing day), given that our clustering algorithm is unsupervised. Place the dataset in `DDoS2019/`, preserving the original names: `SAT-01-12-2018_0` until `SAT-01-12-2018_0818`
- Install gnuplot: `sudo apt-get install gnuplot`
- In line 104 of `python/analyzer.py`, configure the number of cores that you want to use. By default it uses 128 cores.

**Figure 9: Performance by attack type and features**: 

* **Figure 9a: Attack split**:
    * Execute: `./run_fig_09a.sh`
    * Result: `python/plots/attack_split`
    * Plot: [`python/plots/attack_split/attack_split.pdf`](python/plots/attack_split/attack_split.pdf)

* **Figure 9b: Feature split**:
    * Execute: `./run_fig_09b.sh`
    * Result: `python/plots/feature_split`
    * Plot: [`python/plots/feature_split/feature_split.pdf`](python/plots/feature_split/feature_split.pdf)

**Figure 10: Performance of clustering strategies**: 
* Execute: `./run_fig_10.sh`
* Results: `python/plots/num_clusters`
* 💡 *Tip:* Since this experiment involves the exhaustive clustering algorithms, it takes much longer to execute. You can see the progressive results, at any point during the experiment, in `python/plots/num_clusters/clustering_performance_logs.dat`. You can stop the simulation at any point in time, and plot the results collected until then by using `python3 python/plots/num_clusters/analyze.py` and `gnuplot python/plots/num_clusters/plot_num_clusters.gnuplot`, respectively. You may also want to just run the fast approaches by commenting the exhaustive runs in the `./run_fig_10.sh` configuration.

* **Figure 10a: Purity**:
    * Plot: [`python/plots/num_clusters/numclusters_purity.pdf`](python/plots/num_clusters/numclusters_purity.pdf)

* **Figure 10b: Recall benign**:
    * Plot: [`python/plots/num_clusters/numclusters_recall_benign.pdf`](python/plots/num_clusters/numclusters_recall_benign.pdf)

**Figure 11: Impact of scheduling for mitigation**: 

* Requirement: `sudo apt install pcapfix`

* **Figure 11a: Performance of different ranking algorithms**:
    * Execute: `./run_fig_11a.sh`
    * Result: `python/plots/ranking_algorithms`
    * Plot: [`python/plots/ranking_algorithms/ranking_algorithms.pdf`](python/plots/ranking_algorithms/ranking_algorithms.pdf)

* **Figure 11b: Overall performance**:
    * Execute: `./run_fig_11b.sh`
    * Result: `netbench/temp/accturbo/bottleneck_capacities`
    * Plots: [`netbench/projects/accturbo/analysis/bottleneck_capacities/percentage_benign_plot.pdf`](netbench/projects/accturbo/analysis/bottleneck_capacities/percentage_benign_plot.pdf)
* 💡 *Tip:* This experiment takes the longest to execute since it involves two steps. First, a python script processes the input pcaps from the dataset, clusters their packets online, and tags them with their assigned priorities. Then, we feed the resulting pcap traces into a virtual switch on Netbench, which forwards the packets based on their priorities towards a link of pre-configured capacity. The whole process takes quite some time. Feel free to just run the experiment for a subset of the clustering algorithms. You can do that, by adjusting the config. file `./run_fig_11b.sh`.


---
