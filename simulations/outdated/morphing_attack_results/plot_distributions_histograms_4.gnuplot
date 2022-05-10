load "python/palette/spectral.pal"

set term pdfcairo enhanced font "Helvetica,20" size 4in,2.5in

set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9

set xlabel '3rd Byte Destination Address' tc ls 11
set xrange [0:255]

set ylabel 'Num. packets (·10^3)' tc ls 11
set yrange [0:12000]
set ytics ("0" 0, "4" 4000, "8" 8000, "12" 12000)

set key out horiz top
set key font "Helvetica,17" 

set output dst."benign.pdf"
plot src."dst3_distrib_histogram_benign_9.dat" using 2 title "Priority 1" ls 1 lw 4, \
            '' using 3 title "Priority 2" ls 2 lw 4, \
            '' using 4 title "Priority 3" ls 3 lw 4, \
            '' using 5 title "Priority 4" ls 8 lw 4

set yrange [0:1200000]
set ytics ("0" 0, "400" 400000, "800" 800000, "1200" 1200000)
set output dst."malicious.pdf"

plot src."dst3_distrib_histogram_malicious_9.dat" using 2 title "Priority 1" ls 1 lw 4, \
            '' using 3 title "Priority 2" ls 2 lw 4, \
            '' using 4 title "Priority 3" ls 3 lw 4, \
            '' using 5 title "Priority 4" ls 8 lw 4
