
# ACC-Turbo: Reproducing the results

## Background 

**Figure 2: Comparison between ACC and ACC-Turbo**: 

* Execute: `./run_fig_2.sh`

* **Figure 2a: No ACC**:
    * Result: `./temp/accturbo/acc_original/slowgrow`
    * Plots: 
        * [`projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)
        * [`projects/accturbo/analysis/acc_original/slowgrow/droprate_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow/droprate_aggregate.pdf)

* **Figure 2b: ACC**:
    * Result: `./temp/accturbo/acc_original/slowgrow_acc`
    * Plots: 
        * [`projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)
        * [`projects/accturbo/analysis/acc_original/slowgrow_acc/droprate_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow_acc/droprate_aggregate.pdf)

* **Figure 2c: ACC: Impact of K**:
    * Result: `./temp/accturbo/acc_reactiontime`
    * Plots: 
        * [`projects/accturbo/analysis/acc_reactiontime/output_aggregate.pdf`](projects/accturbo/analysis/acc_reactiontime/output_aggregate.pdf)
        * [`projects/accturbo/analysis/acc_reactiontime/droprate_aggregate.pdf`](projects/accturbo/analysis/acc_reactiontime/droprate_aggregate.pdf)

* **Figure 2d: ACC-Turbo**:
    * Result: `./temp/accturbo/acc_original/slowgrow_accturbo`
    * Plots: 
        * [`projects/accturbo/analysis/acc_original/slowgrow_accturbo/output_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow_accturbo/output_aggregate.pdf)
        * [`projects/accturbo/analysis/acc_original/slowgrow_accturbo/droprate_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow_accturbo/droprate_aggregate.pdf)

**Figure 3: Performance under morphing attack**: 

* Execute: `./run_fig_3.sh`

* **Figure 3a: No ACC**:
    * Result: `./temp/accturbo/acc_morphing/fifo`
    * Plot: [`projects/accturbo/analysis/acc_morphing/fifo/output_aggregate.pdf`](projects/accturbo/analysis/acc_morphing/fifo/output_aggregate.pdf)

* **Figure 3b: ACC**:
    * Result: `./temp/accturbo/acc_morphing/acc`
    * Plot: [`projects/accturbo/analysis/acc_morphing/acc/output_aggregate.pdf`](projects/accturbo/analysis/acc_morphing/acc/output_aggregate.pdf)

* **Figure 3c: Speed vs accuracy**:
    * Result: `./temp/accturbo/acc_accuracy_K`
    * Plots: [`projects/accturbo/analysis/acc_accuracy_K/benign_drops.pdf`](projects/accturbo/analysis/acc_accuracy_K/benign_drops.pdf)

* **Figure 3d: ACC-Turbo**:
    * Result: `./temp/accturbo/acc_morphing/accturbo`
    * Plot: [`projects/accturbo/analysis/acc_morphing/accturbo/output_aggregate.pdf`](projects/accturbo/analysis/acc_morphing/accturbo/output_aggregate.pdf)

## Simulation-based Evaluation

**Figure 9: Performance by attack type and features**: 

* Execute: `./run_fig_9.sh`
* **Figure 9a: Attack split**:
    * Result: `./temp/accturbo/acc_original/slowgrow`
    * Plot: [`projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](rojects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)

* **Figure 9b: Feature split**:
    * Result: `./temp/accturbo/acc_original/slowgrow_acc`
    * Plots: [`projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)

**Figure 10: Performance of clustering strategies**: 

* Execute: `./run_fig_10.sh`
* **Figure 10a: Purity**:
    * Result: `./temp/accturbo/acc_original/slowgrow`
    * Plot: [`projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)

* **Figure 10b: Recall benign**:
    * Result: `./temp/accturbo/acc_original/slowgrow_acc`
    * Plots: [`projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)

**Figure 11: Impact of scheduling for mitigation**: 

* Execute: `./run_fig_11.sh`
* **Figure 11a: Performance of different ranking algorithms**:
    * Result: `./temp/accturbo/acc_original/slowgrow`
    * Plot: [`projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)

* **Figure 11b: Overall performance**:
    * Result: `./temp/accturbo/acc_original/slowgrow_acc`
    * Plots: [`projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)

---