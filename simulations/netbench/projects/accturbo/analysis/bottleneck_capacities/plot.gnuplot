load "../python/plots/spectral.pal"

set terminal pdfcairo
#set term pdfcairo enhanced font "Helvetica,16" size 4in,2.5in

set key out horiz top
set term pdfcairo enhanced font "Helvetica,19" size 4.3in,3.1in
set key font "Helvetica,17" 


set datafile separator ","
#set key opaque
#set key top left
set xlabel "Bottleneck capacities (Gbps)"
set xtics ("0.05" 0, "0.02" 1, "0.01" 2, "0.005" 3, "0.001" 4)

set ylabel "% Benign Packets Dropped"
set yrange [0:100]
set output "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/percentage_benign_plot.pdf"

plot "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_benign_Fifo.dat" using 2 title "FIFO" w lp  ls 28 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_benign_PifoGT.dat" using 2 title "PIFO Ideal"  w lp ls 1 lw 4 dt 2, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_benign_PifoAnimeFast.dat" using 2 title "An. Fast Th."  w lp ls 25 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_benign_PifoManhattanFast.dat" using 2 title "* Manh. Fast Th."  w lp ls 24 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_benign_PifoManhattanFastThroughputSize.dat" using 2 title "* Manh. F. Th./S."  w lp ls 23 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_benign_PifoManhattanExhaustive.dat" using 2 title "Manh. Exh.Th."  w lp ls 27 lw 4


set ylabel "% Malicious Packets Dropped  "
set yrange [50:100]
set output "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/percentage_malicious_plot.pdf"

plot "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_malicious_Fifo.dat" using 2 title "FIFO" w lp  ls 28 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_malicious_PifoGT.dat" using 2 title "PIFO Ideal"  w lp ls 1 lw 4 dt 2, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_malicious_PifoAnimeFast.dat" using 2 title "An. Fast Th."  w lp ls 25 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_malicious_PifoManhattanFast.dat" using 2 title "* Manh. Fast Th."  w lp ls 24 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_malicious_PifoManhattanFastThroughputSize.dat" using 2 title "* Manh. F. Th./S."  w lp ls 23 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/drop_percentage_malicious_PifoManhattanExhaustive.dat" using 2 title "Manh. Exh.Th."  w lp ls 27 lw 4


set ylabel "Total Packets Dropped"
unset yrange
set output "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/total_dropped_plot.pdf"

plot "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/total_drops_Fifo.dat" using 2 title "FIFO" w lp  ls 28 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/total_drops_PifoManhattanFast.dat" using 2 title "PIFO M.F.T."  w lp ls 26 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/total_drops_PifoManhattanExhaustive.dat" using 2 title "PIFO M.E.T."  w lp ls 26 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/total_drops_PifoAnimeFast.dat" using 2 title "PIFO A.F.T."  w lp ls 27 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/bottleneck_capacities_analysis/total_drops_PifoGT.dat" using 2 title "PIFO GT"  w lp ls 1 lw 4 dt 2