load "python/palette/spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in

set xlabel "Time (s)"
set ylabel "Throughput (Gbps)"
set datafile separator ","
set xtics font "Helvetica,10" 

set output output_file
plot attack_file using 1:2 title "Baseline with attack" w l ls 2 lw 4 , \
     baseline_file using 1:2 title "Baseline" w l ls 6 lw 4
     