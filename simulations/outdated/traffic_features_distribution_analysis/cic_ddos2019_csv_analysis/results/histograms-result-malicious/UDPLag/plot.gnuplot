load "spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in

# Common configuration
set style data histograms
set style fill solid
set datafile separator ","
set grid noxtics 
set xtics rotate by -45
#set xrange ["2018-12-01 08:00:00.0":"2018-12-01 17:00:00.0"]

# Source-port histogram
set xlabel "Top 15 ports"
set output "histogram_sport.pdf"
set xrange [0:20]
plot "sport.dat" using 2:xtic(1) ls 2 lw 2 title "Number of flows"

# Destination-port histogram
set xlabel "Top 15 ports"
set output "histogram_dport.pdf"
set xrange [0:20]
plot "dport.dat" using 2:xtic(1) ls 2 lw 2 title "Number of flows"

# Source-address histogram
set xlabel "Top 15 addresses"
set output "histogram_saddr.pdf"
set xrange [0:20]
plot "saddr.dat" using 2:xtic(1) ls 2 lw 2 title "Number of flows"

# Destination-address histogram
set xlabel "Top 15 addresses"
set output "histogram_daddr.pdf"
set xrange [0:20]
plot "daddr.dat" using 2:xtic(1) ls 2 lw 2 title "Number of flows"

# Max-packet-length histogram
set xlabel "Top 15 max. packet lengths"
set output "histogram_max_packet_length.pdf"
set xrange [0:20]
plot "max_packet_length.dat" using 2:xtic(1) ls 2 lw 2 title "Number of flows"

# Protocol histogram
set xlabel "Protocol numbers"
set output "histogram_proto.pdf"
set xrange [0:10]
plot "proto.dat" using 2:xtic(1) ls 2 lw 2 title "Number of flows"