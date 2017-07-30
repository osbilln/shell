#!/bin/bash

#Check number of arguments
if [ $# -lt 1 ]; then
         echo 1>&2 Usage: $0 "<DBNAME>/ALL"
         exit 1
fi

# system variables (change these according to your system)
PATH=/usr/local/bin:/usr/bin:/bin:$PATH
USER=root
PASSWORD=n3admin
DBHOST=localhost
LOGFILE=/var/log/mysqldbcheck.log
MAILTO=vipul@neahas.com
TYPE1= # extra params to CHECK_TABLE e.g. FAST
TYPE2=
CORRUPT=no # start by assuming no corruption
#DBNAMES="all" # or a list delimited by space
DBNAMES=$1
DBEXCLUDE="" # or a list delimited by space


# I/O redirection...
touch $LOGFILE
exec 6>&1
exec > $LOGFILE # stdout redirected to $LOGFILE

echo -n "MySQLDBCheck: "
date
echo "---------------------------------------------------------"; echo; echo

# Get our list of databases to check...
if test $DBNAMES = "all" ; then
DBNAMES="`mysql --user=$USER --password=$PASSWORD --batch -N -e "show databases"`"
for i in $DBEXCLUDE
do
  DBNAMES=`echo $DBNAMES | sed "s/\b$i\b//g"`
done
fi

# Run through each database and execute our CHECK TABLE command for all tables
# in a single pass - eyechart
for i in $DBNAMES
do
  # echo the database we are working on
  echo "Database being checked:"
  echo -n "SHOW DATABASES LIKE '$i'" | mysql -t -u$USER -p$PASSWORD $i; echo

  # Check all tables in one pass, instead of a loop
  # Use GAWK to put in comma separators, use SED to remove trailing comma
  # Modified to only check MyISAM or InnoDB tables - eyechart
  DBTABLES="`mysql --user=$USER --password=$PASSWORD $i --batch -N -e "show table status;" \
  | gawk 'BEGIN {ORS=", " } $2 == "MyISAM" || $2 == "InnoDB"{print $1}' | sed 's/, $//'`"

  # Output in table form using -t option
  if [ ! "$DBTABLES" ]
  then
    echo "NOTE:  There are no tables to check in the $i database - skipping..."; echo; echo
  else
    echo "CHECK TABLE $DBTABLES $TYPE1 $TYPE2" | mysql -t -u$USER -p$PASSWORD $i; echo; echo
  fi
done

exec 1>&6 6>&- # Restore stdout and close file descriptor #6

# test our logfile for corruption in the database...
for i in `cat $LOGFILE`
do
  if test $i = "warning" ; then
  CORRUPT=yes
  elif test $i = "error" ; then
  CORRUPT=yes
  fi
done

# Send off our results...
if test $CORRUPT = "yes" ; then
cat $LOGFILE | mail -s "MySQL CHECK Log [ERROR FOUND] for $DBHOST-`date`" $MAILTO
else
cat $LOGFILE | mail -s "MySQL CHECK Log [PASSED OK] for $HOST-`date`" $MAILTO
fi
