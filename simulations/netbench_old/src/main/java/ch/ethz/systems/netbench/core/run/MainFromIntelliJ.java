package ch.ethz.systems.netbench.core.run;

public class MainFromIntelliJ {


    public static void main(String args[]) {
        // Slowgrow FIFO
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_original/slowgrow.properties"});
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_original/slowgrow/plot.gnuplot");

        // Slowgrow ACC
        MainFromProperties.main(new String[]{"projects/accr/runs/acc_original/slowgrow_acc.properties"});
        MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_original/slowgrow_acc/plot.gnuplot");

        // Slowgrow ACC-R
        //MainFromProperties.main(new String[]{"projects/accr/runs/acc_original/slowgrow_accr.properties"});
        //MainFromProperties.runCommand("gnuplot projects/accr/analysis/acc_original/slowgrow_accr/plot.gnuplot");
    }
}