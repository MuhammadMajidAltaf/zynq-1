set terminal pngcairo
set output 'fig/x264:pow:333:pres.png'

set datafile separator ','
set key autotitle columnhead

set xlabel "time/s"
set ylabel "power/$\mu$W"

plot 'x264/vtr-pm-333' u (($1-1422031002853686)/1000000):8 w lp, 'x264/vtr-pm-333' u (($1-1422031002853686)/1000000):16 w lp, 'x264/vtr-pm-333' u (($1-1422031002853686)/1000000):20 w lp