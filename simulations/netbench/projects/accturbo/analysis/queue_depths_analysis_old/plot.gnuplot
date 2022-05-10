load "netbench_ddos/projects/ddos-aid/analysis/spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,16" size 4in,2.5in

set datafile separator ","
set key opaque

set xlabel "Queue Depths"
set xtics ("50" 0, "100" 1, "250" 2, "500" 3)

set ylabel "% Benign Packets Dropped"
set yrange [0:50]
set output "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/percentage_benign_plot.pdf"

plot "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/drop_percentage_benign_Fifo.dat" using 2 title "FIFO" w lp  ls 28 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/drop_percentage_benign_Pifo.dat" using 2 title "PIFO"  w lp ls 27 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/drop_percentage_benign_PifoGT.dat" using 2 title "PIFO GT"  w lp ls 1 lw 4 dt 2

unset key
set ylabel "% Malicious Packets Dropped  "
set yrange [50:100]
set output "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/percentage_malicious_plot.pdf"

plot "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/drop_percentage_malicious_Fifo.dat" using 2 title "FIFO" w lp  ls 28 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/drop_percentage_malicious_PifoGT.dat" using 2 title "PIFO"  w lp ls 27 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/drop_percentage_malicious_PifoGT.dat" using 2 title "PIFO GT"  w lp ls 1 lw 4 dt 2

set ylabel "Total Packets Dropped"
unset yrange
set output "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/total_dropped_plot.pdf"

plot "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/total_drops_Fifo.dat" using 2 title "FIFO" w lp  ls 28 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/total_drops_Pifo.dat" using 2 title "PIFO"  w lp ls 27 lw 4, \
     "netbench_ddos/projects/ddos-aid/analysis/queue_depths_analysis/total_drops_PifoGT.dat" using 2 title "PIFO GT"  w lp ls 1 lw 4 dt 2