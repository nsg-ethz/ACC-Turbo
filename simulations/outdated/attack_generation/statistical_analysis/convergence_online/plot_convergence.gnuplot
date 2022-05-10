load '../../spectral.pal'

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,14" size 4.3in,2.5in

set xlabel 'Packet arrivals' tc ls 11
set ylabel 'Centroid values' tc ls 11
# set xrange [0:800000]
set yrange [10000:40000]
#set xtics ("0" 0, "20k" 20000, "40k" 40000, "60k" 60000, "80k" 80000, "100k" 100000)

set output 'sport_convergence.pdf'
#set xtics ("0" 0, "20k" 20000, "40k" 40000, "60k" 60000, "80k" 80000, "100k" 100000)

unset key

plot "sport_convergence.dat" using 2 title "K-Means offline c0" w l ls 8 lw 5 dashtype 2, \
             '' using 3 title "K-Means offline c1" w l ls 8 lw 5 dashtype 2, \
             '' using 4 title "Range-based-fast online c0" w l ls 2 lw 5, \
             '' using 5 title "Range-based-fast online c1" w l ls 2 lw 5