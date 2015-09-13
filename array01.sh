#/bin/bash

echo "Please the word you want to print"
read word
echo " you have entered $word. "
IN=$word
N=0
### this substring counts how many letters we have i


COUNTER=${#IN}  
### this substring counts how many letters we have i
echo " The length of your $word is $COUNTER"
echo; echo
while [ $N -le $COUNTER ]
	do
 	echo ${IN:$N:1}
 	(( N++ ))
	done

echo "I am print your $word separate by a space"
echo ${word:0:1}


array=( zero one two three four five )
### Key Pair Value
array1=( [0]="first element" [1]="second element" [3]="fourth element" )

echo
echo ${array[0]}
echo ${array[1]}
echo ${array[2]}


echo ${array[@]}
echo ${#array[0]}
echo ${#array[*]}

arrayZ=( one two three four five five )

echo " Print out the arrayZ "
echo "======================"
echo ${arrayZ[*]:1}
echo ${arrayZ[@]:0}
echo ${arrayZ[@]:0:3}


# Substring removal
echo ${arrayZ[@]#f*r}  ## Short match
arrayZ=( one two three thrree four five five )
echo ${arrayZ[@]##t*o} ## long match

echo ${arrayZ[@]%%h*e}



# substring replacing

arrayZ=( one two three thrree four five five )
echo ${arrayZ[@]/fiv/XYZ}
echo ${arrayZ[@]//iv/YY}
echo ${arrayZ[@]//iv/}

echo ${arrayZ[@]/#fi/}   # replace front
echo ${arrayZ[@]/%ve/}	 # replace back


replacement() {
	echo -n "!!!"
}

echo ${arrayZ[@]/%ve/$(replacement)}	 # replace back


# FILE=$1
# READING data lines scripts
# FILE=$1
# exec 3<&0
# exec 0<$FILE
# while read line
#	do
#		echo $line
#	done
# exec 0<&3


# Factor Script
# counter = $1
# factorrial = 1
# while [ $counter -gt 0 ]
#	do
#		factorrial=$(( $factorrial * $counter ))
#		counter=$(( $counter - 1))
#	done
#	echo $factorrial

# for i in $(echo $IN | tr ";" "\n")
# do
  # echo ${}
#done


