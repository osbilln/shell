#!/bin/bash

set -e
set -u

HOSTNAME="$(hostname -s)"
DATETIME="$(date +%F_%T)"
BASEDIR="$(dirname "$0")"


bc=`which bc 2>/dev/null`

help() {

    cat <<EOF

	This plugin shows the I/O usage of the specified disk, using data from sysfs.
	It prints two statistics: IO per second
	read from the disk (IOPs read) and written to the disk (IOPs write).

$0:
	-d <disk>		Device to be checked (without the full path, eg. sda)
	-c <read>,<wrtn>	Sets the CRITICAL level for IOPs read and IOPs write, respectively
	-w <read>,<wrtn>	Sets the WARNING level for IOPs read and IOPs write, respectively

EOF

    exit -1
}

# Ensuring we have the needed tools:
if [ ! -f $bc ]; then
    echo "ERROR: You must have iostat and bc installed in order to run this plugin\n\tuse: apt-get install iostat bc\n" && exit -1
fi

# Getting parameters:
while getopts "d:w:c:h" OPT; do
	case $OPT in
		"d") disk=$OPTARG;;
		"w") warning=$OPTARG;;
		"c") critical=$OPTARG;;
		"h") help;;
	esac
done
# Adjusting the three warn and crit levels:
crit_read=`echo $critical | cut -d, -f1`
crit_written=`echo $critical | cut -d, -f2`

warn_read=`echo $warning | cut -d, -f1`
warn_written=`echo $warning | cut -d, -f2`


# Checking parameters:
if [ ! -f "/sys/block/${disk}/stat" ]; then
    echo "ERROR: Device incorrectly specified"
    help
fi

if [ "$warn_read" == "" ] || [ "$warn_written" == "" ] || \
   [ "$crit_read" == "" ] || [ "$crit_written" == "" ]; then
    echo "ERROR: You must specify all warning and critical levels"
    help
fi

if [ $warn_read -ge  $crit_read ] || [ $warn_written -ge  $crit_written ]; then
    echo "ERROR: critical levels must be highter than warning levels"
    help
fi

if [ ! -d "/storage/iostat" ]; then
    mkdir -p "/storage/iostat"
fi

cp /sys/block/${disk}/stat /storage/iostat/${disk}.new

read="$(awk '{print $1}' /storage/iostat/${disk}.new)"
written="$(awk '{print $5}' /storage/iostat/${disk}.new)"
if [ ! -f "/storage/iostat/${disk}" ]; then
    read_old="${read}"
    written_old="${written}"
else
    read_old="$(awk '{print $1}' /storage/iostat/${disk})"
    written_old="$(awk '{print $5}' /storage/iostat/${disk})"
fi

TIMESTAMP="$(date +%s)"
if [ ! -f "/storage/iostat/${disk}" ]; then
    TIMESTAMP_OLD="$(( ${TIMESTAMP} - 300 ))"
else
    TIMESTAMP_OLD="$(stat --format=%Z /storage/iostat/${disk})"
fi

mv /storage/iostat/${disk}.new /storage/iostat/${disk}

read="$( echo "( ${read} - ${read_old} ) / ( ${TIMESTAMP} - ${TIMESTAMP_OLD} )" | bc )"
written="$( echo "( ${written} - ${written_old} ) / ( ${TIMESTAMP} - ${TIMESTAMP_OLD} )" | bc )"

## Comparing the result and setting the correct level:
#if ( [ "`echo "$tps >= $crit_tps" | bc`" == "1" ] || [ "`echo "$read >= $crit_read" | bc -q`" == "1" ] || \
#     [ "`echo "$written >= $crit_written" | bc`" == "1" ] ); then
#        msg="CRITICAL"
#        status=2
#else if ( [ "`echo "$tps >= $warn_tps" | bc`" == "1" ] || [ "`echo "$read >= $warn_read" | bc`" == "1" ] || \
#          [ "`echo "$written >= $warn_written" | bc`" == "1" ] ); then
#        	msg="WARNING"
#        	status=1
#     else
#        msg="OK"
#        status=0
#     fi
#fi

# Printing the results:
#echo "$msg - I/O stats $disk IOPs read=$read IOPs written=$written | 'IOPs_read'=$read; 'IOPs_written'=$written;"
echo "OK - I/O stats $disk IOPs read=$read IOPs written=$written | 'IOPs_read'=$read; 'IOPs_written'=$written;"

# Bye!
#exit $status
exit 0
# vim: ts=4 expandtab fileencoding=utf-8 filetype=sh
