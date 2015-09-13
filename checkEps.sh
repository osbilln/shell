#!/bin/sh

for F in *.eps ; do
	od -a "$F" > "$F.od"
 	BADCOUNT=`grep -c 'cr  nl' "$F.od" `
 	NLCOUNT=`grep -c 'cr' "$F.od" `
	echo "$NLCOUNT	$BADCOUNT	$F"
done

