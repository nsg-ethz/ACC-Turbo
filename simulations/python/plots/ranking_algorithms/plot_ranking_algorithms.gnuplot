load "python/plots/spectral.pal"

# General configuration
set terminal pdfcairo

# Histogram configuration
set boxwidth 0.8
set style data histogram
set style histogram
set style fill solid 0.6
set bars front

set key out horiz top
set style histogram
set term pdfcairo enhanced font "Helvetica,20" size 4.2in,2.5in
set key font "Helvetica,16"

###################
# Scheduler performance
###################

# X-Axis
#set xlabel "Ranking algorithms"
#set xtics ("Num. Packets" 0, "Throughput" 1, "Num. Packets/Size" 2, "Throughput/Size" 3)
#set xrange [-0.5:3.5]

# Y-Axis: Purity
#set boxwidth 1.5
#set ylabel "Score (%)"
#set xtics rotate by 33
##set xtics out offset -1.25,-1.25
#set yrange [0:100]
#set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set output "schedulers.pdf"
#plot "schedulers.dat" using 2 title 'MSSQL' ls 8 lw 3, \
                       '' using 3 title 'SSDP' ls 2 lw 3
set xtics rotate by 0
set xlabel "Attack Vectors"
set xtics ("MSSQL" 0, "SSDP" 1)
set xrange [-0.5:1.5]
set term pdfcairo enhanced font "Helvetica,19" size 3.8in,2in
set key font "Helvetica,18" 
#set xtics ("NTP" 0, "DNS" 1, "MSSQL" 2, "NetBIOS" 3, "SNMP" 4, "SSDP" 5, "TFTP" 6, "UDP" 7, "UDPLag" 8)
#set xrange [-0.5:8.5]

# Y-Axis: Purity
set boxwidth 0.5
set ylabel "Score (%)"
set xtics out offset 0,0
set yrange [0:100]
set ytics ("0" 0, "50" 50, "100" 100)
set output "schedulers.pdf"
plot "priority_performance_logs.dat" using 2 title 'N.P.' ls 8 lw 3, \
                '' using 3 title 'Th.' ls 4 lw 3, \
                '' using 4 title 'N.P./Size' ls 3 lw 3, \
                '' using 5 title 'Th./Size' ls 2 lw 3