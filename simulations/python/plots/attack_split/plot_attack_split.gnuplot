load "python/plots/spectral.pal"

# General configuration
set terminal pdfcairo

# Histogram configuration
set boxwidth 0.8
set style data histogram
set style histogram
set style fill solid 0.6
set bars front

set key out horiz top
set style histogram
set term pdfcairo enhanced font "Helvetica,20" size 4.2in,2.5in
set key font "Helvetica,16"

###################
# Attack vectors
###################

# X-Axis
set xlabel "Attack Vectors"
set xtics ("NTP" 0, "DNS" 1, "MSSQL" 2, "NetBIOS" 3, "SNMP" 4, "SSDP" 5, "TFTP" 6, "UDP" 7, "UDPLag" 8)
set xrange [-0.5:8.5]

# Y-Axis: Purity
set boxwidth 2
set ylabel "Purity (%)"
set xtics rotate by 33
set xtics out offset -1.25,-1.25
set yrange [50:100]
set ytics ("50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)
set output "python/plots/attack_split/attack_split.pdf"
plot "python/plots/attack_split/attack_split.dat" using 2 title 'Reflection-based' ls 8 lw 3, \
                       '' using 3 title 'Exploitation-based' ls 2 lw 3