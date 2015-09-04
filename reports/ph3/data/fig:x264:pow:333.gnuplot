set terminal postscript eps enhanced color
set output 'fig/x264:pow:333.eps'

set xlabel "time/s"
set ylabel "power/microwatts"
set datafile separator ','
set key autotitle columnhead
plot 'x264/vtr-pm-333' u 1:8 w lp, 'x264/vtr-pm-333' u 1:16 w lp, 'x264/vtr-pm-333' u 1:20 w lp
