#!/bin/bash

# This scripts setups default settings for mongo. 
#

# CONFIGURATIONS:
SERVER='DEV'

# if the user specifies what type of environment to setup then use that otherwise use default
if [ -n "$1" ]
then
SERVER=$1
fi

# Start mongo
echo "starting mongo service"
service mongodb start

# Sleep for 5 seconds to allow the mongo process to start up
sleep 5

# Setup initial db permissions
if [ $SERVER = "PROD" ]
then
    echo "db = db.getSisterDB( \"protools\" ); db.addUser(\"cpf_spt\",\"sunshine\"); " > /tmp/setup.js    
else
    echo "db = db.getSisterDB( \"protools_dev\" ); db.addUser(\"cpf_spt\",\"sunshine\"); " >> /tmp/setup.js
    echo "db = db.getSisterDB( \"protools_staging\" ); db.addUser(\"cpf_spt\",\"sunshine\"); " >> /tmp/setup.js    
    echo "db = db.getSisterDB( \"protools_preview\" ); db.addUser(\"cpf_spt\",\"sunshine\"); " >> /tmp/setup.js
fi

echo "about to create empty mongo databases and granting default user access permissions"
mongo --quiet /tmp/setup.js

# Clean up tasks
rm /tmp/setup.js