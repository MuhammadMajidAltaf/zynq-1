set terminal postscript eps enhanced color
set output 'fig/x264:pow:667.eps'

set datafile separator ','
set key autotitle columnhead
plot 'x264/vtr-pm-667' u 1:8 w lp, 'x264/vtr-pm-667' u 1:16 w lp, 'x264/vtr-pm-667' u 1:20 w lp
