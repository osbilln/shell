#!/bin/bash

array0=( First second third )
array1=( '' )
array2=( )
array3=(  )

echo
ListArray()
{
	echo
	echo "Elements in array0: ${array0[@]}"
	echo "Elements in array0: ${array1[@]}"
	echo "Elements in array0: ${array2[@]}"
	echo "Elements in array0: ${array3[@]}"
	echo
echo "Length of first element in array0 = ${#array0}"
echo "Length of first element in array1 = ${#array1}"
echo "Length of first element in array2 = ${#array2}"
echo "Length of first element in array3 = ${#array3}"
echo
echo "Number of elements in array0 = ${#array0[*]}"  # 3
echo "Number of elements in array1 = ${#array1[*]}"  # 1  (Surprise!)
echo "Number of elements in array2 = ${#array2[*]}"  # 0
echo "Number of elements in array3 = ${#array3[*]}"  # 0

}
ListArray

# Adding an element to an array.
array0=( "${array0[@]}" "new0" )
array1=( "${array1[@]}" "new1" )
array2=( "${array2[@]}" "new2" )
array3=( "${array3[@]}" "new3" )

ListArray

# copying an array
array2=( ${array0[@]} )
# adding an element to an array
array=( "${array[@]}" "New Element" )

