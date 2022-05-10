load "~/albert/ddos-aid/simulations/python/palette/spectral.pal"

set terminal pdfcairo

set key out horiz top
set term pdfcairo enhanced font "Helvetica,20" size 4in,2.5in

set xlabel "Prioritized-traffic rate (Gbps)"
#set xrange [0:100]
#set xtics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set xtics rotate by 33
#set xtics out offset -1.25,-0.75
#set key opaque

set yrange [0:100]
set ytics ("0" 0, "25" 25, "50" 50, "75" 75, "100" 100)
set ylabel font "Helvetica,18" 
set ylabel "% Deprioritized-traffic dropped" offset 0,-1
set output "analysis/flashcrowd.pdf"

plot "analysis/flashcrowd.dat" using 2:xtic(1) title "Priority Queues" w lp ls 22 lw 4, \
''  using 3:xtic(1) title "FIFO" w lp ls 28 lw 4, \