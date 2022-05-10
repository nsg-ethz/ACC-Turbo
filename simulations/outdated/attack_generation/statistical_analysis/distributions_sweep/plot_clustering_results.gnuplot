load '../../spectral.pal'

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,14" size 4.3in,2.5in

unset key
set xlabel 'Source Port values' tc ls 11
set ylabel 'Destination Port values' tc ls 11

set yrange [0:65536]
set xrange [0:65536]

set output 'clustering_results.pdf'

# Benign is pt 7 (circle), Malicious is pt 2 (cross). Cluster 1 is orange (ls 2). Cluster 2 is green (ls 6).
plot "< awk '{if($3 == \"False\" && $4 == \"0\")  print}' clustering_results.dat" using 1:2 w p pt 2 lc rgb '#F46D43', \
     "< awk '{if($3 == \"False\" && $4 == \"1\") print}'  clustering_results.dat" using 1:2 w p pt 2 lc rgb '#ABDDA4', \
     "< awk '{if($3 == \"True\"  && $4 == \"0\") print}'  clustering_results.dat" using 1:2 w p pt 7 lc rgb '#F46D43', \
     "< awk '{if($3 == \"True\"  && $4 == \"1\") print}'  clustering_results.dat" using 1:2 w p pt 7 lc rgb '#ABDDA4', \
    "centroids.dat"                                                               using 1:2 w p pt 1 lc rgb '#000000' lw 4