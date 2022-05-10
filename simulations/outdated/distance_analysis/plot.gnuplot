load "../palette/spectral.pal"

set terminal pdfcairo

set key out horiz top
set term pdfcairo enhanced font "Helvetica,15" size 4.2in,2.5in

set xlabel "Cluster combinations"

#set key opaque
set datafile separator ","

set xrange [0:200000]
set xtics ("0" 0, "20k" 20000, "40k" 40000, "60k" 60000, "80k" 80000, "100k" 100000, "120k" 120000, "140k" 140000, "160k" 160000, "180k" 180000, "200k" 200000)

set ylabel "Distance"

set output "anime.pdf"
plot "distances.dat" using 2 title "Anime" w l ls 1 lw 1

set output "euclidean_repres.pdf"
plot "distances.dat" using 3 title "Euclidean Repres." w l ls 2 lw 1

set output "manhattan_repres.pdf"
plot "distances.dat" using 4 title "Manhattan Repres." w l ls 3 lw 1

set output "mmanhattan_ranges.pdf"
plot "distances.dat" using 5 title "Manhattan Ranges" w l ls 4 lw 1

set output "anime_modified.pdf"
plot "distances.dat" using 6 title "Anime Modified" w l ls 5 lw 1

set output "abs_anime.pdf"
plot "distances.dat" using 7 title "Abs Anime" w l ls 5 lw 1

set output "abs_anime_modified.pdf"
plot "distances.dat" using 8 title "Abs Anime Modified" w l ls 5 lw 1

set output "all.pdf"
plot "distances.dat" using 2 title "Anime" w l ls 1 lw 1, \
      ''             using 3 title "Euclidean Repres." w l ls 2 lw 1, \
      ''             using 4 title "Manhattan Repres." w l ls 3 lw 1, \
      ''             using 5 title "Manhattan Ranges" w l ls 4 lw 1, \
      ''             using 6 title "Anime Modified" w l ls 5 lw 1