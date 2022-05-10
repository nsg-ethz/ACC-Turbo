load "~/albert/ddos-aid/simulations/python/palette/spectral.pal"
set terminal pdfcairo

set term pdfcairo enhanced font "Helvetica,17" size 4.5in,2.5in
set datafile separator ","

N = 2   # number of boxes in group
myGap          = 0.2    # relative gap between groups
myBoxWidth     = 0.8    # relative boxwidth within group
myBoxGrid      = (1.0 - myGap)/N
myBoxHalfWidth = myBoxGrid*myBoxWidth/2
myPosY(i)      = column(0) - 0.5 + (i-1)*myBoxGrid + (myBoxGrid + myGap)/2.
myYLow(i)      = myPosY(i) - myBoxHalfWidth
myYHigh(i)     = myPosY(i) + myBoxHalfWidth
myYCenter(i)   = (myYLow(i) + myYHigh(i))/2

set style fill solid 0.3
set offset 0,0,0.5,0.5
set xrange [0:100]
set xlabel '% Traffic Dropped'

set yrange [:] reverse
set ytics out

set output "analysis/two_priorities.pdf"
plot i=1 "analysis/two_priorities.dat"    u (0):0:(0):3:(myYLow(i)):(myYHigh(i)) w boxxy ls 7 lw 4 title 'Benign (β)', \
     i=2  ''                              u (0):0:(0):2:(myYLow(i)):(myYHigh(i)):ytic(1) w boxxy ls 1 lw 4 title 'Attack (α)'
     

