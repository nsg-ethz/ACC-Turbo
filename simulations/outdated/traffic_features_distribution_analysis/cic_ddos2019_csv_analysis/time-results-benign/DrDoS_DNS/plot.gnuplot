load "spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in


# Common configuration
set xlabel "Time (s)"
set datafile separator ","
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M"
set xtics font "Helvetica,10"
#set xrange ["2018-12-01 08:00:00.0":"2018-12-01 17:00:00.0"]

# Source port vs. time
set ylabel "Source port"
set output "time_sport.pdf"
plot "time_sport.dat" using 1:2 title "Source port" w l ls 2 lw 2

# Destination port vs. time
set ylabel "Destination port"
set output "time_dport.pdf"
plot "time_dport.dat" using 1:2 title "Destination port" w l ls 2 lw 2

# Protocol vs. time
set ylabel "Protocol identifier"
set output "time_proto.pdf"
plot "time_proto.dat" using 1:2 title "Protocol identifier" w l ls 2 lw 2

# Source address vs. time
set ylabel "Source address"
set output "time_saddr0.pdf"
plot "time_saddr0.dat" using 1:2 title "First byte" w l ls 2 lw 2

set ylabel "Source address"
set output "time_saddr1.pdf"
plot "time_saddr1.dat" using 1:2 title "Second byte" w l ls 3 lw 2

set ylabel "Source address"
set output "time_saddr2.pdf"
plot "time_saddr2.dat" using 1:2 title "Third byte" w l ls 4 lw 2

set ylabel "Source address"
set output "time_saddr3.pdf"
plot "time_saddr3.dat" using 1:2 title "Fourth byte" w l ls 6 lw 2 

# Destination address vs. time
set ylabel "Destination address"
set output "time_daddr0.pdf"
plot "time_daddr0.dat" using 1:2 title "First byte" w l ls 2 lw 2

set ylabel "Destination address"
set output "time_daddr1.pdf"
plot "time_daddr1.dat" using 1:2 title "Second byte" w l ls 3 lw 2

set ylabel "Destination address"
set output "time_daddr2.pdf"
plot "time_daddr2.dat" using 1:2 title "Third byte" w l ls 4 lw 2

set ylabel "Destination address"
set output "time_daddr3.pdf"
plot "time_daddr3.dat" using 1:2 title "Fourth byte" w l ls 6 lw 2 

# Max_packet_length vs. time
set ylabel "Max. packet length"
set output "time_max_packet_length.pdf"
plot "time_max_packet_length.dat" using 1:2 title "Max. packet length" w l ls 2 lw 2

# Min_packet_length vs. time
set ylabel "Min. packet length"
set output "time_min_packet_length.pdf"
plot "time_min_packet_length.dat" using 1:2 title "Min. packet length" w l ls 2 lw 2