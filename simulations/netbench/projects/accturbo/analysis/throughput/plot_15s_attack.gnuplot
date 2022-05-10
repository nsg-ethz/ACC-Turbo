load "netbench_ddos/projects/ddos-aid/analysis/spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in

set xlabel "Time (s)"

#set key opaque
set datafile separator ","
set xtics font "Helvetica,10"

# Input Throughput
set ylabel "Input Throughput (Gbps)"
set output path."input_throughput_plot.pdf"

plot path."input_throughput_malicious.dat" using 1:2 title "Malicious" w l ls 2 lw 2, \
     path."input_throughput_benign.dat" using 1:2 title "Benign" w l ls 6 lw 2 

# Output Throughput
set ylabel "Output Throughput (Gbps)"
set output path."output_throughput_plot.pdf"

plot path."output_throughput_malicious.dat" using 1:2 title "Malicious" w l ls 2 lw 2, \
     path."output_throughput_benign.dat" using 1:2 title "Benign" w l ls 6 lw 2

# Packet Drops
set ylabel "Dropped Packets"
set output path."packet_drops_plot.pdf"

plot path."packet_drops_malicious.dat" using 1:2 title "Malicious" w l ls 2 lw 2, \
     path."packet_drops_benign.dat" using 1:2 title "Benign" w l ls 6 lw 2