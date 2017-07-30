#!/bin/bash -x

filename=$1
xslName=$(pwd)/../scripts/custom/$2
tempFileName="$filename.tmp.$$"

# Escape quotations
sed -i '' 's/\&quot\;/\&quot\;\&quot\;/g' $filename

# Run XSL Transformation
xsltproc -o "$tempFileName" "$xslName" "$filename"

if [[ $? != 0 ]]; then
    echo "xsltproc failed, csv may not be correct or may be missing"
    exit 4
fi

# Move file back
mv "$tempFileName" "$filename"

