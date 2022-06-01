load "~/DDoS-AID/code/python/palette/spectral.pal"

set terminal pdfcairo

set key out horiz top
set term pdfcairo enhanced font "Helvetica,16" size 4.2in,2.5in

set xlabel "Time (s)"
set xrange [0:100]

#set key opaque
set datafile separator ","

# In-Out Throughput
set yrange [0:10000]
set ytics ("0" 0, "2" 2000, "4" 4000, "6" 6000, "8" 8000, "10" 10000)

set ylabel "Throughput (Gbps)"
set output "fifo_in_out_plot.pdf"

#plot path."output_throughput_malicious.dat" using 1:2 title "Output Malicious" w l ls 1 lw 4, \
     path."input_throughput_malicious.dat" using 1:2 title "Input Malicious" w l ls 1 lw 4 dashtype "_", \
     path."output_throughput_benign.dat" using 1:2 title "Output Benign" w l ls 7 lw 4, \
     path."input_throughput_benign.dat" using 1:2 title "Input Benign" w l ls 7 lw 4 dashtype "_"

plot "fifo_throughput_nic_malicious.dat" using 5 title "Output Malicious" w l ls 1 lw 4, \
     "fifo_throughput_nic_benign.dat" using 5 title "Output Benign" w l ls 7 lw 4          
     