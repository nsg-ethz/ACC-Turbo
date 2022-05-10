set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,16" size 12in,5in


set datafile separator ","

set xlabel "Time (s)"
set ylabel "IP Destination 3rd Byte"

#set xrange [0:654]
set yrange [0:255]
set cbrange [0:3e9]

#set key opaque
set datafile separator ","

set style increment default
set view map scale 1
unset surface 
set style data pm3d
set style function pm3d
set xyplane relative 0
set key off
set pm3d implicit at b

#set xtics ("0" 0, "10000" 100, "20000" 200, "30000" 300, "40000" 400, "50000" 500, "60000" 600)
#set ytics ("0" 0, "    10000" 100, "20000" 200, "30000" 300, "40000" 400, "50000" 500, "60000" 600)

set palette negative defined ( \
    0 '#D53E4F',\
    1 '#F46D43',\
    2 '#FDAE61',\
    3 '#FEE08B',\
    4 '#E6F598',\
    5 '#ABDDA4',\
    6 '#66C2A5',\
    7 '#3288BD' )

set output output_file
splot input_file using 1:2:3
