#!/bin/sh
# Replace form feed characters with a space
F=$1
T=$F.tmp
sed -e 's/\o14/ /g' "$F" > "$T"
mv "$T" "$F"
