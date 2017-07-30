#!/bin/bash

<<<<<<< HEAD
<<<<<<< HEAD
set -x
DATE=`date '+%Y-%m-%d'`

function hostName {
        HOSTDIR=/etc/hosts
	HOSTNAMEDIR=/etc/hostname		
        cat /etc/hosts | sed s/"${HOSTNAME_ORIG}"/"${HOSTNAME}"/g > /tmp/newhosts
        sudo mv /tmp/newhosts /etc/hosts
        ###
        cat /etc/hostname | sed s/"${HOSTNAME_ORIG}.*"/"${HOSTNAME}.naehas.com"/g > /tmp/newhostname
        sudo mv /tmp/newhostname /etc/hostname
	sudo hostname -F /etc/hostname
}

function ipAddress {
        IPADDRESS=${IPADDRESS}
        NETWORK="/etc/network"
        sudo cp -rp ${NETWORK}/interfaces /root/interfaces-${DATE}
        sed "s/address.*/address ${IPADDRESS}/g" ${NETWORK}/interfaces > /tmp/interfaces.new
        sudo mv /tmp/interfaces.new /etc/network/interfaces
}

if [ $# != 2 ]
then
  echo "Arg 1 must be New Hostname billn.naehas.com"
  echo "Arg 2 must be Net IPaddress 192.168.200.78"
  exit 0
fi
HOSTNAME=$1
IPADDRESS=$2
HOSTNAME_ORIG=`/bin/hostname | cut -d. -f1`

echo $HOSTNAME_ORIG

ipAddress 
hostName
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
CLIENTKEY="/etc/chef/client.pem"
HOSTNAME_ORIG=$(cat /etc/hostname)

## Getting a new hostname 

#
#
echo Please, enter New FQDN Hostname
echo      For instance: vicentegoetten.fluigidentity.com
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
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
