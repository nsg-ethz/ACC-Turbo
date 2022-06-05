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
set term pdfcairo enhanced font "Helvetica,19" size 3.8in,2in
set key font "Helvetica,18" 

###################
# Scheduler performance
###################

set xtics rotate by 0
set xlabel "Attack Vectors"
set xtics ("MSSQL" 0, "SSDP" 1)
set xrange [-0.5:1.5]

# Y-Axis: Purity
set boxwidth 0.5
set ylabel "Score (%)"
set xtics out offset 0,0
set yrange [0:1]
set ytics ("0" 0, "50" 0.5, "100" 1)
set output "python/plots/ranking_algorithms/ranking_algorithms.pdf"
plot "python/plots/ranking_algorithms/ranking_algorithms.dat" using 2 title 'N.P.' ls 8 lw 3, \
                '' using 3 title 'Th.' ls 4 lw 3, \
                '' using 4 title 'N.P./Size' ls 3 lw 3, \
                '' using 5 title 'Th./Size' ls 2 lw 3