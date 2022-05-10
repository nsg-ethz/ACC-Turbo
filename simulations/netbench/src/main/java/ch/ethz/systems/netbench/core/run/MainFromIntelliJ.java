package ch.ethz.systems.netbench.core.run;

public class MainFromIntelliJ {


    public static void main(String args[]) {
        // Slowgrow FIFO
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_original/slowgrow.properties"});
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_original/slowgrow/plot.gnuplot");

        // Slowgrow ACC
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_original/slowgrow_acc.properties"});
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_original/slowgrow_acc/plot.gnuplot");

        // Slowgrow ACC-R
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_original/slowgrow_accr.properties"});
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_original/slowgrow_accr/plot.gnuplot");

        // ACC Reaction time: Pushback constants are specified at compile time, so you have to change K values from the pushbackconstants file before each simulation
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_reactiontime/K10.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_reactiontime/K15.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_reactiontime/K20.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_reactiontime/K25.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_reactiontime/K30.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_reactiontime/K35.properties"});
        //MainFromProperties.runCommand("python3 projects/accr/analysis/acc_reactiontime/analyze.py");
        MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_reactiontime/plot.gnuplot");

        // ACC Risk of misconfiguration
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration/ptarget01.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration/ptarget02.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration/ptarget03.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration/ptarget04.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration/ptarget05.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration/ptarget06.properties"});
        //MainFromProperties.runCommand("python3 projects/accr/analysis/acc_misconfiguration/analyze.py");
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_misconfiguration_ptarget/plot.gnuplot");

        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration_phigh/phigh01.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration_phigh/phigh02.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration_phigh/phigh03.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration_phigh/phigh04.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration_phigh/phigh05.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_misconfiguration_phigh/phigh06.properties"});
        //MainFromProperties.runCommand("python3 projects/accr/analysis/acc_misconfiguration_phigh/analyze.py");
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_misconfiguration_phigh/plot.gnuplot");

        // ACC Morphing attack
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_morphing/acc.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_morphing/accr.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_morphing/fifo.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_morphing/pifo_gt.properties"});
        //MainFromProperties.runCommand("python3 projects/accr/analysis/acc_morphing/analyze.py");
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_morphing/acc/plot.gnuplot");
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_morphing/accr/plot.gnuplot");
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_morphing/fifo/plot.gnuplot");
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_morphing/pifo_gt/plot.gnuplot");

        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K1.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K25.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K50.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K100.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K250.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K500.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K1000.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K2000.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K3000.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K4000.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/K5000.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/accr.properties"});
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_accuracy_K/fifo.properties"});

        //MainFromProperties.runCommand("python3 projects/accr/analysis/acc_accuracy_K/analyze.py");
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_accuracy_K/plot.gnuplot");
    }
}