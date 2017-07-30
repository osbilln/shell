#!/bin/bash

CLIENTKEY="/etc/chef/client.pem"
HOSTNAME_ORIG=$(cat /etc/hostname)

## Getting a new hostname 

#
#
echo Please, enter New FQDN Hostname
echo      For instance: prodwebe1.naehas.com
#
#
#
  read HOSTNAME_NEW

hostname "$HOSTNAME_NEW"

if [ "$HOSTNAME_NEW" == "$HOSTNAME_ORIG" ]; then
	exit 0
else
   echo $HOSTNAME_NEW
	/bin/rm -rf "$CLIENTKEY"
	ps ax | grep -i chef-client 2>/dev/null | grep -v grep | awk '{print $1}' | xargs kill -15
        sleep 2
        /usr/bin/chef-client -N $HOSTNAME_NEW >> /var/log/chef/chef-client.$HOSTNAME_NEW
        sleep 2
	/etc/init.d/chef-client start
fi

###
cat /etc/hosts | sed s/"$HOSTNAME_ORIG"/"$HOSTNAME_NEW"/g > /tmp/newhosts
mv /tmp/newhosts /etc/hosts
echo "Hostname changed from $HOSTNAME_ORIG to $HOSTNAME_NEW"
###
cat /etc/hostname | sed s/"$HOSTNAME_ORIG"/"$HOSTNAME_NEW"/g > /tmp/newhostname
mv /tmp/newhostname /etc/hostname
echo "The /etc/hostname file has been changed"

### Re-Register chef client 
if [ "$HOSTNAME_NEW" == "$HOSTNAME_ORIG" ]; then
	exit 0
else
   echo $HOSTNAME_NEW
	/bin/rm -rf "$CLIENTKEY"
	ps ax | grep -i chef-client 2>/dev/null | grep -v grep | awk '{print $1}' | xargs kill -15
        sleep 2
        /usr/bin/chef-client -N $HOSTNAME_NEW >> /var/log/chef/chef-client.$HOSTNAME_NEW
        sleep 2
	/etc/init.d/chef-client start
fi
