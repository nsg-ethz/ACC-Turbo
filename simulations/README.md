
# ACC-Turbo: Reproducing the results

## Background 

**Figure 2: Comparison between ACC and ACC-Turbo**: 

* Execute: `./run_fig_02.sh`

* **Figure 2a: No ACC**:
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow`
    * Plots: 
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow/droprate_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow/droprate_aggregate.pdf)

* **Figure 2b: ACC**:
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow_acc`
    * Plots: 
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/droprate_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/droprate_aggregate.pdf)

* **Figure 2c: ACC: Impact of K**:
    * Result: `./netbench/temp/accturbo/acc_reactiontime`
    * Plots: 
        * [`netbench/projects/accturbo/analysis/acc_reactiontime/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_reactiontime/output_aggregate.pdf)
        * [`netbench/projects/accturbo/analysis/acc_reactiontime/droprate_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_reactiontime/droprate_aggregate.pdf)

* **Figure 2d: ACC-Turbo**:
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow_accturbo`
    * Plots: 
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow_accturbo/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_accturbo/output_aggregate.pdf)
        * [`netbench/projects/accturbo/analysis/acc_original/slowgrow_accturbo/droprate_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_accturbo/droprate_aggregate.pdf)

**Figure 3: Performance under morphing attack**: 

* Execute: `./run_fig_03.sh`

* **Figure 3a: No ACC**:
    * Result: `./netbench/temp/accturbo/acc_morphing/fifo`
    * Plot: [`netbench/projects/accturbo/analysis/acc_morphing/fifo/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_morphing/fifo/output_aggregate.pdf)

* **Figure 3b: ACC**:
    * Result: `./netbench/temp/accturbo/acc_morphing/acc`
    * Plot: [`netbench/projects/accturbo/analysis/acc_morphing/acc/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_morphing/acc/output_aggregate.pdf)

* **Figure 3c: Speed vs accuracy**:
    * Result: `./netbench/temp/accturbo/acc_accuracy_K`
    * Plots: [`netbench/projects/accturbo/analysis/acc_accuracy_K/benign_drops.pdf`](netbench/projects/accturbo/analysis/acc_accuracy_K/benign_drops.pdf)

* **Figure 3d: ACC-Turbo**:
    * Result: `./netbench/temp/accturbo/acc_morphing/accturbo`
    * Plot: [`netbench/projects/accturbo/analysis/acc_morphing/accturbo/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_morphing/accturbo/output_aggregate.pdf)

## Simulation-based Evaluation

**Figure 9: Performance by attack type and features**: 

* **Figure 9a: Attack split**:
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow`
    * Plot: [`netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)

* **Figure 9b: Feature split**:
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow_acc`
    * Plots: [`netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)

**Figure 10: Performance of clustering strategies**: 

* Execute: `./run_fig_10.sh`

* **Figure 10a: Purity**:
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow`
    * Plot: [`netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)

* **Figure 10b: Recall benign**:
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow_acc`
    * Plots: [`netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)

**Figure 11: Impact of scheduling for mitigation**: 

* **Figure 11a: Performance of different ranking algorithms**:
    * Execute: `./run_fig_11a.sh`
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow`
    * Plot: [`netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf)

* **Figure 11b: Overall performance**:
    * Execute: `./run_fig_11b.sh`
    * Result: `./netbench/temp/accturbo/acc_original/slowgrow_acc`
    * Plots: [`netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`](netbench/projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf)

---