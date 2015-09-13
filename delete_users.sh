#!/bin/bash
set -x
# This script adds ssh key auth enabled users to the system
# it can be involked to add all or a new user by using --all or --new argument respectively
# if --new option is specified then username argument must be specified.
# script depends on existing user keys (username.pub) to create users. A new key will be generated
# if --new option is specified AND public key does not exist in key directory
# 
#
# Directory where all pub keys are stored  


# Help function
display_help()
{
	echo "Usage: $0 <[--all] [--new <username>]>"
	exit 1
}

# Create user function
disable_users()
{
	# Checking if user key exists	
	KEY_DIR="/home/${1}/.ssh"
	KEY_FILE="authorized_keys"
	if [ ! -f "$KEY_DIR/$KEY_FILE" ]
	then
		exit 0
	fi
	mv $KEY_DIR/$KEY_FILE  $KEY_DIR/$KEY_FILE.OLD
}

# Sanity Checks
if [ ! -d ${KEY_DIR} ]
then
	echo "Key directory : $KEY_DIR not found.. Terminating !!"
	exit 1
fi

if [ $# -le 0 -o $# -ge 3 ]
then
	# Display help
	display_help
else


case $* in
--all)
	echo "Creating all acounts..."
	MYDIR=`pwd`
	cd ${KEY_DIR}
	for i in `ls *.pub`
	do
		MY_USER=`echo ${i} | cut -d. -f1`
#		create_user $MY_USER
	done
	cd $MYDIR
	;;
--new*)
	if [ -z "$2" ]
	then
		display_help
	else
		disable_users $2
	fi
	;;
*)	echo "Invalid argument"
	display_help
	;;
esac
fi
