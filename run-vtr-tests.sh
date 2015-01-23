#!/bin/bash

DIR=~/results-`date +%s`
mkdir $DIR

#Run VTR tests
cd ~/vtr
for i in 667 333 222
do
	echo "Running test for speed $i"

	echo ">Set CPU"
	`cpufreq-set -c0 -f ${i}MHz`
	`cpufreq-set -c1 -f ${i}MHz`

	echo ">Start PM"
	TIME=150*667/$i
	PM_LOG="$DIR/vtr-pm-$i"
	(~/monit/stats.rb 2 $TIME $PM_LOG)&

	sleep 10

	echo ">Running test"
	VTR_LOG="$DIR/vtr-out-$i"
	START=`date +%s`
	(./run_reg_test.pl vtr_reg_basic > $VTR_LOG)&

	wait
	END=`date +%s`

	TIME_LOG="$DIR/vtr-time-$i"
	echo $START >> $TIME_LOG
	echo $END >> $TIME_LOG
	echo $($END - $START) >> $TIME_LOG

	echo ">Cooling down"
	sleep 30
done
