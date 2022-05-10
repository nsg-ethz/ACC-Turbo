load "../spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,16" size 4in,2.5in

set key opaque
set key off

set xlabel "Mean Benign"
set xtics rotate by 30 offset -3,-1
set ylabel "Mean Attack"

set rmargin 12
set colorbox user origin 0.85,0.2
set cbtic 0.5,0.1,1

set title "% Purity"
set output "sweep_means_purity.pdf"
plot "sweep_means_purity.dat" using 1:2:3 with points palette pointsize 1 pointtype 7