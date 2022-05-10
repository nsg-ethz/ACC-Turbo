load "spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in

# Common configuration
set style data histograms
set style fill solid
set datafile separator ","
set grid noxtics 

set xlabel "Top packet sizes (bits)"
set xrange [0:15]
set xtics rotate by -45

set title "Rank 9"
set output "histogram-packet-sizes-9.pdf"
plot "histogram-packet-sizes-9.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 8"
set output "histogram-packet-sizes-8.pdf"
plot "histogram-packet-sizes-8.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 7"
set output "histogram-packet-sizes-7.pdf"
plot "histogram-packet-sizes-7.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 6"
set output "histogram-packet-sizes-6.pdf"
plot "histogram-packet-sizes-6.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 5"
set output "histogram-packet-sizes-5.pdf"
plot "histogram-packet-sizes-5.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 4"
set output "histogram-packet-sizes-4.pdf"
plot "histogram-packet-sizes-4.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 3"
set output "histogram-packet-sizes-3.pdf"
plot "histogram-packet-sizes-3.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 2"
set output "histogram-packet-sizes-2.pdf"
plot "histogram-packet-sizes-2.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 1"
set output "histogram-packet-sizes-1.pdf"
plot "histogram-packet-sizes-1.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"

set title "Rank 0"
set output "histogram-packet-sizes-0.pdf"
plot "histogram-packet-sizes-0.dat" using 2:xtic(1) ls 6 lw 2 title "Number of packets"