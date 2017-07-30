#!/bin/bash

function backup () 
{
        SRCDIR='/etc/bind'
	cd bind
	sudo rsync -azvt $SRCDIR/* .
}

function deployer ()
{
      	DSTDIR='/etc/bind'
	cd bind
	sudo rsync -azvt testfile $DSTDIR/.
#	sudo rsync -azvt db.naehas.com $DSTDIR/.
#	sudo rsync -azvt db.192.168.201 $DSTDIR/.
#	sudo rsync -azvt db.192.168.200 $DSTDIR/.
}

if [ $# != 1 ]
  then
   echo "Arg 1 must be an bind dir (host list etc.....)"
   exit
fi
action_name=${1?}
case $action_name in
    "deployer")
        deployer
        ;;
    "backup")
        backup
        ;;
	*)
        echo "ERROR: unsupported action_name($action_name) for backup"
esac
