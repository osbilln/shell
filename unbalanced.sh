#!/bin/sh
# TODO: ensure the correct current working directory

test=unbalanced

if [ $# -ne 2 ]; then
	echo "Usage: $test.sh number_requests duration_in_seconds loop_count loop_delay"
	exit
fi

requests=$1
duration=$2
lcount=$3
ldelay=$4

totalrequests=`expr $1 * $3`
loopdelaysecs=`expr $4 / 1000`
totalduration=`expr $2 + $loopdelaysecs`

echo Starting $test test
echo Sending $totalrequests requests in approx. $totalduration secs
echo 

# these copies are made because I like to clean up the results directory periodically
cp extras/jmeter-results-detail-report_21.xsl results
cp extras/expand.jpg results
cp extras/collapse.jpg results

basefilename=$test.`date +%Y%m%d_%H%M%S`
logfile=results/$basefilename.log
resultsfile=results/results.$basefilename.xml

bin/jmeter -t scripts/$test.jmx -j $logfile -l $resultsfile -n -Jnumrequests=$requests -Jtestduration=$duration -Jloopcount=$lcount -Jloopdelay=$ldelay

success=`grep " s=\"true\" " $resultsfile | wc -l`
failure=`grep " s=\"false\" " $resultsfile | wc -l`
total=`expr $success + $failure`

echo 
echo "Detailed Results in: $resultsfile (view in browser with results/*.xsl, *.jpg)"
echo Log file: $logfile
echo
echo Summary 
echo Total Requests Recorded: $total
echo Succeeded: $success
echo Failed: $failure
echo

