#!/bin/bash
#set -x

if [ "$#" -ne 6 ]; then
    echo "dashboard_db_dump.sh usage: <db_name> <db_host> <db_user> <db_pw> <dump dir> <bucket location>"
    exit
fi

DB_NAME=$1
DB_HOST=$2
DB_USER=$3
DB_PW=$4
DUMP_DIR=$5
S3_BUCKET=$6

echo "Dumping database $DB_NAME@$DB_HOST"

LOOKUPS=`echo "select distinct tablename from N_DATA_LISTS where type not in ('DATA_FILE','TMP','STAGING','EXTENSION') and tablename in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = '${DB}_staging')" | mysql -uroot -p$PASSWORD ${DB}_staging -A -s`
NAEHAS_TABLES=`echo "show tables where tables_in_${DB} like 'N\_%' and tables_in_${DB} not like 'N\_%DATA\_MAPPINGS%';" | mysql -uroot -p$PASSWORD $DB -A -s `| gzip > $DB.sql.gz
NAEHAS_TABLES=`echo "show tables where tables_in_${DB}_staging like 'N\_%' and tables_in_${DB}_staging not like 'N\_%DATA\_MAPPINGS%';" | mysql -uroot -p$PASSWORD ${DB}_staging -A -s `
NAEHAS_AUDIT_TABLES=`echo "show tables where tables_in_${DB}_staging like '%\_AUD' and tables_in_${DB}_staging not like 'N\_%';" | mysql -uroot -p$PASSWORD ${DB}_staging -A -s `
ACL_TABLES="acl_entry acl_object_identity"

TABLES_TO_DUMP="$NAEHAS_TABLES $LOOKUPS $NAEHAS_AUDIT_TABLES $ACL_TABLES" 


echo Backing up $DB_NAME : $TABLES_TO_DUMP

echo "Dumping to $DUMP_DIR/$DB_NAME.sql.gz"
mysqldump --single-transaction -u $DB_USER -p$DB_PW -h $DB_HOST $DB_NAME $TABLES_TO_DUMP | gzip -9 >  $DUMP_DIR/$DB_NAME.sql.gz

echo "copying to $S3_BUCKET"
s3cmd --force put $DUMP_DIR/$DB_NAME.sql.gz s3://$S3_BUCKET/$DB_NAME.sql.gz

echo "dump $CLONE_DB_NAME to S3 complete, removing local dump file"
rm -f $DUMP_DIR/$B_NAME.sql.gz
