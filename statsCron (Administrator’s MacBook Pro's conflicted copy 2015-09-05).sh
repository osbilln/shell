#!/bin/bash
export PATH=$PATH:$HOME/bin
function delete() {
  /bin/rm -f $1
}
if [ "x$HOME" = "x" ] ; then
  HOME=/home/naehas
fi
LOG=$HOME/cron.log
echo "`date`: ====== statsCron.sh Starting. ======" >> $LOG
if [ ! -f $HOME/bin/.statsrc ] ; then
  echo "`date`: Stats settings not initialized." >> $LOG
  exit 1
fi

. $HOME/bin/.statsrc
if [ "x$STATS_PASSWORD" = "x" ] ; then
  echo "`date`: Stats password not initialized." >> $LOG
  exit 1
fi
if [ "x$STATS_HOST" = "x" ] ; then
  echo "`date`: Stats host not initialized." >> $LOG
  exit 1
fi
if [ "x$1" = "x" ] ; then
  SKIP_JOBS=yes
else
  SKIP_JOBS=no
fi
YESTERDAY=`yesterday`
PROD="dmiplatform-dashboard mpspprod-dashboard mpsp2-dashboard o2mpsp3-dashboard "
UAT="dmiplatformuat-dashboard mpspuat-dashboard mpsp2uat-dashboard "
DEV="base-dashboard "
for DASH in $PROD $UAT $DEV; do
  DASHDIR=/usr/java/$DASH/
  if [ -d $DASHDIR ] ; then
    echo "`date`: Processing $DASH" >> $LOG
    cd $DASHDIR
    cd logs/
    if [ "$SKIP_JOBS" = "no" ] ; then
      echo "`date`:   Collecting job stats." >> $LOG
      collectJobStats.py $DASHDIR/conf/Catalina/localhost/dashboard.xml $YESTERDAY 2>> $LOG
      JOB_STATS="N_EVENTS.jobs.$YESTERDAY"
      if [ -f $JOB_STATS ] ; then
        #load it!
        echo "`date`:   loading $JOB_STATS" >> $LOG
        mysql -uroot -p$STATS_PASSWORD -A -h $STATS_HOST nadb 2>> $LOG <<EOF
  load data local infile '$JOB_STATS'
  into table N_EVENTS
  fields terminated by ',' optionally enclosed by '"' 
  lines terminated by '\n' 
  (LOAD_HOST,DASHBOARD,REVISION,TYPE,JOB,FINISH_DATE,FINISH_TIME,URI,ACTION,DETAILS,RESULT,CONTROLLER_MILLIS,FULL_MILLIS,SIZE) 
EOF
        delete $JOB_STATS
      fi
    fi
    YESTERDAYS_LOG=dashboard.log.$YESTERDAY
    if [ -f $YESTERDAYS_LOG ] ; then
      echo "`date`:   Collecting UI stats." >> $LOG
      parseDashboardRequests.py $YESTERDAYS_LOG 2>> $LOG
      REQ_STATS="N_EVENTS.$YESTERDAYS_LOG"
      if [ -f $REQ_STATS ] ; then
        echo "`date`:   loading $REQ_STATS" >> $LOG
        mysql -uroot -p$STATS_PASSWORD -A -h $STATS_HOST nadb 2>> $LOG <<EOF
load data local infile '$REQ_STATS'
into table N_EVENTS
fields terminated by ',' optionally enclosed by '"' 
lines terminated by '\n' 
(LOAD_HOST,DASHBOARD,REVISION,FINISH_DATE,FINISH_TIME,TYPE,URI,ACTION,RESULT,CONTROLLER_MILLIS,FULL_MILLIS) 
EOF
        delete $REQ_STATS
      fi
      gzip $YESTERDAYS_LOG
    fi
    echo "`date`:   Done." >> $LOG
  else
    echo "`date`: Skipping $DASHDIR" >> $LOG
  fi
done
echo "`date`: ====== statsCron.sh Finished. ======" >> $LOG
