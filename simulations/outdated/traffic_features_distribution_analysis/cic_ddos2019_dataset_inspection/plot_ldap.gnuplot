load "spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in

set xlabel "Time (s)"
set ylabel "Throughput (bps)"

#set key opaque
set datafile separator ","

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M"
set xrange ["2018-12-01 11:10:00.0":"2018-12-01 11:40:00.0"]
set xtics font "Helvetica,10" 

#set ytics ("0" 0, "10" 10000, "20" 20000, "30" 30000, "40" 40000, "50" 50000, "60" 60000, "70" 70000)

set output "ldap_aggregated_throughputUDP.pdf"
plot "aggregated_throughputUDP.dat" using 1:2 title "Throughput UDP" w l ls 2 lw 2

set output "ldap_aggregated_throughputTCP.pdf"
plot "aggregated_throughputTCP.dat" using 1:2 title "Throughput TCP" w l ls 2 lw 2

set output "ldap_aggregated_numpacketsUDP.pdf"
plot "aggregated_numpacketsUDP.dat" using 1:2 title "Numpackets UDP" w l ls 2 lw 2

set output "ldap_aggregated_numpacketsTCP.pdf"
plot "aggregated_numpacketsTCP.dat" using 1:2 title "Numpackets TCP" w l ls 2 lw 2


set output "ldap_aggregated_throughputflow1.pdf"
plot "aggregated_throughputflow1.dat" using 1:2 title "Throughput Flows UDP Src = 695 Dst = 5910" w l ls 2 lw 2

set output "ldap_aggregated_throughputflow2.pdf"
plot "aggregated_throughputflow2.dat" using 1:2 title "Throughput Flows UDP Src = 695 Dst = 61435" w l ls 2 lw 2

set output "ldap_aggregated_throughputflow3.pdf"
plot "aggregated_throughputflow3.dat" using 1:2 title "Throughput Flows UDP Src = 695 Dst = 33087" w l ls 2 lw 2

set output "ldap_aggregated_throughputflow4.pdf"
plot "aggregated_throughputflow4.dat" using 1:2 title "Throughput Flows UDP Src = 695 Dst = 1097" w l ls 2 lw 2

