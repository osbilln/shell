#!/bin/sh
# pipeDelmatrixuploadFileGenerator.sh 
# $1 relative path to root directory of the publish 
# 
# A new file is created in the current directory containing. The filename is 
# in the format of matrixupload_YYYYMMDDHHMMSS.csv where YYYYMMDDHHMMSS is the 
# current date and time. 
# 
# The first line of the file contains a custom header record comprised of the 
# string "HEADER|" followed immediately by the filename. 
# 
# After the first line, the contents of the original production.csv appear. 
# 
# After the contents of the original production.csv is a custom footer row comprized 
# of "FOOTER|" followed immediately by the number of actual data records in the 
# original production.csv 
filePath=$1
scriptDir=../scripts/publish
delimiter=','
$scriptDir/matrixuploadFileGenerator.sh $filePath $delimiter "DMIUPLOAD_" "FH" "FT"
for originalFile in $1/*/data/DMIUPLOAD_*
do
if [ -r $originalFile ]
then
    echo "$originalFile exists and readable"
    echo "Using delimiter $delimiter"
    fileName=$originalFile
    echo "fileName=$fileName"
    if grep -q "audit_seq" "$fileName"; 
	then
	    echo "$originalFile has audit_seq column...removing audit_seq column..." 
	    mv $fileName $fileName.tmp
    	    awk -F"$delimiter" '{for(i=1;i<=NF-1;i++)if(i!=x)f=f?f FS $i:$i;print f;f=""}' x=0 $fileName.tmp > ${fileName}
            if [ -r $fileName.tmp ]
	    then
	    	rm $fileName.tmp
	    fi
	else
    	    echo "$originalFile does not have audit_seq column" 
    fi
fi
done
