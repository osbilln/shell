#!/bin/sh
# commaRemoveAuditSeq.sh 
# $1 relative path to root directory of the publish 
# 
# A new production csv file is created in the current directory with audit_seq header and content removed. 
# 
# After the first line, the contents of the original production.csv appear. 
# 
filePath=$1
delimiter=','
scriptDir=../scripts/publish

for originalFile in $1/*/data/production*.csv
do
if [ -r $originalFile ] 
then
   echo "$originalFile exists and readable"

# Create the new file name with the current date&time stamp. 
   $scriptDir/deleteDelimiteredColumns.py $originalFile $delimiter audit_seq

   echo "removed audit_seq from file $filepath/$originalFile"

else
   echo "$originalFile does not exists"
fi
done



