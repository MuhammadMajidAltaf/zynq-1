set datafile separator ','
set key autotitle columnhead
plot for [col=2:25] 'vtr/vtr-pm-667' u 1:col w lp, for [col=2:25] 'vtr/vtr-pm-333' u 1:col w lp
#plot for [col=2:50] 'x264/stats' u 1:col w lp
