package ch.ethz.systems.netbench.core.run;

public class MainFromIntelliJ {


    public static void main(String args[]) {

        /* Figure 2: Comparison between ACC and ACC-Turbo with the original paper's experiment */

            /* Figure 2a: No ACC */
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_original/slowgrow.properties"});
            //MainFromProperties.runCommand("gnuplot projects/accturbo/analysis/acc_original/slowgrow/plot.gnuplot");

            /* Figure 2b: ACC */
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_original/slowgrow_acc.properties"});
            //MainFromProperties.runCommand("gnuplot projects/accturbo/analysis/acc_original/slowgrow_acc/plot.gnuplot");

            /* Figure 2c: ACC: Impact of K (ACC constants are specified at compile time, so you have to change K values from the ACC constants file before each simulation)*/
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_reactiontime/K10.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_reactiontime/K15.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_reactiontime/K20.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_reactiontime/K25.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_reactiontime/K30.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_reactiontime/K35.properties"});
            //MainFromProperties.runCommand("python3 projects/accturbo/analysis/acc_reactiontime/analyze.py");
            //MainFromProperties.runCommand("gnuplot projects/accturbo/analysis/acc_reactiontime/plot.gnuplot");

            /* Figure 2d: ACC-Turbo */
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_original/slowgrow_accturbo.properties"});
            //MainFromProperties.runCommand("gnuplot projects/accturbo/analysis/acc_original/slowgrow_accturbo/plot.gnuplot");

        /* Figure 3: Performance under morphing attack */

            /* Figure 3a: No ACC */
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_morphing/fifo.properties"});
            //MainFromProperties.runCommand("gnuplot projects/accturbo/analysis/acc_morphing/fifo/plot.gnuplot");

            /* Figure 3b: ACC */
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_morphing/acc.properties"});
            //MainFromProperties.runCommand("gnuplot projects/accturbo/analysis/acc_morphing/acc/plot.gnuplot");

            /* Figure 3c: Speed vs. accuracy */
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/K1.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/K25.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/K50.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/K100.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/K250.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/K500.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/K1000.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/accturbo.properties"});
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_accuracy_K/fifo.properties"});

            //MainFromProperties.runCommand("python3 projects/accturbo/analysis/acc_accuracy_K/analyze.py");
            //MainFromProperties.runCommand("gnuplot projects/accturbo/analysis/acc_accuracy_K/plot.gnuplot");

            /* Figure 3d: ACC-Turbo */
            //MainFromProperties.main(new String[]{"projects/accturbo/runs/acc_morphing/accturbo.properties"});
            //MainFromProperties.runCommand("gnuplot projects/accturbo/analysis/acc_morphing/accturbo/plot.gnuplot");

    }
}