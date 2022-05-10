load "spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in

set output "throughput.pdf"
set xlabel "Time (s)"
set ylabel "Throughput (bps)"
#set key opaque
set datafile separator ","

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M"
set xrange ["2018-12-01 08:00:00.0":"2018-12-01 17:00:00.0"]
set xtics font "Helvetica,10" 

#set ytics ("0" 0, "10" 10000, "20" 20000, "30" 30000, "40" 40000, "50" 50000, "60" 60000, "70" 70000)

#plot "throughput.dat" using 1:2 title "Throughput" w l ls 2 lw 2

set output "aggregated_throughputUDP.pdf"
plot "aggregated_throughputUDP.dat" using 1:2 title "Throughput UDP" w l ls 2 lw 2

set output "aggregated_throughputTCP.pdf"
plot "aggregated_throughputTCP.dat" using 1:2 title "Throughput TCP" w l ls 2 lw 2

set output "aggregated_throughputDNS.pdf"
plot "aggregated_throughputDNS.dat" using 1:2 title "Throughput DNS" w l ls 2 lw 2

set output "aggregated_throughputNTP.pdf"
plot "aggregated_throughputNTP.dat" using 1:2 title "Throughput NTP" w l ls 2 lw 2

set output "aggregated_throughputHTTP.pdf"
plot "aggregated_throughputHTTP.dat" using 1:2 title "Throughput HTTP" w l ls 2 lw 2

set output "aggregated_throughputSYN.pdf"
plot "aggregated_throughputSYN.dat" using 1:2 title "Throughput SYN" w l ls 2 lw 2
