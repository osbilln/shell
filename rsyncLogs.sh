#!/opt/local/bin/bash

HOSTNAME=`/usr/bin/hostname | /usr/xpg4/bin/awk -F '.' '{print $1}'`

/opt/local/bin/rsync -a /var/log/zub rsync://10.100.23.77/logs/$HOSTNAME/zub
/opt/local/bin/rsync -a /opt/tomcat/logs rsync://10.100.23.77/logs/$HOSTNAME/tomcat

