load "../../spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,16" size 4in,2.5in

set key opaque

set xrange [0:120]
set xlabel "Iteration Number"

set yrange [50:150]
set ylabel "Purity (%)"

set output "purities.pdf"
plot "purities.dat" using 1 title "Theoretical" w l ls 2 lw 8, \
            ''      using 2 title "K-Means" w l ls 8 lw 8 dashtype 2