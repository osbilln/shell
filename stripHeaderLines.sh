#!/bin/sh -x

filepathname=$1
lines=$2

sed "$lines d" "$filepathname" > "$filepathname.new"
mv "$filepathname.new" "$filepathname"
