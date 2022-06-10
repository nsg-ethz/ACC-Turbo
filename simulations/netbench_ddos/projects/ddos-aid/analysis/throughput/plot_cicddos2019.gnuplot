load "netbench_ddos/projects/ddos-aid/analysis/spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in

set xlabel "Time (s)"

#set key opaque
set datafile separator ","

set xrange[0:21.6e12]
set xtics ("0h" 0, "1h" 3.6e12, "2h" 7.2e12, "3h" 10.8e12, "4h" 14.4e12, "5h" 18e12, "6h" 21.6e12)
set xtics font "Helvetica,10"


# Input Throughput
set ylabel "Input Throughput (bps)"
set output path."input_throughput_plot.pdf"

plot path."input_throughput_malicious.dat" using 1:2 title "Malicious" w l ls 2 lw 2, \
     path."input_throughput_benign.dat" using 1:2 title "Benign" w l ls 6 lw 2
     

# Output Throughput
set ylabel "Output Throughput (bps)"
set output path."output_throughput_plot.pdf"

plot path."output_throughput_malicious.dat" using 1:2 title "Malicious" w l ls 2 lw 2, \
     path."output_throughput_benign.dat" using 1:2 title "Benign" w l ls 6 lw 2

# Packet Drops
set ylabel "Dropped Packets"
set output path."packet_drops_plot.pdf"

plot path."packet_drops_malicious.dat" using 1:2 title "Malicious" w l ls 2 lw 2, \
     path."packet_drops_benign.dat" using 1:2 title "Benign" w l ls 6 lw 2
     