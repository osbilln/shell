#!/bin/bash
# *************************************************************************
# This script is to start redirect application 
#
. /etc/profile
pid_file="/var/tmp/redirect_core.pid"
java -Xmx128m -ea  -Denv=stage -javaagent:$REDIRECT_HOME/spring-instrument-3.0.0.RELEASE.jar -jar $REDIRECT_HOME/redirect.jar
echo $! > $pid_file
