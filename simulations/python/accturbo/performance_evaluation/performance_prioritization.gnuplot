load "python/palette/spectral.pal"

# General configuration
set terminal pdfcairo

# Histogram configuration
set boxwidth 0.8
set style data histogram
set style histogram
set style fill solid 0.6
set bars front

###################
# Num clusters
###################

set key out horiz top
set style histogram
set term pdfcairo enhanced font "Helvetica,16" size 4.2in,2.5in

# X-Axis
set xlabel "Num Clusters"
set xtics ("2" 0, "4" 1, "6" 2, "8" 3, "10" 4)
set xrange [-0.5:4.5]

# Y-Axis: Score
set ylabel "Score (%)"
set yrange [0:1]
set ytics ("0" 0, "1" 1)
set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_numclusters_score.pdf"
plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_numclusters_score.dat" using 2 title "Anime Range Exh." ls 8 lw 3, \
        '' using 3 title "Manh. Range Exh." ls 7 lw 3, \
        '' using 4 title "Center Exh." ls 4 lw 3, \
        '' using 5 title "Anime Range Fast" ls 3 lw 3, \
        '' using 6 title "Manh. Range Fast" ls 2 lw 3, \
        '' using 7 title "Center Fast" ls 1 lw 3

###################
# Extended Num clusters
###################

set key out horiz top
set style histogram
set term pdfcairo enhanced font "Helvetica,14" size 4.2in,2.5in

# X-Axis
set xlabel "Num Clusters"
set xtics ("2" 0, "4" 1, "6" 2, "8" 3, "10" 4)
set xrange [-0.5:4.5]

# Y-Axis: Score
set ylabel "Score (%)"
set yrange [0:1]
set ytics ("0" 0, "1" 1)
set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_score.pdf"
plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_score.dat" using 3 title "Anime Range Exh." ls 8 lw 3, \
        '' using 5 title "Center Exh." ls 7 lw 3, \
        '' using 8 title "Center Exh. Init." ls 6 lw 3, \
        '' using 4 title "Anime Range Fast" ls 5 lw 3, \
        '' using 6 title "Center Fast" ls 4 lw 3, \
        '' using 7 title "Center Fast Init." ls 3 lw 3, \
        '' using 2 title "Random" ls 2 lw 3, \
        '' using 9 title "Offline K-Means" ls 1 lw 3