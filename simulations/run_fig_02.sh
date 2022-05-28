#!/bin/bash

echo -e "Running ACC-Turbo Figure 2 evaluation using run_fig_2.sh"

# Compile
cd netbench
mvn clean compile assembly:single

#/* Figure 2: Comparison between ACC and ACC-Turbo with the original paper's experiment */

    #/* Figure 2a: No ACC */
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_original/slowgrow.properties
    gnuplot projects/accturbo/analysis/acc_original/slowgrow/plot.gnuplot

    #/* Figure 2b: ACC */
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_original/slowgrow_acc.properties
    gnuplot projects/accturbo/analysis/acc_original/slowgrow_acc/plot.gnuplot

    #/* Figure 2c: ACC: Impact of K */
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_reactiontime/K10.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_reactiontime/K15.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_reactiontime/K20.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_reactiontime/K25.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_reactiontime/K30.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_reactiontime/K35.properties
    python3 projects/accturbo/analysis/acc_reactiontime/analyze.py
    gnuplot projects/accturbo/analysis/acc_reactiontime/plot.gnuplot

    #/* Figure 2d: ACC-Turbo */
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_original/slowgrow_accturbo.properties
    gnuplot projects/accturbo/analysis/acc_original/slowgrow_accturbo/plot.gnuplot

