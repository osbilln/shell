#!/bin/bash
# matrixuploadFileGenerator.sh 
# $1 relative path to root directory of the publish 
# $2 delimiter for fields in header and footer lines
# 
# A new file is created in the current directory containing. The filename is 
# in the format of matrixupload_YYYYMMDDHHMMSS.csv where YYYYMMDDHHMMSS is the 
# current date and time. 
# 
# The first line of the file contains a custom header record comprised of the 
# string "HEADER|" followed immediately by the filename and then padded with
# a number of delimiters to match the number of delimiters per row 
# 
# After the first line, the contents of the original production.csv appear. 
# 
# After the contents of the original production.csv is a custom footer row comprized 
# of "FOOTER|" followed immediately by the number of actual data records in the 
# original production.csv and then padded with a number of delimiters to match the
# number of delimiters per row
filePath=$1
delimiter=$2

for originalFile in $1/*/data/production*
do
if [ -r $originalFile ] 
then
    echo "$originalFile exists and readable"

# Create the new file name with the current date&time stamp. 
    newFile=`date "+matrixupload_%Y%m%d%H%M%S.csv"` 

# Get the count of lines in the original production.csv 
# (grep should be faster than wc -l) 
    recordCount=`grep -c '\n' $originalFile` 
    echo $recordCount

# Adjust the record count, subtracting for the first line in the production.csv which 
# contains the column names and no actual data 
    adjRecordCount=`expr $recordCount - 1` 

# Get the total number of delimiters in the header of the file
    delimCount=$(head -n 1 $originalFile| awk -F"$delimiter" '{print NF-1}')
    echo "must ensure $delimCount delimeters per line"

# Create a new file containing the custom header row 
    customHeaderRow="FHEADER"$delimiter$newFile
    i=1
    while [ "$((i<$delimCount))" -eq 1 ];
	do
	customHeaderRow="$customHeaderRow$delimiter"
	i=$((i+1))
	done
    echo $customHeaderRow > $newFile 

# Append the contents of the original production.csv to the new file 
    cat $originalFile >> $newFile 

# Append the footer row, with the adjusted record count to the end of the new file 
    customFooterRow="FFOOTER"$delimiter$adjRecordCount
    i=1
    while [ "$((i<$delimCount))" -eq 1 ];
        do
        customFooterRow="$customFooterRow$delimiter"
        i=$((i+1))
        done
    echo $customFooterRow >> $newFile
 
    filepath=`dirname $originalFile`
    echo $filepath
    mv $newFile $filepath/$newFile
    echo "created new file $filepath/$newFile"

# Rename the production file extension.
    prodFile=${originalFile%.txt}.csv
    if [[ "${prodFile}" != "${originalFile}" && "${prodFile}" != "${originalFile}.csv" ]] ; then
        mv "${originalFile}" "${prodFile}"
    fi

else
    echo "$originalFile does not exists"
fi
done



