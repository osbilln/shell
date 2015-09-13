# Author: James Chase 
# Contact: james@chasecomputers.net
# Description: 	A script to check Virtual Disk Information on ESX 3.5.
# 		It only checks space in terms of Gigabytes. If you have a 
#		Terabyte or more, this isn't a problem. If you are checking
#		a drive that is being reported in Megabytes, then it is just
#		going to tell you that the drive has no space left (which
#		if we are talking about ESX DataStores might as well be true).
#		This is due to bash only doing integer math. Maybe I will 
#		re-write this script with awk or something at some point,
#		but if you know enough to view this file, then you probably
#		are a better scripter than me =o)
#		Also it would be nice if it accepted command line options, and
#		probably the logic could be written to execute faster. Oh well.
#		Hope it can be some help to you.

if test "$#" -ne 3
then
	echo "Usage: check_vdisk.sh [Warning] [Critical] [Mount Point of volume]"
	exit 3
fi

warning=$1
critical=$2
search=$3

#echo $search
freeSpace=`/usr/sbin/vdf -h | grep "$search"`
#echo $freeSpace
freeSpace=`echo $freeSpace | awk '{print $(NF-2)}'`
#echo $freeSpace
if [ "$freeSpace" != "" ]
then
	fileType=`echo $freeSpace | sed s/[0-9]*//`
	#echo $fileType
	freeSpace=`echo $freeSpace | sed s/[A-Z]//`
	if test "$fileType" = "T"
	then
		#echo 'Converting to TB from GB'
		freeSpace=$(($freeSpace * 1000))
	fi
	if test "$fileType" = "M"
	then
		#echo 'Converting from MB to GB'
		freeSpace=$(($freeSpace / 1000))
	fi
	
	#echo $freeSpace
	if test $freeSpace -le $critical
	then
		echo "$freeSpace ${fileType}B left!"
		exit 2
	fi
	if test $freeSpace -le $warning
	then
		echo "$freeSpace ${fileType}B left!"
		exit 1
	fi
	if test $freeSpace -gt $warning
	then
		echo "$freeSpace ${fileType}B left." 
		exit 0
	fi
else
	echo 'The filesystem doesnt exist or there is a script error'
	exit 3
fi

