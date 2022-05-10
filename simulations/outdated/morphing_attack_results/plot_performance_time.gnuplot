load "python/palette/spectral.pal"

set terminal pdfcairo
set key out horiz top
set term pdfcairo enhanced font "Helvetica,14" size 4in,2.5in

set datafile separator ","
set xlabel "Time (s)"

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%S"
set xrange ["1970-01-01 01:00:00":"1970-01-01 01:00:30"]

set yrange [0:100]
set output path.".pdf"

# Purity, True Negative Rate, True Positive Rate
plot path."_clustering_performance_time.dat" using 1:2 title "Purity" w l ls 8 lw 3                                 

# Recall Benign, Recall Malicious
plot path."_clustering_performance_time.dat" using 1:4 title "True Positive Rate" w l ls 2 lw 3, \
""                                           using 1:3 title "True Negative Rate" w l ls 6 lw 3, \
""                                           using 1:6 title "Recall Malicious" w l ls 2 lw 3 dashtype 2, \
""                                           using 1:5 title "Recall Benign" w l ls 6 lw 3 dashtype 2

# Number Packets Benign, Number Packets Malicious
unset yrange
plot path."_throughput.dat" using 1:2 title "Number Packets Benign" w l ls 6 lw 3
plot path."_throughput.dat" using 1:3 title "Number Packets Malicious" w l ls 2 lw 3

# Priority throughputs (for 4 clusters)
plot path."_throughput_priorities.dat" using 1:2 title "Priority 0" w l ls 1 lw 4 , \
''                       using 1:3 title "Priority 1" w l ls 2 lw 4 , \
''                       using 1:4 title "Priority 2" w l ls 4 lw 4 , \
''                       using 1:5 title "Priority 3" w l ls 6 lw 4 

# Prioritization
set yrange[0:1]
plot path."_priority_performance_time.dat"    using 1:4 title "Score" w l ls 8 lw 3

set yrange[0:3]
plot path."_priority_performance_time.dat"    using 1:3 title "Malicious Average Priority" w l ls 2 lw 3, \
""                                            using 1:2 title "Benign Average Priority" w l ls 6 lw 3