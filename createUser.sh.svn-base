#!/bin/bash

# @author: Salim Kapadia
# @date: 03/26/2012
# @version: 1.2
# @description - This program setups a user account that is passed in via 
#                  command line argument 1 and sets default password to sunshine
#
#   How to Run:
#   ./createUser.sh [userName]
#   ./createUser.sh skapadia
#

# @TODO: determine if the bashrc_profile needs to be copied over for user creation. 
#
# 
#
    echo "----------------------------------" 1>&2
    echo "   Starting user setup " 1>&2
    echo "----------------------------------" 1>&2   


    # Check that the user that is running this script is root. 
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root" 1>&2
       exit 1
    fi

    # Confirm that they passed in a user name. 
    if [ -z "$1" ]; then
        echo "You must enter a username when running this file." 1>&2
        exit 1
    fi

    USER_HOME_DIRECTORY="/home/$1"
    if [ -d "$USER_HOME_DIRECTORY" ]; then
        echo "That directory/user already exits."  1>&2
        exit 1    
    fi

    if [ ! -f configuration.cfg ]; then
       echo "The configuration file is not present." 1>&2
       exit 1
    fi

    # load configuration file
    source configuration.cfg

    # Generate encrypted password to be stored.    
    PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' "$DEFAULT_USER_PASSWORD!")
    
    # Create a user directory
    useradd -d $USER_HOME_DIRECTORY -m $1 -p $PASSWORD

    echo "----------------------------------" 1>&2
    echo "   Creating default directories   " 1>&2
    echo "----------------------------------" 1>&2   

    mkdir -p $USER_HOME_DIRECTORY/$USER_SITES_DIRECTORY
    chown $1:$1 -R $USER_HOME_DIRECTORY/$USER_SITES_DIRECTORY

    mkdir -p $USER_HOME_DIRECTORY/logs 
    chown $1:$1 -R $USER_HOME_DIRECTORY/logs

    mkdir -p $USER_HOME_DIRECTORY/sandbox/library
    chown $1:$1 -R $USER_HOME_DIRECTORY/sandbox
    chown $1:$1 -R $USER_HOME_DIRECTORY/sandbox/library

    echo "----------------------------------" 1>&2
    echo "   User setup complete" 1>&2
    echo "----------------------------------" 1>&2   
   
 exit 1

