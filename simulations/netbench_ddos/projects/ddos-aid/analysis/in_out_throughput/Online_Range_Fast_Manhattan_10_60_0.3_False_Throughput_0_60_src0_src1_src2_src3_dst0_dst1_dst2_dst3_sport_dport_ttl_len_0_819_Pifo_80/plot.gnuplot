load "~/DDoS-AID_private/code/python/palette/spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,20" size 4in,2.5in

set xlabel "Time (h)"

#set key opaque
set datafile separator ","

set xrange[0:21.6e12]
set xtics ("0h" 0, "1h" 3.6e12, "2h" 7.2e12, "3h" 10.8e12, "4h" 14.4e12, "5h" 18e12, "6h" 21.6e12)

set yrange[0:1000000000]
set ytics ("0" 0, "0.2" 200000000, "0.4" 400000000, "0.6" 600000000, "0.8" 800000000, "1" 1000000000)

# Input Throughput
set ylabel "Input Th. (Gbps)"
set output "input_throughput_plot.pdf"

plot "input_throughput_malicious.dat" using 1:2 title "Attack" w l ls 1 lw 2, \
     "input_throughput_benign.dat" using 1:2 title "Benign" w l ls 7 lw 2

# Packet Drops
set ylabel "Throughput decrease (%)"
set output "throughput_decrease_plot.pdf"

 plot "throughput_decrease_malicious.dat" using 1:2 title "Attack" w l ls 1 lw 2, \
     "throughput_decrease_benign.dat" using 1:2 title "Benign" w l ls 7 lw 2

set ylabel "Dropped Th. (Gbps)"
set output "packet_drops.pdf"

 plot "packet_drops_malicious.dat" using 1:2 title "Attack" w l ls 1 lw 2, \
     "packet_drops_benign.dat" using 1:2 title "Benign" w l ls 7 lw 2

set yrange[0:100000000]
set ytics ("0" 0, "20" 20000000, "40" 40000000, "60" 60000000, "80" 80000000, "100" 100000000)

set key opaque

# Output Throughput
set ylabel "Output Th. (Mbps)"
set output "output_throughput_plot.pdf"

plot "output_throughput_malicious.dat" using 1:2 title "Attack" w l ls 1 lw 2, \
     "output_throughput_benign.dat" using 1:2 title "Benign" w l ls 7 lw 2

