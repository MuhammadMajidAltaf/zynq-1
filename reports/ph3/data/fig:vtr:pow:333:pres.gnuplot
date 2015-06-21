set terminal pngcairo
set output 'fig/vtr:pow:333:pres.png'

set datafile separator ','
set key autotitle columnhead

set xlabel "time/s"
set ylabel "power/$\mu$W"

plot 'vtr/vtr-pm-333' u (($1-1422047469980479)/1000000):8 w lp, 'vtr/vtr-pm-333' u (($1-1422047469980479)/1000000):16 w lp, 'vtr/vtr-pm-333' u (($1-1422047469980479)/1000000):20 w lp
