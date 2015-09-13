#!/bin/bash
# Backs up all naehas tables.
# Excludes customer tables, and rendermap tables.

PASSWORD=n3admin


if [[ "$1" == "" ]] ; then
        DB=dmigatewayuat
else
        DB=$1
fi
echo $DB


NAEHAS_TABLES=`echo "show tables where tables_in_${DB} like 'N\_%';" | mysql -uroot -p$PASSWORD $DB -A -s `
ACL_TABLES=`echo "show tables where tables_in_${DB} like 'acl\_%';" | mysql -uroot -p$PASSWORD $DB -A -s `
#LOOKUPS=`echo "select distinct tablename from N_DATA_LISTS where type not in ('DATA_FILE','TMP','STAGING','EXTENSION') and tablename in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = '${DB}')" | mysql -uroot -p$PASSWORD ${DB} -A -s`
echo Checking up $LOOKUPS $NAEHAS_TABLES for $DB > /tmp/${DB}_mysqlcheck_log.txt
echo ""
mysqlcheck -u root -p$PASSWORD $DB $NAEHAS_TABLES $ACL_TABLES >> /tmp/${DB}_mysqlcheck_log.txt
#mysqlcheck -u root -p$PASSWORD $DB $NAEHAS_TABLES $ACL_TABLES $LOOKUPS >> /tmp/${DB}_mysqlcheck_log.txt
echo ""
echo 'Done.' >> /tmp/${DB}_mysqlcheck_log.txt
