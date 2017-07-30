#!/bin/bash
# This script simply sync log files
#
set -x
FIND=/bin/find
SCP=/usr/bin/scp
#
ZUBLOG=/var/log/zub
DBLOG=/var/log/mongo
WEBLOG=/opt/tomcat/logs
ZEUSLOG=/opt/zeus/log
LVSLOG=/var/log
LL="ls -lrd"

#
# {
for ZUB in ssapp01p ssapp02p
  do 
    echo ""
    echo " $ZUB "
    echo " ============================================ "
    ssh $ZUB -C "$LL $ZUBLOG/* "
  done

for DB in ssdb01p ssdb02p ssdb03p
  do 
    echo ""
    echo " $DB"
    echo " ============================================ "
    ssh $DB -C "$LL $DBLOG/*"
  done

for WEB in ssweb01p ssweb02p
  do 
    echo ""
    echo " $WEB"
    echo " ============================================ "
    ssh $WEB -C "$LL $WEBLOG/*"
  done

for ZEUS in ssztm01p ssztm00p
  do 
    echo ""
    echo " $ZEUS "
    echo " ============================================ "
    ssh $ZEUS -C "$LL $ZEUSLOG/*"
  done

for LVS in sslvs01p sslvs02p
  do 
    echo ""
    echo " $LVS"
    echo " ============================================ "
    ssh $LVS -C "$LL $LVSLOG/*"
  done

# } > /tmp/logs 
# mailx -s "chk_log logs Dir" bill@zuberance.com < /tmp/logs
# rm /tmp/logs
