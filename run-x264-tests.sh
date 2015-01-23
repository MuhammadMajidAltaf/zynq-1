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
	X264_INST=/root/x264/x264-snapshot-20141218-2245/x264
	($X264_INST ~/Sintel.y4m -o ~/a.h264 > $VTR_LOG)&

	wait
	END=`date +%s`

	TIME_LOG="$DIR/vtr-time-$i"
	echo $START >> $TIME_LOG
	echo $END >> $TIME_LOG

	GMON_FM="$DIR/vtr-gmount.out-$i"
	cp ~/gmon.out $GMON_FM
	gprof $X264_INST $GMON_FM > "$GMON_FM-profiled"

	echo ">Cooling down"
	sleep 30
done
