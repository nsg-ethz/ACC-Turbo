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

set key out horiz top right
set key font "Helvetica,17" 

set output dst."benign_10.pdf"
plot src."dst3_distrib_histogram_benign_8.dat" using 2 title "P1" ls 1 lw 4, \
            '' using 3 title "P2" ls 2 lw 4, \
            '' using 4 title "P3" ls 3 lw 4, \
            '' using 5 title "P4" ls 4 lw 4, \
            '' using 6 title "P5" ls 5 lw 4, \
            '' using 7 title "P6" ls 6 lw 4, \
            '' using 8 title "P7" ls 31 lw 4, \
            '' using 9 title "P8" ls 33 lw 4, \
            '' using 10 title "P9" ls 7 lw 4, \
            '' using 11 title "P10" ls 8 lw 4

set yrange [0:1200000]
set ytics ("0" 0, "400" 400000, "800" 800000, "1200" 1200000)
set output dst."malicious_10.pdf"

plot src."dst3_distrib_histogram_malicious_8.dat" using 2 title "P1" ls 1 lw 4, \
            '' using 3 title "P2" ls 2 lw 4, \
            '' using 4 title "P3" ls 3 lw 4, \
            '' using 5 title "P4" ls 4 lw 4, \
            '' using 6 title "P5" ls 5 lw 4, \
            '' using 7 title "P6" ls 6 lw 4, \
            '' using 8 title "P7" ls 31 lw 4, \
            '' using 9 title "P8" ls 33 lw 4, \
            '' using 10 title "P9" ls 7 lw 4, \
            '' using 11 title "P10" ls 8 lw 4
