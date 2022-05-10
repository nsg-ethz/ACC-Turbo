load "python/palette/spectral.pal"

set terminal pdfcairo
set key out horiz top
set term pdfcairo enhanced font "Helvetica,14" size 4in,2.5in

set datafile separator ","
set xlabel "Time (s)"

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%S"

# IP Destination
#Time,Signature0_Min,Signature0_Max,Signature1_Min,Signature1_Max,Signature2_Min,Signature2_Max,Signature3_Min,Signature3_Max

set output path.feature.".pdf"
set ylabel "Destination Address Third Byte"
#plot path.feature.".dat" using 1:2 title "Cluster 0 [min]" w l ls 1 lw 4, \
#     ''                  using 1:4 title "Cluster 1 [min]" w l ls 2 lw 4, \
#     ''                  using 1:6 title "Cluster 2 [min]" w l ls 3 lw 4, \
#     ''                  using 1:8 title "Cluster 3 [min]" w l ls 4 lw 4, \
#     ''                  using 1:3 title "Cluster 0 [max]" w l ls 1 lw 4, \
#     ''                  using 1:5 title "Cluster 1 [max]" w l ls 2 lw 4, \
#     ''                  using 1:7 title "Cluster 2 [max]" w l ls 3 lw 4, \
#     ''                  using 1:9 title "Cluster 3 [max]" w l ls 4 lw 4

set style fill transparent solid 0.6

plot path.feature.".dat" using 1:8:9 with filledcurves fc '#3288BD' fs solid 0.5 noborder title 'Cluster 0', \
     ''                  using 1:8 w l ls 8 lw 2 notitle, \
     ''                  using 1:9 w l ls 8 lw 2 notitle, \
     ''                  using 1:6:7 with filledcurves fc '#ABDDA4' fs solid 0.5 noborder title 'Cluster 1', \
     ''                  using 1:6 w l ls 6 lw 2 notitle, \
     ''                  using 1:7 w l ls 6 lw 2 notitle, \
     ''                  using 1:4:5 with filledcurves fc '#FEE08B' fs solid 0.5 noborder title 'Cluster 2', \
     ''                  using 1:4 w l ls 4 lw 2 notitle, \
     ''                  using 1:5 w l ls 4 lw 2 notitle, \
     ''                  using 1:2:3 with filledcurves fc '#FDAE61' fs solid 0.5 noborder title 'Cluster 3', \
     ''                  using 1:2 w l ls 3 lw 2 notitle, \
     ''                  using 1:3 w l ls 3 lw 2 notitle

     