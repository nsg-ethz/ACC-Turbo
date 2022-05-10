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

#set y2range [0:1200000]
#set y2tics ("0" 0, "400" 400000, "800" 800000, "1200" 1200000)
#set ytics nomirror
#set border 11 front ls 11

set key out horiz top
set key font "Helvetica,17" 

set output dst."benign.pdf"
plot src."dst3_distrib_0.dat" using 2 title "Benign (t=0s)" w l ls 7 lw 4

set yrange [0:1200000]
set ytics ("0" 0, "400" 400000, "800" 800000, "1200" 1200000)
set output dst."malicious.pdf"

plot src."dst3_distrib_7.dat" using 3 title "Attack (t=5s)" w l ls 1 lw 4, \
     src."dst3_distrib_17.dat" using 3 title "Attack (t=15s)" w l ls 2 lw 4, \
     src."dst3_distrib_27.dat" using 3 title "Attack (t=25s)" w l ls 3 lw 4 , \
     src."dst3_distrib_37.dat" using 3 title "Attack (t=35s)" w l ls 8 lw 4