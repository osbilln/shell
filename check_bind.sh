#!/bin/bash
#
# DNS / Named process monitor plugin for Nagios
# Written by Thomas Sluyter (nagios@kilala.nl)
# By request of DTV Labs, Liberty Global, the Netherlands
# Last Modified: 19-06-2006
# 
# Usage: ./check_named
#
# Description:
# This plugin determines whether the named DNS server
# is running properly. It will check the following:
# * Are all required processes running?
# * Is it possible to make DNS requests?
#
# Limitations:
# Currently this plugin will only function correctly on Solaris systems.
#
# Output:
# The script returns a CRIT when the abovementioned criteria are
# not matched.
#

# Host OS check and warning message
if [ `uname` != "SunOS" ]
then
        echo "WARNING:"
        echo "This script was originally written for use on Solaris."
        echo "You may run into some problems running it on this host."
        echo ""
        echo "Please verify that the script works before using it in a"
        echo "live environment. You can easily disable this message after"
        echo "testing the script."
        echo ""
fi

# You may have to change this, depending on where you installed your
# Nagios plugins
PATH="/usr/bin:/usr/sbin:/bin:/sbin"
LIBEXEC="/usr/lib/nagios/plugins"
. $LIBEXEC/utils.sh

print_usage() {
	echo "Usage: $PROGNAME"
	echo "Usage: $PROGNAME --help"
}

print_help() {
	echo ""
	print_usage
	echo ""
	echo "Named DNS monitor plugin for Nagios"
	echo ""
	echo "This plugin not developped by the Nagios Plugin group."
	echo "Please do not e-mail them for support on this plugin, since"
	echo "they won't know what you're talking about :P"
	echo ""
	echo "For contact info, read the plugin itself..."
}

while test -n "$1" 
do
	case "$1" in
	  --help) print_help; exit $STATE_OK;;
	  -h) print_help; exit $STATE_OK;;
	  *) print_usage; exit $STATE_UNKNOWN;;
	esac
done

check_processes()
{
	PROCESS="0"
	if [ `ps -ef | grep named | grep -v grep | grep -v nagios | wc -l` -lt 1 ]; then 
		echo "NAMED NOK - One or more processes not running"
		exitstatus=$STATE_CRITICAL
		exit $exitstatus
	fi
}

check_service()
{
	SERVICE=0
	nslookup www.google.com localhost >/dev/null 2>&1
	if [ $? -eq 1 ]; then SERVICE=1;fi

	if [ $SERVICE -eq 1 ]; then 
		echo "SQUID NOK - One or more TCP/IP ports not listening."
		exitstatus=$STATE_CRITICAL
		exit $exitstatus
	fi
}

check_processes
check_service

echo "NAMED OK - Everything running like it should"
exitstatus=$STATE_OK
exit $exitstatus
