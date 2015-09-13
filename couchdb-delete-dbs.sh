#!/bin/bash
set -x

function trimEnds(){
	str=$1
	str=${str:1}
	len=${#str}
	str=${str:0:len-1}
	echo $str		
		
}

host="https://billn:at2mJvOuND6n@billn.cloudant.com"

access=`curl -X GET $host/_all_dbs`
IFS=",\[\"\^$\]" read -ra arr <<< $access
# Load into an DBNAME
DBNAME=( $arr )

echo; echo
echo "this is the first element"
echo; echo
echo ${DBNAME[@]}

# echo ${#arr}
N=0
LEN="${#DBNAME[@]}"

while [ $N -le $LEN ]
	do
		X="${DBNAME[@]:$N:1}"
		echo $X
		echo; echo;
		echo " Deleting ..... $X"
		curl -X DELETE "$host/$X"	
    	(( N++ ))
	done