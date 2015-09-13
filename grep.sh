#!/bin/sh -x

filename=$1
pattern=$2

mv "$filename" "$filename.orig"
egrep "$pattern" "$filename.orig" > "$filename"
