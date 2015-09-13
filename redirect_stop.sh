#!/bin/sh
# *************************************************************************
# This script is to stop redirect application 
#
# Fetch the value of $pid_file from Startup script
. /etc/profile
eval `grep \^pid_file=  $REDIRECT_HOME/bin/start_redirect.sh`
if [ -r $pid_file ]; then
kill `cat $pid_file`
rm $pid_file
fi
# EOF #
