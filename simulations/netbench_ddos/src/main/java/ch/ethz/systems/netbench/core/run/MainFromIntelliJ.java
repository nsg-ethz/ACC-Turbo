package ch.ethz.systems.netbench.core.run;

public class MainFromIntelliJ {


    public static void main(String args[]) {

            MainFromProperties.main(new String[]{"projects/ddos-aid/runs/test.properties"});
            //MainFromProperties.runCommand("python3 projects/ddos-aid/analysis/analyze.py", true);
            //MainFromProperties.runCommand("gnuplot projects/ddos-aid/analysis/input_throughput_plot.gnuplot", true);

        //MainFromProperties.runCommand("python3 projects/ddos-aid/analysis/ground_truth/ground_truth.py", true);
        //MainFromProperties.runCommand("gnuplot projects/ddos-aid/analysis/ground_truth/input_throughput_plot.gnuplot", true);

    }

}
