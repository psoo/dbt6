# sys_stat.sh: get system info using sar, iostat and vmstat
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# March 2003

#!/bin/sh
if [ $# -ne 3 ]; then
	echo "Usage: $0 <interval> <duration> <result_dir>"
	exit
fi

INTERVAL=$1
RUN_DURATION=$2
RESULTS_PATH=$3

#calculate count
let "COUNT=$RUN_DURATION/$INTERVAL"
if [ $COUNT -eq 0 ]
then
	COUNT=1
fi

#get one more count
let "COUNT=$COUNT+1"

##get database statistics
#echo "start db_stats.sh"
#./db_stats.sh $SID $RESULTS_PATH $COUNT $INTERVAL &
#
if [ -f $RESULTS_PATH/thruput.sar.out ]; then
	rm $RESULTS_PATH/thruput.sar.out
fi

echo "start sar"
export PATH=/usr/local/bin:$PATH

#get sysstat version
sar -V &> .sar.tmp
sysstat=`cat .sar.tmp | grep version | awk '{print $3}'`
rm .sar.tmp

#sar
echo "start sar version $sysstat"
if [ $sysstat = '4.0.3' ]; then
	sar -o $RESULTS_PATH/thruput.sar.out $INTERVAL 0 &
else
	sar -o $RESULTS_PATH/thruput.sar.out $INTERVAL 0 &
fi
	
#iostat
echo "start iostat"
echo "iostat -d $INTERVAL $COUNT" > $RESULTS_PATH/thruput.iostat.txt
iostat -d $INTERVAL $COUNT >> $RESULTS_PATH/thruput.iostat.txt &
iostat -x -d $INTERVAL $COUNT >> $RESULTS_PATH/thruput.iostatx.txt &
# collect vmstat 
echo "start vmstat"
echo "vmstat $INTERVAL $COUNT" > $RESULTS_PATH/thruput.vmstat.txt
vmstat $INTERVAL $COUNT >> $RESULTS_PATH/thruput.vmstat.txt &
#sh ./runtop.sh $1 $2 $RESULTS_PATH &

echo "sleep for $RUN_DURATION seconds..."
sleep $RUN_DURATION
echo "sys_stats.sh done"
