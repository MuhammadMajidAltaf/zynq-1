set terminal pngcairo
set output 'fig/vtr:pow:667:pres.png'

set datafile separator ','
set key autotitle columnhead

set xlabel "time/s"
set ylabel "power/$\mu$W"

plot 'vtr/vtr-pm-667' u (($1-1422046866172044)/1000000):8 w lp, 'vtr/vtr-pm-667' u (($1-1422046866172044)/1000000):16 w lp, 'vtr/vtr-pm-667' u (($1-1422046866172044)/1000000):20 w lp
