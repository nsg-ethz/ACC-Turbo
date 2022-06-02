load "palette/spectral.pal"

set terminal pdfcairo

set key out horiz top
set term pdfcairo enhanced font "Helvetica,20" size 4in,2.5in

set xlabel "Time (s)"
set xrange [0:100]

#set key opaque
set datafile separator ","

# In-Out Throughput
set yrange [0:10000]
set ytics ("0" 0, "2" 2000, "4" 4000, "6" 6000, "8" 8000, "10" 10000)
set key font "Helvetica,17" 
set ylabel "Throughput (Gbps)"
set output "run_fig_06a/results/fifo_in_out_plot.pdf"

plot "run_fig_06a/results/fifo_throughput_malicious.dat" using 5 title "Output Attack" w l ls 1 lw 4, \
     "run_fig_06a/results/fifo_throughput_benign.dat" using 5 title "Output Benign" w l ls 7 lw 4