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
delimiter='|'
$scriptDir/matrixuploadFileGenerator.sh $filePath $delimiter
