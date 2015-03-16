set terminal postscript eps enhanced color
set output 'fig/vtr:mem:333.eps'

set datafile separator ','
set key autotitle columnhead
#plot for [col=42:85] 'vtr/vtr-pm-333' u 1:col w lp
plot 'vtr/vtr-pm-333' u 1:48 w lp, 'vtr/vtr-pm-333' u 1:64 w lp, 'vtr/vtr-pm-333' u 1:76 w lp
