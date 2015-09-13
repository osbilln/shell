#!/bin/bash
# *************************************************************************
# This script is to start reportapplication 
#
. /etc/profile
pid_file="/var/tmp/redirect_core.pid"
java -Xmx128m -javaagent:$REPORT_HOME/spring-instrument-3.0.0.RELEASE.jar -Denv=stage -jar $REPORT_HOME/report.jar     
# /usr/bin/java -Xms128m -Xmx128m -Dcore=redirect -Denv=stage -jar $REPORT_HOME/report.jar 2>/dev/null &
echo $! > $pid_file
