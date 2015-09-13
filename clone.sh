#!/bin/bash
set -x
NODE=$1
SPT="/home/spt"
MYSQL="/etc/mysql"

# modified my.cnf file
#
ssh $NODE -C "sed '$ a\[client] \nsocket=/var/run/mysqld/mysqld.sock' /etc/mysql/my.cnf > /tmp/my.cnf_NEW "
ssh $NODE -C "mv $MYSQL/my.cnf $MYSQL/my.sql_ORIG && cp -rp /tmp/my.cnf_NEW $MYSQL/my.cnf"

#
#
ssh $NODE -C "/bin/bash /home/spt/dev/cron/refresh/database/qa_prep_db.sh dev small"
# ssh $NODE -C " rm -rf $SPT/dev/library/XML && rm -rf $SPT/dev/library/PEAR.php"

ssh $NODE -C " cd $SPT/dev && svn switch http://svn.cleanpowerfinance.com/spt/branches/Project2.11 ."

#
#
## cd /root/work/nagios && ./nagios.sh $NODE
##  cd /root/work/munin && ./munin.sh $NODE
