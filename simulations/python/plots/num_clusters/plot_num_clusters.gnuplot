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
# Num clusters
###################

# X-Axis
set xlabel "Num Clusters"
set xtics ("2" 0, "4" 1, "6" 2, "8" 3, "10" 4)

set xrange [-0.5:4.5]

# Y-Axis: Purity
set ylabel "Purity (%)"
set yrange [50:100]
set ytics ("50" 50, "75" 75, "100" 100)
set output "python/plots/num_clusters/numclusters_purity.pdf"
plot "python/plots/num_clusters/numclusters_purity.dat" using 2 title "Anime Exh." ls 8 lw 3, \
        '' using 3 title "Manh. Exh." ls 7 lw 3, \
        '' using 4 title "Eucl. Exh." ls 6 lw 3, \
        '' using 5 title "Anime Fast" ls 5 lw 3, \
        '' using 6 title "* Manh. Fast" ls 4 lw 3, \
        '' using 7 title "Eucl. Fast" ls 3 lw 3, \
        '' using 8 title "Eucl. Fast In." ls 2 lw 3, \
        '' using 9 title "Off. KMeans" ls 1 lw 3

# Y-Axis: Recall Benign
set ylabel "Recall Benign (%)"
set yrange [50:100]
set ytics ("50" 50, "75" 75, "100" 100)
set output "python/plots/num_clusters/numclusters_recall_benign.pdf"
plot "python/plots/num_clusters/numclusters_recall_benign.dat" using 2 title "Anime Exh." ls 8 lw 3, \
        '' using 3 title "Manh. Exh." ls 7 lw 3, \
        '' using 4 title "Eucl. Exh." ls 6 lw 3, \
        '' using 5 title "Anime Fast" ls 5 lw 3, \
        '' using 6 title "* Manh. Fast" ls 4 lw 3, \
        '' using 7 title "Eucl. Fast" ls 3 lw 3, \
        '' using 8 title "Eucl. Fast In." ls 2 lw 3, \
        '' using 9 title "Off. KMeans" ls 1 lw 3