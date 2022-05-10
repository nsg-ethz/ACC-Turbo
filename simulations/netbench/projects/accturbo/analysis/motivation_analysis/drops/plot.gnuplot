load "netbench_ddos/projects/ddos-aid/analysis/spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,16" size 4in,2.5in

set datafile separator ","
set key opaque
set key off

set xlabel "% True-Positive Rate"
set ylabel "Attack Rate (Gbps)"
set palette negative

set rmargin 10
set colorbox user origin 0.85,0.2

set title "% Total Drops (True-Negative Rate = 1)"
set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_total.pdf"
plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_total.dat" using 2:1:3 with points palette pointsize 1 pointtype 7

set title "% Benign Drops (True-Negative Rate = 1)"
set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_benign.pdf"
plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_benign.dat" using 2:1:3 with points palette pointsize 1 pointtype 7

set title "% Malicious Drops (True-Negative Rate = 1)"
set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_malicious.pdf"
plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tp_drops_malicious.dat" using 2:1:3 with points palette pointsize 1 pointtype 7

set xlabel "% True-Negative Rate"

set title "% Total Drops (True-Positive Rate = 1)"
set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_total.pdf"
plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_total.dat" using 2:1:3 with points palette pointsize 1 pointtype 7

set title "% Benign Drops (True-Positive Rate = 1)"
set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_benign.pdf"
plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_benign.dat" using 2:1:3 with points palette pointsize 1 pointtype 7

set title "% Malicious Drops (True-Positive Rate = 1)"
set output "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_malicious.pdf"
plot "netbench_ddos/projects/ddos-aid/analysis/motivation_analysis/drops/tn_drops_malicious.dat" using 2:1:3 with points palette pointsize 1 pointtype 7
