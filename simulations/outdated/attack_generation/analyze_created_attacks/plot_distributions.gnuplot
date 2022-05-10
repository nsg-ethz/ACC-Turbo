load '../spectral.pal'

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,14" size 4.3in,2.5in

set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9
set key left top

########################################################################################################################
# Source Ports
########################################################################################################################
set xlabel 'Source Port values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:65536]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'generated_distributions.pdf'
plot "generated_distributions.dat" using 2 title "Benign" w l ls 6 lw 4, \
            '' using 3 title "Attack" w l ls 2 lw 4