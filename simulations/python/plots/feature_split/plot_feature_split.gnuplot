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

set datafile separator ","

###################
# Features
###################

# X-Axis
set xlabel "Features"
set xtics ("daddr" 0, "saddr" 1, "sport" 2, "dport" 3, "ttl" 4, "len" 5, "f.off." 6, "id" 7, "proto" 8)
set xrange [-0.5:8.5]

# Y-Axis: Purity
#set boxwidth 1.5
set ylabel "Clustering quality"
set xtics rotate by 33
set xtics out offset -1.25,-0.75
set yrange [0:100]
set ytics ("0" 0, "20" 20, "40" 40, "60" 60, "80" 80, "100" 100)
set output "python/plots/feature_split/feature_split.pdf"
plot "python/plots/feature_split/clustering_performance_logs.dat" using 2 title 'Purity (%)' ls 8 lw 3, \
        '' using 5 title 'Recall benign (%)' ls 2 lw 3, \
        '' using 6 title 'Recall malicious (%)' ls 3 lw 3