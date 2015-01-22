set datafile separator ','
set key autotitle columnhead
plot for [col=2:50] 'vtr/stats' u 1:col w lp
#plot for [col=2:50] 'x264/stats' u 1:col w lp
