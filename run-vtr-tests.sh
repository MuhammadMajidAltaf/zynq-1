#!/bin/bash

DIR=~/results-`date +%s`
mkdir $DIR

cd ~/vtr
for i in 667 333
do
	echo "Running test for speed $i"

	echo ">Set CPU"
	`cpufreq-set -c0 -f ${i}MHz`
	`cpufreq-set -c1 -f ${i}MHz`

	echo ">Start PM"
  TIME=250*$(( 667/$i ))
	PM_LOG="$DIR/vtr-pm-$i"

	(~/monit/stats.rb 2 $TIME $PM_LOG)&

	sleep 10

	echo ">Running test"
	VTR_LOG="$DIR/vtr-out-$i"
	(START=`date +%s`; 
	./run_reg_test.pl vtr_reg_basic > $VTR_LOG
	 END=`date +%s`;
	 TIME_LOG="$DIR/vtr-time-$i";
	 echo $START >> $TIME_LOG;
	 echo $END >> $TIME_LOG;
        )&

	wait

	echo ">Cooling down"
	sleep 30
done
