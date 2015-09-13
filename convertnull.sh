#! /bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: convertnull.sh <filename> <delimiter>"
    exit 1
fi

. `dirname $0`/../functions.sh

filename=$1
delimiter=$2
original='NULL'
replacement='""'

pattern1="s/^${original}$/${replacement}/i"
pattern2="s/^${original}${delimiter}/${replacement}${delimiter}/i"
pattern3="s/${delimiter}${original}$/${delimiter}${replacement}/i"
pattern4="s/${delimiter}${original}${delimiter}/${delimiter}${replacement}${delimiter}/ig"
pattern5="s/${delimiter}${original}${delimiter}/${delimiter}${replacement}${delimiter}/ig"

fullpattern="${pattern1};${pattern2};${pattern3};${pattern4};${pattern5}"

sedi "${fullpattern}" "${filename}"
