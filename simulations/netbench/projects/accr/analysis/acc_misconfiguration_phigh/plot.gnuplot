load "../python/palette/spectral.pal"

set terminal pdfcairo

set key out horiz top
set term pdfcairo enhanced font "Helvetica,16" size 4.2in,2.5in

#set yrange [0:50000000000]
#set ytics ("0" 0, "2" 2, "4" 4, "6" 6, "8" 8)

set key font "Helvetica,14"
set datafile separator ","

set xlabel "Time (s)"
set xrange [0:50000000000]
set xtics ("0" 0, "5" 5000000000, "10" 10000000000, "15" 15000000000, "20" 20000000000, "25" 25000000000, "30" 30000000000, "35" 35000000000, "40" 40000000000, "45" 45000000000, "50" 50000000000)

set ylabel "Fraction of Link Bandwidth"
set yrange [0:1.1]
set ytics ("0" 0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1" 1)
set output "projects/accr/analysis/acc_misconfiguration_phigh/output.pdf"
plot "projects/accr/analysis/acc_misconfiguration_phigh/phigh01/aggregate_output_throughput.dat" using 1:6 title "p_{high}=0.1" w l ls 1 lw 4 dashtype "-", \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh02/aggregate_output_throughput.dat" using 1:6 title "p_{high}=0.2" w l ls 2 lw 4, \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh03/aggregate_output_throughput.dat" using 1:6 title "p_{high}=0.3" w l ls 3 lw 4, \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh04/aggregate_output_throughput.dat" using 1:6 title "p_{high}=0.4" w l ls 4 lw 4, \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh05/aggregate_output_throughput.dat" using 1:6 title "p_{high}=0.5" w l ls 7 lw 4, \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh06/aggregate_output_throughput.dat" using 1:6 title "p_{high}=0.6" w l ls 8 lw 4


set ylabel "Drop Rate"
set term pdfcairo enhanced font "Helvetica,16" size 4.2in,1.7in
set yrange [-0.1:1]
set ytics ("0" 0, "0.2" 0.2, "0.4" 0.4, "0.6" 0.6, "0.8" 0.8, "1" 1)
set output "projects/accr/analysis/acc_misconfiguration_phigh/droprate.pdf"
plot "projects/accr/analysis/acc_misconfiguration_phigh/phigh01/aggregate_droprate.dat" using 1:2 title "p_{high}=0.1" w l ls 1 lw 4 dashtype "-", \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh02/aggregate_droprate.dat" using 1:2 title "p_{high}=0.2" w l ls 2 lw 4, \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh03/aggregate_droprate.dat" using 1:2 title "p_{high}=0.3" w l ls 3 lw 4, \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh04/aggregate_droprate.dat" using 1:2 title "p_{high}=0.4" w l ls 4 lw 4, \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh05/aggregate_droprate.dat" using 1:2 title "p_{high}=0.5" w l ls 7 lw 4, \
"projects/accr/analysis/acc_misconfiguration_phigh/phigh06/aggregate_droprate.dat" using 1:2 title "p_{high}=0.6" w l ls 8 lw 4

