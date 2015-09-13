#!/bin/sh
#script to concatenate files and append a column at each file to id each original file
#
filePath=$1
outfile=$2
delimiter=$3

for f in $1/*.*
do
if [ -r $f ]
then
    first=$(head -1 $f)
    echo $first
    if [[ "$lastfirst" = "" ]] ; then
       if [[ "$delimiter" = "," ]] ; then
          filecol=",FILEUID"
       else
          delimiter="|"
          filecol="|FILEUID"
       fi        
       lastfirst=$first
       echo "$first$filecol" > $outfile
    else
       if [[ "$lastfirst" != "$first" ]] ; then
         echo 'header lines are differnt:'
         echo $lastfirst
         echo $first
         exit 1
       fi
     fi
else
    echo "$f does not exists" 
    exit 1
fi
done
fid=1
for f2 in $1/*.*
do
   sed 's/$/'"${delimiter}"''"${fid}"'/;' $f | sed -e '1d' >> $outfile
   fid=`expr $fid + 1`
done

