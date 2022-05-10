load "python/ddos-aid/performance_evaluation/spectral.pal"

set terminal pdfcairo
set term pdfcairo enhanced font "Helvetica,15" size 6in,2.5in

set xlabel "Time (s)"
unset ylabel
set yrange [0:100]

set key opaque
set datafile separator ","

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M"
set xrange ["2018-12-01 08:00:00.0":"2018-12-01 17:00:00.0"]
#set xrange ["2018-12-01 10:00:00.0":"2018-12-01 15:00:00.0"]
set xtics font "Helvetica,10" 

set output "python/ddos-aid/performance_evaluation/performance_time.pdf"

# Purity, True Negative Rate, True Positive Rate
plot "python/ddos-aid/performance_evaluation/Online_Range_Exhaustive_10_60_0.3_False_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_performance_clustering_time.dat" using 1:2 title "Purity" w l ls 8 lw 2, \
"" using 1:3 title "True Negative Rate" w l ls 6 lw 2 dashtype 2, \
"" using 1:4 title "True Positive Rate" w l ls 2 lw 2 dashtype 2

# Recall Benign, Recall Malicious
unset yrange
plot "python/ddos-aid/performance_evaluation/Online_Range_Exhaustive_10_60_0.3_False_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_performance_clustering_time.dat" using 1:5 title "Recall Benign" w l ls 6 lw 2, \
"" using 1:6 title "Recall Malicious" w l ls 2 lw 2 dashtype 2

# Number Packets Benign, Number Packets Malicious
plot "python/ddos-aid/performance_evaluation/Online_Range_Exhaustive_10_60_0.3_False_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_throughput.dat" using 1:2 title "Number Packets Benign" w l ls 6 lw 2
plot "python/ddos-aid/performance_evaluation/Online_Range_Exhaustive_10_60_0.3_False_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_throughput.dat" using 1:3 title "Number Packets Malicious" w l ls 2 lw 2

# Prioritization
plot "python/ddos-aid/performance_evaluation/Online_Range_Exhaustive_10_60_0.3_False_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_performance_prioritization_time.dat" using 1:2 title "Benign Average Priority" w l ls 6 lw 2, \
                                                                                                                                                                                                             "" using 1:3 title "Malicious Average Priority" w l ls 2 lw 2
plot "python/ddos-aid/performance_evaluation/Online_Range_Exhaustive_10_60_0.3_False_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_performance_prioritization_time.dat" using 1:4 title "Score" w l ls 8 lw 2

# Priority throughputs (for 10 clusters)
plot "python/ddos-aid/performance_evaluation/Online_Range_Exhaustive_10_60_0.3_False_0_60_len_id_frag_offset_ttl_proto_src0_src1_src2_src3_dst0_dst1_dst2_dst3_sport_dport_throughput_priorities.dat" using 1:2 title "Priority 1" w l ls 1 lw 2 , \
''                       using 1:3 title "Priority 2" w l ls 2 lw 2 , \
''                       using 1:4 title "Priority 3" w l ls 3 lw 2 , \
''                       using 1:5 title "Priority 4" w l ls 4 lw 2 , \
''                       using 1:6 title "Priority 5" w l ls 5 lw 2 , \
''                       using 1:7 title "Priority 6" w l ls 6 lw 2 , \
''                       using 1:8 title "Priority 7" w l ls 7 lw 2 , \
''                       using 1:9 title "Priority 8" w l ls 8 lw 2 , \
''                       using 1:10 title "Priority 9" w l ls 9 lw 2 , \
''                       using 1:11 title "Priority 10" w l ls 10 lw 2