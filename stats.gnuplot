set datafile separator ','
set key autotitle columnhead
plot for [col=2:50] '/tmp/stats' u 1:col w lp
