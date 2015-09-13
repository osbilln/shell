#! /bin/bash

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <filename> <original> <replacement>"
    exit 1
fi

. `dirname $0`/../functions.sh

filename=$1
original=$2
replacement=$3
pattern="s/${original}/${replacement}/g"

sedi "${pattern}" "${filename}"
