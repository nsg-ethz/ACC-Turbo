
# ACC-Turbo: Reproducing the results

## Background 

**Figure 2: Comparison between ACC and ACC-Turbo**: 

* Execute: `./run_fig_2.sh`

* **Figure 2a: No ACC**:
    * Result: `./temp/accturbo/acc_original/slowgrow`
    * Plots: 
        * `./projects/accturbo/analysis/acc_original/slowgrow/output_aggregate.pdf`
        * `./projects/accturbo/analysis/acc_original/slowgrow/droprate_aggregate.pdf`

* **Figure 2b: ACC**:
    * Result: `./temp/accturbo/acc_original/slowgrow_acc`
    * Plots: 
        * `./projects/accturbo/analysis/acc_original/slowgrow_acc/output_aggregate.pdf`
        * `./projects/accturbo/analysis/acc_original/slowgrow_acc/droprate_aggregate.pdf`

* **Figure 2c: ACC: Impact of K**:
    * Result: `./temp/accturbo/acc_reactiontime`
    * Plots: 
        * `./projects/accturbo/analysis/acc_reactiontime/output_aggregate.pdf`
        * `./projects/accturbo/analysis/acc_reactiontime/droprate_aggregate.pdf`

* **Figure 2d: ACC-Turbo**:
    * Result: `./temp/accturbo/acc_original/slowgrow_accturbo`
    * Plots: 
        * `./projects/accturbo/analysis/acc_original/slowgrow_accturbo/output_aggregate.pdf`
        * `./projects/accturbo/analysis/acc_original/slowgrow_accturbo/droprate_aggregate.pdf`

**Figure 3: Performance under morphing attack**: 

* Run `./run_fig_3.sh`. 
* Result in `./temp/sppifo/sppifo_analysis`.
* Plots in `./projects/sppifo/plots/sppifo_analysis/`.

---

## Simulation-based Evaluation

* **Figure 9: Performance by attack type and features**: 

    * Run `./run_fig_9.sh`. 
    * Result in `./temp/sppifo/sppifo_analysis`.
    * Plots in `./projects/sppifo/plots/sppifo_analysis/`.

* **Figure 10: Performance of clustering strategies**: 

    * Run `./run_fig_10.sh`. 
    * Result in `./temp/sppifo/sppifo_analysis`.
    * Plots in `./projects/sppifo/plots/sppifo_analysis/`.

* **Figure 11: Impact of scheduling for mitigation**: 

    * Run `./run_fig_11.sh`. 
    * Result in `./temp/sppifo/sppifo_analysis`.
    * Plots in `./projects/sppifo/plots/sppifo_analysis/`.

---