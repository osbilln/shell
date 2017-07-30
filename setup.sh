#!/bin/bash

# This scripts setups default settings for mongo. 
#
# CONFIGURATIONS:
SVNUSER='build'
SVNPASS='hQ46DmYe9Pln651'
SERVER='DEV'

# DO NOT EDIT BELOW THIS LINE
WEBSITELOCATION='' # Where you want to store the rockmongo files.

# if the user specifies what type of environment to setup then use that otherwise use default
if [ -n "$1" ]
then
SERVER=$1
fi

# Switch to tmp directory.
cd /tmp

#make sure apache2 is installed
apt-get install apache2

# Make sure make is installed
apt-get install make

# Install pecl module first
pecl install mongo

# Copy the php.ini file over to this machine. 
    cd /tmp
    wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/conf/php/php.ini .
    mv php.ini /etc/php5/apache2/php.ini

# restart apache
service apache2 restart

# Get RockMongo
wget http://rock-php.googlecode.com/files/rockmongo-v1.1.0.zip

# Intall unzip utility
apt-get install unzip

# Create tmp rock directory
mkdir /tmp/rock

# unzip the file.
unzip rockmongo-v1.1.0.zip -d rock

if [ $SERVER = "PROD" ]
then
    WEBSITELOCATION='rockmongoprod'    
else
    WEBSITELOCATION='rockmongodev'
fi

# Setup initial directory
mkdir -p /var/www/sites/$WEBSITELOCATION

# Move rock mongo files over to the new location
cp -R /tmp/rock/* /var/www/sites/$WEBSITELOCATION

# Download the rockMongo config file over to this machine
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/conf/rockmongo/config.php

# Move this 3rd party specific config file over to its directory:
mv config.php /var/www/sites/$WEBSITELOCATION

# Copy sample Apache's virtual host file over to this machine.
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/conf/apache/virtualhostfile

# Update the virutal file based on the enviornment that i'm in 
sed "s/HOSTNAMEGOESHERE/$WEBSITELOCATION/g" virtualhostfile > /etc/apache2/sites-available/www.$WEBSITELOCATION.com

# Enable the new virtual site. 
a2ensite www.$WEBSITELOCATION.com

# Reload apache settings:
service apache2 reload

# Clean up tasks
rm /tmp/rockmongo-v1.1.0.zip
rm -rf /tmp/rock
rm /tmp/www.rockmongo.com
