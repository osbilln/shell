#!/bin/bash
# script-array.sh

script_contents=( $(cat "$0") )
for element in $(seq 0 $((${#script_contents[@]} - 1)))
	do
		echo -n "${script_contents[$element]}"
		echo -n " -- "
	done
echo 
exit 0