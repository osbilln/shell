#!/bin/sh
#
# The script will correct the translation of [i] to <i> and [/i] to </i>.
#

echo "Working dir is $1" > $1/fix_translationRan

cp $1/renderMap*.txt $1/renderMap*.txt.backup
sed "s/\[i\]/\<i\>/g" $1/renderMap*.txt > $1/renderMap*.txt.tmp
mv $1/renderMap*.txt.tmp $1/renderMap*.txt
sed "s/\[\/i\]/\<\/i\>/g" $1/renderMap*.txt > $1/renderMap*.txt.tmp
mv $1/renderMap*.txt.tmp $1/renderMap*.txt
rm $1/renderMap*.txt.backup

cp $1/webcontentupload-indd/data/matrixupload*.csv $1/webcontentupload-indd/data/matrixupload*.csv.backup
sed "s/\[i\]/\<i\>/g" $1/webcontentupload-indd/data/matrixupload*.csv > $1/webcontentupload-indd/data/matrixupload*.csv.tmp
mv $1/webcontentupload-indd/data/matrixupload*.csv.tmp $1/webcontentupload-indd/data/matrixupload*.csv
sed "s/\[\/i\]/\<\/i\>/g" $1/webcontentupload-indd/data/matrixupload*.csv > $1/webcontentupload-indd/data/matrixupload*.csv.tmp
mv $1/webcontentupload-indd/data/matrixupload*.csv.tmp $1/webcontentupload-indd/data/matrixupload*.csv
rm $1/webcontentupload-indd/data/matrixupload*.csv.backup

cp $1/webcontentproofing-indd/data/matrixupload*.csv $1/webcontentproofing-indd/data/matrixupload*.csv.backup
sed "s/\[i\]/\<i\>/g" $1/webcontentproofing-indd/data/matrixupload*.csv > $1/webcontentproofing-indd/data/matrixupload*.csv.tmp
mv $1/webcontentproofing-indd/data/matrixupload*.csv.tmp $1/webcontentproofing-indd/data/matrixupload*.csv
sed "s/\[\/i\]/\<\/i\>/g" $1/webcontentproofing-indd/data/matrixupload*.csv > $1/webcontentproofing-indd/data/matrixupload*.csv.tmp
mv $1/webcontentproofing-indd/data/matrixupload*.csv.tmp $1/webcontentproofing-indd/data/matrixupload*.csv
rm $1/webcontentproofing-indd/data/matrixupload*.csv.backup
