#!/bin/bash
echo "----------------------------------------------------------------"
# displaying the name of current user
echo "Welcome Network Configuration:"
# assigning the current date in format dd.mm.yyyy to Date variable
Date=$(date +"%d.%m.%Y")
echo "Today is $Date"
echo "----------------------------------------------------------------"
echo ""
# displaying the current directory
echo "You are in $(pwd)"
echo "Select the service you want from the list below: "
echo ""
# creating variable for selection and assigning it to 0
sel=0
# making a loop for menu
while [ $sel -ne 6 ]
do
	echo ""
	echo "1 Static"
	echo "2 Read animals from file"
	echo "3 Feed animals"
	echo "4 Move to a directory"
	echo "5 Link a txt file"
	echo "6 Exit"
	echo ""
	# reading from the console number and assigning it to variable sel
	read -p "Make selection: " sel
	# creating 5 cases for variable sel
	case "$sel" in
	"1")
	echo "Give three numbers:"
	read n1 n2 n3
	# if n1 is greater than n2 and greater than n3
	if [ $n1 -gt $n2 ] && [ $n1 -gt $n3 ]
	then
		echo ""
		echo "Number $n1 is greater than $n2 and $n3"
	# if n2 is greater than n1 and greater than n3
	elif [ $n2 -gt $n1 ] && [ $n2 -gt $n3 ]
	then
		echo ""
		echo "Number $n2 is greater than $n1 and $n3"
	# if n3 is greater than n1 and greater than n2
	elif [ $n3 -gt $n1 ] && [ $n3 -gt $n2 ]
	then
		echo ""
		echo "Number $n3 is greater than $n1 and $n2"
	else
		echo ""
		echo "None of the numbers $n1, $n2 and $n3 is greater than the other two."
	fi
	;;

	"2")
	echo "Give a file name:"
	read file
	# for every line in given file display...
	for cats in `cat $file`
	do
		echo "Next animal is $cats"
	done
	;;

	"3")
	echo "Give a file name:"
	read file
	for anim in `cat $file`
	do
		# if the line starts with c
		if [[ $anim = c* ]]
		then
			echo "Next animal is $anim"
			echo "feed seeds"
		# if the line contains tiger or lion display...
		elif [ $anim = "tiger" ] || [ $anim = "lion" ]
		then
			echo "Next animal is $anim"
			echo "feed meat"
		else
			echo "Next animal is $anim"
			echo "feed hay"
		fi
	# writing the output to the file
	done > feeding.log
	;;

	"4")
	echo "Give a directory name:"
	read dir
	# if the file exists and is a directory
	if [ -d $dir ]
	then
		# change the current directory to the given directory
		cd $dir
		echo "Your directory is now $(pwd)"
	else
		echo "Directory does not exist."
	fi
	;;

	"5")
	echo "Give a file name: "
	read file
	# if the file exists and is a file and if its name ands with “.txt”
	if [ -f $file ] && [[ $file = *.txt ]]
	then
		# create a symbolic link to the file
		ln -s $file linkTofile
	else
		echo "File does not exist."
	fi
	;;
esac
done
