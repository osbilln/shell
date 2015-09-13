#!/bin/bash
#############################
# check_sftp-file.sh script #
#############################
# Author : Vittorio Memmo
# Ver.1.0.0 - Mar 2012
#############################
#
E_NOARGS=0
if [ -z $1 ]; then 
	echo "Hostname missing!"
        E_NOARGS=1
fi
if [ -z $2 ]; then
	echo "Username missing!"
        E_NOARGS=2
fi
if [ -z $3 ]; then
	echo "You need a password to login into the FTP server!"
        E_NOARGS=3
fi
if [ -z $4 ]; then
	echo "You must specify the path to search file for!"
        E_NOARGS=4
fi
if [ -z $5 ]; then
	echo "You must specify the file name to search for!"
	     E_NOARGS=5
fi
if [ $E_NOARGS != 0 ]; then
	echo "Usage : check_sftp-file.sh <Hostname> <Username> <Password> <Path> <Filename> <Filename date ext format: none|%Y%m%d> <Number of lines in the file>"
	exit $E_NOARGS
fi
HOST=$1
USER=$2
PSWD=$3
PTH1=$4
filenm=$5
filend=$6 # date format
lines_num=$7
if [ -z $filend ] || [ $filend = "none" ]
	then
		file_name=$filenm
fi
if [ $filend != "none" ]
	then
	   filewsf=$(echo "$filenm" | cut -d '.' -f1)
	   filesff=$(echo "$filenm" | cut -d '.' -f2)
		filendate=$(date +$filend)
		file_name=$filewsf$filendate'.'$filesff	
fi
#Copies the specified file on local path
/usr/bin/lftp -u ${USER},${PSWD} sftp://${HOST} <<EOF 2>/dev/null
cd $PTH1
get -O /tmp $file_name
bye
EOF
#
if [  -f /tmp/$file_name ]
	then
		lines=$(cat /tmp/$file_name 2> /dev/null | wc -l)
		rm -f /tmp/$file_name
	   if [ $lines != 0 ] && [ $lines = $lines_num ]
	   	then
      		echo "OK: $file_name found with $lines_num rows"
      		exit 0
      	else
         	echo "CRITICAL: $file_name does not contain $lines_num rows!"
         	exit 2
      fi
	else
		echo "CRITICAL: $file_name not found!"
		exit 2
fi
