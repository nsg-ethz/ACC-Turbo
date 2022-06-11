load "../palette/spectral.pal"

set terminal pdfcairo

set key out horiz top
set term pdfcairo enhanced font "Helvetica,20" size 4in,2.5in

set xlabel "Bloom filter inter-reset time (s)"
#set xrange [0:100]
#set xtics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set key opaque
set datafile separator ","

set yrange [0:100]
set ytics ("0" 0, "25" 25, "50" 50, "75" 75, "100" 100)
set key font "Helvetica,17" 
set ylabel "Benign-packet drops (%)"
set output "speed.pdf"

plot "speed.dat"using 5:xtic(1) title "ACC-Turbo" w lp ls 27 lw 4, \
 '' using 4:xtic(1) title "FIFO" w lp ls 21 lw 4, \
'' using 2:xtic(1) title "Jaqen Th=10^7 pks" w lp ls 28 lw 4, \
'' using 3:xtic(1) title "Jaqen Th=10^4 pks" w lp ls 28 lw 4 dt 2
