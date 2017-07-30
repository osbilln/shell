#!/bin/sh
#
# The script will insert the NAEHAS_FILE_CODE column as the first column to the inclusion
#

ARG1=$1
ARG2=`basename $1`

LOG="Adding NAEHAS_FILE_CODE rows for $ARG1 with argument $ARG2"
cp $1 $1.backup
echo $LOG > $ARG1.log
awk 'NR > 1 { exit }; 1' ${ARG1} > ${ARG1}.header
awk 'NR > 1 {print "'${ARG2}'\|",$0}' ${ARG1} > ${ARG1}.rows
cat ${ARG1}.header ${ARG1}.rows > $1.tmp
mv $1.tmp $1

sed "s/$ARG2| /$ARG2|/g" $1 > $1.tmp
mv $1.tmp $1

rm ${ARG1}.header
rm ${ARG1}.rows
