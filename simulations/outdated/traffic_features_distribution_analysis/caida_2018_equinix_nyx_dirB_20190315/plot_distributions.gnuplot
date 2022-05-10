load '../spectral.pal'

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,14" size 4.3in,2.5in

set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9

########################################################################################################################
# IP Length
########################################################################################################################
set xlabel 'IP Length values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:65536]
# set yrange [0:60000]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'caida_2018_equinix_results/ip_len_distrib.pdf'
plot "caida_2018_equinix_results/ip_len_distrib.dat" using 2 title "IP Length" ls 1 lw 4

########################################################################################################################
# IP Identification
########################################################################################################################
set xlabel 'IP Identification values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:65536]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'caida_2018_equinix_results/ip_id_distrib.pdf'
plot "caida_2018_equinix_results/ip_id_distrib.dat" using 2 title "IP Identification" w l ls 1 lw 4

########################################################################################################################
# IP Frag. Offset
########################################################################################################################
set xlabel 'IP Frag. Offset values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:8192]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'caida_2018_equinix_results/ip_frag_offset_distrib.pdf'
plot "caida_2018_equinix_results/ip_frag_offset_distrib.dat" using 2 title "IP Frag. Offset" w l ls 1 lw 4

########################################################################################################################
# IP Time To Live
########################################################################################################################
set xlabel 'IP Time To Live values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:256]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'caida_2018_equinix_results/ip_ttl_distrib.pdf'
plot "caida_2018_equinix_results/ip_ttl_distrib.dat" using 2 title "IP Time To Live" w l ls 1 lw 4

########################################################################################################################
# IP Protocol
########################################################################################################################
set xlabel 'IP Protocol values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:256]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'caida_2018_equinix_results/ip_proto_distrib.pdf'
plot "caida_2018_equinix_results/ip_proto_distrib.dat" using 2 title "IP Protocol" w l ls 1 lw 4

########################################################################################################################
# IP Source Address
########################################################################################################################
set xlabel 'IP Source Address values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:256]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'caida_2018_equinix_results/ip_src.pdf'
plot "caida_2018_equinix_results/ip_src.dat" using 2 title "IP Source Address 0" w l ls 1 lw 4, \
                      '' using 3 title "IP Source Address 1" w l ls 2 lw 4, \
                      '' using 4 title "IP Source Address 2" w l ls 3 lw 4, \
                      '' using 5 title "IP Source Address 3" w l ls 4 lw 4

########################################################################################################################
# IP Destination Address
########################################################################################################################
set xlabel 'IP Destination Address values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:256]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'caida_2018_equinix_results/ip_dst.pdf'
plot "caida_2018_equinix_results/ip_dst.dat" using 2 title "IP Destination Address 0" w l ls 1 lw 4, \
                      '' using 3 title "IP Destination Address 1" w l ls 2 lw 4, \
                      '' using 4 title "IP Destination Address 2" w l ls 3 lw 4, \
                      '' using 5 title "IP Destination Address 3" w l ls 4 lw 4

########################################################################################################################
# Transport Source-Destination Ports
########################################################################################################################
set xlabel 'Transport Ports values' tc ls 11
set ylabel 'Number of packets forwarded' tc ls 11
set xrange [0:65536]
# set yrange [0:100]
# set xtics ("0" 0, "10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)

set output 'caida_2018_equinix_results/t_ports.pdf'
plot "caida_2018_equinix_results/t_ports.dat" using 3 title "Destination Port" w l ls 2 lw 4, \
            '' using 2 title "Source Port" w l ls 1 lw 4

            