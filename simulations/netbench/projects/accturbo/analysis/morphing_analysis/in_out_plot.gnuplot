load "python/palette/spectral.pal"

set terminal pdfcairo

set key out horiz top
set term pdfcairo enhanced font "Helvetica,20" size 4in,2.5in

set xlabel "Time (s)"

#set key opaque
set datafile separator ","

# In-Out Throughput
set yrange [0:6]
set ytics ("0" 0, "2" 2, "4" 4, "6" 6, "8" 8)
set key font "Helvetica,17" 
set ylabel "Throughput (Gbps)"
set output path."in_out_plot.pdf"

plot path."output_throughput_malicious.dat" using 1:2 title "Output Attack" w l ls 1 lw 4, \
     path."input_throughput_malicious.dat" using 1:2 title "Input Attack" w l ls 1 lw 4 dashtype "_", \
     path."output_throughput_benign.dat" using 1:2 title "Output Benign" w l ls 7 lw 4, \
     path."input_throughput_benign.dat" using 1:2 title "Input Benign" w l ls 7 lw 4 dashtype "_"