load "python/palette/spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,20" size 4in,3.2in

set datafile separator ","
set key out horiz top
set key opaque
set ylabel "% Throughput Decrease"

#set palette negative
#set rmargin 10
#set colorbox user origin 0.85,0.2
set xlabel "% True-Positive Rate"

set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_benign.pdf"
plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_benign_10Gbps.dat" using 2:3  title "10 Gbps" w linespoints ls 28, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_benign_8Gbps.dat" using 2:3  title "8 Gbps" w linespoints ls 26, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_benign_6Gbps.dat" using 2:3  title "6 Gbps" w linespoints ls 25, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_benign_4Gbps.dat" using 2:3  title "4 Gbps" w linespoints ls 24, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_benign_2Gbps.dat" using 2:3  title "2 Gbps" w linespoints ls 23, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_benign_0Gbps.dat" using 2:3  title "0 Gbps" w linespoints ls 22

#set xlabel "% Malicious Throughput Decrease"
#set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_malicious.pdf"
#plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tp_throughput_decrease_malicious.dat" using 2:1:3 with points palette pointsize 1 pointtype 7

set xlabel "% True-Negative Rate"
set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_benign.pdf"
plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_benign_10Gbps.dat" using 2:3  title "10 Gbps" w linespoints ls 28, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_benign_8Gbps.dat" using 2:3  title "8 Gbps" w linespoints ls 26, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_benign_6Gbps.dat" using 2:3  title "6 Gbps" w linespoints ls 25, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_benign_4Gbps.dat" using 2:3  title "4 Gbps" w linespoints ls 24, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_benign_2Gbps.dat" using 2:3  title "2 Gbps" w linespoints ls 23, \
    "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_benign_0Gbps.dat" using 2:3  title "0 Gbps" w linespoints ls 22

#set xlabel "% Malicious Throughput Decrease"
#set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_malicious.pdf"
#plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/decrease_throughput/tn_throughput_decrease_malicious.dat" using 2:1:3 with points palette pointsize 1 pointtype 7
