#!/bin/sh -x

filepathname=$1
newcolheader=$2

numofflds=`head -n 1 $filepathname | awk -F',' '{print NF; exit}'`
filename=$(basename "$filepathname");
newcolval=`echo $filename | cut -d'_' -f1`
awk -v colh="${newcolheader}" -v newcolv="${newcolval}" -v colindex="${numofflds}" 'BEGIN{FS = OFS = ","}
{$(colindex+1) = NR==1 ? colh : newcolv} 
1' "$filepathname" > "$filepathname.new"
mv "$filepathname.new" "$filepathname"
