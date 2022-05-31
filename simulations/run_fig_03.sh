#!/bin/bash

echo -e "Running ACC-Turbo Figure 3 evaluation using run_fig_3.sh"

# Compile
cd netbench
mvn clean compile assembly:single

#/* Figure 3: Performance under morphing attack */

    #/* Figure 3a: No ACC */
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_morphing/fifo.properties
    gnuplot projects/accturbo/analysis/acc_morphing/fifo/plot.gnuplot

    #/* Figure 3b: ACC */
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_morphing/acc.properties
    gnuplot projects/accturbo/analysis/acc_morphing/acc/plot.gnuplot

    #/* Figure 3c: Speed vs. accuracy */
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K10.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K25.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K50.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K100.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K250.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K500.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K1000.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K1500.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/K2000.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/accturbo.properties
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_accuracy_K/fifo.properties

    python3 projects/accturbo/analysis/acc_accuracy_K/analyze.py
    gnuplot projects/accturbo/analysis/acc_accuracy_K/plot.gnuplot

    #/* Figure 3d: ACC-Turbo */
    java -jar -ea NetBench.jar projects/accturbo/runs/acc_morphing/accturbo.properties
    gnuplot projects/accturbo/analysis/acc_morphing/accturbo/plot.gnuplot