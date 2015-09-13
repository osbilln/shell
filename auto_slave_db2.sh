#! /bin/bash
#
# auto-restart slave in case of known errors
################################################################

MYSQL="mysql --defaults-file=/root/.my.cnf --socket=/var/lib/mysql/db2.sock -Bce "

# Is mysql working?

LAST_ERROR=$($MYSQL "show slave status\G" | egrep "Last_IO_Errno" | cut -d":" -f2)

st=1
echo $LAST_ERROR | egrep -q '1153'
if [ $? -eq 0 ]; then st=0; type=partial; fi
  if [ $st -eq 0 ]; then
	# Restart slave
	$MYSQL "start slave IO_THREAD"
  fi
