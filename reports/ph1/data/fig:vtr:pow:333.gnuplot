set terminal postscript eps enhanced color
set output 'fig/vtr:pow:333.eps'

set datafile separator ','
set key autotitle columnhead
plot 'vtr/vtr-pm-333' u 1:8 w lp, 'vtr/vtr-pm-333' u 1:16 w lp, 'vtr/vtr-pm-333' u 1:20 w lp
