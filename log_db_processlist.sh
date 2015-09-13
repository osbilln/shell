#!/bin/sh

#

# This script logs the database process list and log only for target schema.

#

echo "Logging 'show full processlist;' from dbHost=$1 and schema=$2 to file $3"

`date >> $3`

`mysql -h$1 -uroot -pn3admin $2 -e "show full processlist;" | grep $2 >> $3`

#`mysql -h$1 -uroot -pn3admin $2 -e "show open tables WHERE In_use > 0;" >> $3`

`echo "========================================================================" >> $3`
