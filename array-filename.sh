#!/bin/bash

declare -a array
FILENAME=$1

array=( `cat $FILENAME` )

echo ${array[@]}


IFS=",\[\"\^$\]" read -ra arr <<< $accessha