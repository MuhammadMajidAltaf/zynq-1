set terminal postscript eps enhanced color
set output 'fig/x264:mem:333.eps'

set datafile separator ','
set key autotitle columnhead
#plot for [col=42:85] 'x264/vtr-pm-333' u 1:col w lp
plot 'x264/vtr-pm-333' u 1:48 w lp, 'x264/vtr-pm-333' u 1:64 w lp, 'x264/vtr-pm-333' u 1:76 w lp
