load '../spectral.pal'

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,14" size 4.3in,2.5in

set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9

########################################################################################################################
# IP Source Address
########################################################################################################################
set xlabel 'IP Source Address values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:256]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'ip_src.pdf'
plot "ip_src.dat" using 2 title "IP Source Address 0" w l ls 1 lw 4, \
                      '' using 3 title "IP Source Address 1" w l ls 2 lw 4, \
                      '' using 4 title "IP Source Address 2" w l ls 3 lw 4, \
                      '' using 5 title "IP Source Address 3" w l ls 4 lw 4

########################################################################################################################
# Transport Source-Destination Ports
########################################################################################################################
set xlabel 'Transport Ports values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:65536]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 't_ports.pdf'
plot "t_ports.dat" using 2 title "Source Port" w l ls 1 lw 4, \
            '' using 3 title "Destination Port" w l ls 2 lw 4

########################################################################################################################
# Autonomous System Source
########################################################################################################################
set xlabel 'Autonomous System Source values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:65536]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'as_src.pdf'
plot "as_src.dat" using 2 title "Source AS" w l ls 1 lw 4