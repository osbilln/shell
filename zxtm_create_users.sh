#!/bin/bash
# This script adds ssh key auth enabled users to the system
# it can be involked to add all or a new user by using --all or --new argument respectively
# if --new option is specified then username argument must be specified.
# script depends on existing user keys (username.pub) to create users. A new key will be generated
# if --new option is specified AND public key does not exist in key directory
# 
#
# Directory where all pub keys are stored  
KEY_DIR="/shared/util/create_users/data"


# Help function
display_help()
{
        echo "Usage: $0 <[--all] [--new <username>]>"
        exit 1
}

# Create user function
create_user()
{
        # check for existance of dev group
        GROUP_NAME=`grep ^dev /etc/group|cut -d: -f1`
        if [ ! "${GROUP_NAME}" = dev ]
        then
                # Must create group before user creation.
                echo "My group : $GROUP_NAME"
                /usr/sbin/groupadd dev
        fi
        
        # Checking if user key exists   
        if [ ! -f "$KEY_DIR/${1}.pub" ]
        then
                echo "SSH key for user : ${1} not found.. generating new key.."
                echo "Genrating a random password for the key..."
                PW=`dd if=/dev/random bs=4 count=2 2>/dev/null | openssl base64`
                if ! [ $? -eq 0 ]
                then    
                        echo "Error generating a random password .. exiting."
                        exit 1
                else
                        ssh-keygen -t dsa -b 1024 -N ${PW} -f ${KEY_DIR}/${1} -C "${1}@Zuberance"
                        if ! [ $? -eq 0 ]
                        then    
                                echo "Error generating SSH keys .. exiting."
                                exit 1
                        else
                                echo "Please note - Username : ${1} Key passphrase : ${PW}"
                        fi
                fi
        fi
                
                /usr/sbin/useradd -g dev -s /usr/bin/bash -d /home/${1} -m ${1}
                /usr/bin/passwd -N ${1}
                mkdir /home/${1}/.ssh 2>/dev/null
                cp ${KEY_DIR}/$1.pub /home/${1}/.ssh/authorized_keys
                chmod 700 /home/${1}/.ssh
                chmod 400 /home/${1}/.ssh/authorized_keys
                chown -R ${1}:dev /home/${1}/.ssh
                mv /home/${1}/local.bash_profile  /home/${1}/.bash_profile 2>/dev/null
                mv /home/${1}/local.bashrc  /home/${1}/.bashrc 2>/dev/null
                mv /home/${1}/local.profile  /home/${1}/.profile 2>/dev/null
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
                create_user $MY_USER
        done
        cd $MYDIR
        ;;
--new*)
        if [ -z "$2" ]
        then
                display_help
        else
                create_user $2
        fi
        ;;
*)      echo "Invalid argument"
        display_help
        ;;
esac
fi
