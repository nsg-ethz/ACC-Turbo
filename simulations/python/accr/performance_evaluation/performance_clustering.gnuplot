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
set term pdfcairo enhanced font "Helvetica,20" size 4.2in,2.5in
set key font "Helvetica,16"

# X-Axis
set xlabel "Num Clusters"
set xtics ("2" 0, "4" 1, "6" 2, "8" 3, "10" 4)
set xrange [-0.5:4.5]

# Y-Axis: Purity
set ylabel "Purity (%)"
set yrange [50:100]
set ytics ("50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)
set output "python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_purity.pdf"
plot "python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_purity.dat" using 2 title "Anime Range Exh." ls 8 lw 3, \
        '' using 5 title "Anime Range Fast" ls 7 lw 3, \
        '' using 4 title "Repres. Exh." ls 4 lw 3, \
        '' using 7 title "Repres. Fast" ls 3 lw 3, \
        '' using 3 title "Manh. Range Exh." ls 2 lw 3, \
        '' using 6 title "Manh. Range Fast" ls 1 lw 3

# Y-Axis: Recall Benign
set ylabel "Recall Benign (%)"
set yrange [0:100]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
set output "python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_recall_benign.pdf"
plot "python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_recall_benign.dat" using 2 title "Anime Range Exh." ls 8 lw 3, \
        '' using 5 title "Anime Range Fast" ls 7 lw 3, \
        '' using 4 title "Repres. Exh." ls 4 lw 3, \
        '' using 7 title "Repres. Fast" ls 3 lw 3, \
        '' using 3 title "Manh. Range Exh." ls 2 lw 3, \
        '' using 6 title "Manh. Range Fast" ls 1 lw 3, \


# Y-Axis: Recall Malicious
set ylabel "Recall Malicious (%)"
set yrange [0:100]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
set output "python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_recall_malicious.pdf"
plot "python/ddos-aid/performance_evaluation/numclusters/plot_numclusters_recall_malicious.dat" using 2 title "Anime Range Exh." ls 8 lw 3, \
        '' using 5 title "Anime Range Fast" ls 7 lw 3, \
        '' using 4 title "Repres. Exh." ls 4 lw 3, \
        '' using 7 title "Repres. Fast" ls 3 lw 3, \
        '' using 3 title "Manh. Range Exh." ls 2 lw 3, \
        '' using 6 title "Manh. Range Fast" ls 1 lw 3

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
#set xtics ("1" 0, "2" 1, "4" 2, "6" 3, "8" 4, "10" 5)
#set xrange [-0.5:5.5]

# Y-Axis: Purity
set ylabel "Purity (%)"
set yrange [50:100]
set ytics ("50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_purity.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_purity.dat" using 3 title "Anime Range Exh." ls 8 lw 3, \
        '' using 5 title "Center Exh." ls 7 lw 3, \
        '' using 8 title "Center Exh. Init." ls 6 lw 3, \
        '' using 4 title "Anime Range Fast" ls 5 lw 3, \
        '' using 6 title "Center Fast" ls 4 lw 3, \
        '' using 7 title "Center Fast Init." ls 3 lw 3, \
        '' using 2 title "Random" ls 2 lw 3, \
        '' using 9 title "Offline K-Means" ls 1 lw 3

# Y-Axis: Recall Benign
set ylabel "Recall Benign (%)"
set yrange [0:100]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_recall_benign.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_recall_benign.dat" using 3 title "Anime Range Exh." ls 8 lw 3, \
        '' using 5 title "Center Exh." ls 7 lw 3, \
        '' using 8 title "Center Exh. Init." ls 6 lw 3, \
        '' using 4 title "Anime Range Fast" ls 5 lw 3, \
        '' using 6 title "Center Fast" ls 4 lw 3, \
        '' using 7 title "Center Fast Init." ls 3 lw 3, \
        '' using 2 title "Random" ls 2 lw 3, \
        '' using 9 title "Offline K-Means" ls 1 lw 3

# Y-Axis: Recall Malicious
set ylabel "Recall Malicious (%)"
set yrange [0:100]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_recall_malicious.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/extended_numclusters/plot_extended_numclusters_recall_malicious.dat" using 3 title "Anime Range Exh." ls 8 lw 3, \
        '' using 5 title "Center Exh." ls 7 lw 3, \
        '' using 8 title "Center Exh. Init." ls 6 lw 3, \
        '' using 4 title "Anime Range Fast" ls 5 lw 3, \
        '' using 6 title "Center Fast" ls 4 lw 3, \
        '' using 7 title "Center Fast Init." ls 3 lw 3, \
        '' using 2 title "Random" ls 2 lw 3, \
        '' using 9 title "Offline K-Means" ls 1 lw 3



###################
# Feature selection
###################
# X-Axis
set xlabel "Feature-selection strategy"
#set xtics ( "src.port" 0, \
        "src.port dst.port" 1, \
        "src.addr." 2, \
        "dst.addr." 3, \
        "src.addr. dst.addr." 4, \
        "src.addr. dst.addr\nsrc.port dst.port" 5, \
        "src.addr. dst.addr\nsrc.port dst.port\nttl len" 6, \
        "src.addr. dst.addr\nsrc.port dst.port\nttl len id\nfrag.offset proto" 7)
set xtics ( "A" 0, \
        "B" 1, \
        "C" 2, \
        "D" 3, \
        "E" 4, \
        "F" 5, \
        "G" 6, \
        "H" 7)
unset xrange

# Y-Axis: Purity
set ylabel "Purity (%)"
set yrange [50:150]
set ytics ("50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_features_purity.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_features_purity.dat" using 2 title "Range Exhaustive" linecolor rgb midnight lw 3, \
        '' using 4 title "Rep. Exhaustive" linecolor rgb aqua lw 3, \
        '' using 3 title "Range Fast" linecolor rgb wave lw 3, \
        '' using 5 title "Rep. Fast" linecolor rgb foam lw 3

# Y-Axis: Recall Benign
set ylabel "Recall Benign Packets (%)"
set yrange [0:200]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_features_recall_benign.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_features_recall_benign.dat" using 2 title "Range Exhaustive" linecolor rgb midnight lw 3, \
        '' using 4 title "Rep. Exhaustive" linecolor rgb aqua lw 3, \
        '' using 3 title "Range Fast" linecolor rgb wave lw 3, \
        '' using 5 title "Rep. Fast" linecolor rgb foam lw 3

# Y-Axis: Recall Malicious
set ylabel "Recall Malicious Packets (%)"
set yrange [0:200]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_features_recall_malicious.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_features_recall_malicious.dat" using 2 title "Range Exhaustive" linecolor rgb midnight lw 3, \
        '' using 4 title "Rep. Exhaustive" linecolor rgb aqua lw 3, \
        '' using 3 title "Range Fast" linecolor rgb wave lw 3, \
        '' using 5 title "Rep. Fast" linecolor rgb foam lw 3


###################
# Num clusters - Normalization
###################

set style histogram errorbars gap 2 lw 3

# X-Axis
set xlabel "Num clusters"
set xtics ("2" 0, "4" 1, "6" 2, "8" 3, "10" 4)
set xrange [-0.5:4.5]

# Y-Axis: Purity
set ylabel "Purity (%)"
set yrange [50:150]
set ytics ("50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_normalization_numclusters_purity.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_normalization_numclusters_purity.dat" using 2:3:4 title "Range Exhaustive" linecolor rgb midnight lw 3, \
        '' using 8:9:10 title "Rep. Exhaustive" linecolor rgb aqua lw 3, \
        '' using 5:6:7 title "Range Fast" linecolor rgb wave lw 3, \
        '' using 11:12:13 title "Rep. Fast" linecolor rgb foam lw 3

# Y-Axis: Recall Benign
set ylabel "Recall Benign Packets (%)"
set yrange [0:200]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_normalization_numclusters_recall_benign.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_normalization_numclusters_recall_benign.dat"  using 2:3:4 title "Range Exhaustive" linecolor rgb midnight lw 3, \
        '' using 8:9:10 title "Rep. Exhaustive" linecolor rgb aqua lw 3, \
        '' using 5:6:7 title "Range Fast" linecolor rgb wave lw 3, \
        '' using 11:12:13 title "Rep. Fast" linecolor rgb foam lw 3

# Y-Axis: Recall Malicious
set ylabel "Recall Malicious Packets (%)"
set yrange [0:200]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
#set output "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_normalization_numclusters_recall_malicious.pdf"
#plot "python/ddos-aid/performance_evaluation/plots_reset_window_60s/numclusters/plot_normalization_numclusters_recall_malicious.dat"  using 2:3:4 title "Range Exhaustive" linecolor rgb midnight lw 3, \
        '' using 8:9:10 title "Rep. Exhaustive" linecolor rgb aqua lw 3, \
        '' using 5:6:7 title "Range Fast" linecolor rgb wave lw 3, \
        '' using 11:12:13 title "Rep. Fast" linecolor rgb foam lw 3

