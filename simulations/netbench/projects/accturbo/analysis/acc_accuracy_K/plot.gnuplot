load "../python/plots/spectral.pal"

set terminal pdfcairo
set datafile separator ","

#set key out horiz top
set term pdfcairo enhanced font "Helvetica,16" size 4.2in,2.5in

set ylabel "% Benign Drops"
set yrange [0:100]

set xlabel "K (seconds)"
set xtics ("0.01" 0, "0.025" 1, "0.05" 2, "0.1" 3, "0.25" 4, "0.5" 5, "1" 6, "1.5" 7, "2" 8)

set output "projects/accturbo/analysis/acc_accuracy_K/benign_drops.pdf"
plot "projects/accturbo/analysis/acc_accuracy_K/benign_drops.dat" using 4 title "ACC-Turbo" w lp ls 27 lw 4, \
'' using 2 title "ACC" w lp ls 28 lw 4, \
'' using 3 title "FIFO" w lp ls 21 lw 4