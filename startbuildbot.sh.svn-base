#!/usr/bin/env bash
pushd .
source pyvirt/bb/bin/activate
cd Sites/spt/tests/buildbot/master/
make start
cd ../slave
#This allows for scp of downloaded mongo and mysql files
#public ssh key, ~/.ssh/id_dsa.pub  
export USER='jbrody'
make start
popd
