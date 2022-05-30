load "palette/spectral.pal"

set terminal pdfcairo

set key out horiz top
set term pdfcairo enhanced font "Helvetica,20" size 4in,2.5in

set xlabel "Time (s)"
set xrange [0:100]
set xtics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)

#set key opaque
set datafile separator ","

# In-Out Throughput
set yrange [0:10e9]
set ytics ("0" 0, "2" 2e9, "4" 4e9, "6" 6e9, "8" 8e9, "10" 10e9)
set key font "Helvetica,17" 
set ylabel "Throughput (Gbps)"
set output "run_fig_07d/results/jaqen_output_throughput.pdf"

plot "run_fig_07d/results/jaqen_throughput_malicious.dat" using 1:2 title "Output Attack" w l ls 1 lw 4, \
     "run_fig_07d/results/jaqen_throughput_benign.dat" using 1:2 title "Output Benign" w l ls 7 lw 4