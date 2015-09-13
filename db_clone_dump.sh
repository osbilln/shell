#!/bin/bash
#set -x

if [ "$#" -ne 6 ]; then
    echo "db_clone_dump.sh usage: <db_name> <db_host> <db_user> <db_pw> <dump dir> <bucket location>"
    exit
fi

DB_NAME=$1
DB_HOST=$2
DB_USER=$3
DB_PW=$4
DUMP_DIR=$5
S3_BUCKET=$6

LOOKUPS=`echo "select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id = df.id JOIN INFORMATION_SCHEMA.TABLES it on it.TABLE_NAME = dl.tablename and it.TABLE_SCHEMA='${SET_CLONE_DB_STAGING_NAME}' where dl.type not in ('DATA_FILE') and df.purpose = 'LOOKUP_LIST' UNION select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id = df.id JOIN INFORMATION_SCHEMA.TABLES it on it.TABLE_NAME = dl.tablename and it.TABLE_SCHEMA='${SET_CLONE_DB_STAGING_NAME}' where dl.type not in ('DATA_FILE', 'TMP', 'STAGING', 'EXTENSION') and df.purpose = 'DATA_LIST'" | mysql -uroot -p$DB_PW -h $DB_HOST $DB_NAME -A -s`
NAEHAS_TABLES=`echo "show tables where tables_in_${DB_NAME} like 'N\_%' and tables_in_${DB_NAME} not like 'N\_DATA\_MAPPINGS%';" | mysql -uroot -p$DB_PW -h $DB_HOST $DB_NAME -A -s `
VIEWS=`echo "select table_name from INFORMATION_SCHEMA.tables where table_type = 'VIEW' and table_schema = '${DB_NAME}'" | mysql -uroot -p$DB_PW -h $DB_HOST ${DB_NAME} -A -s`  
ACL_TABLES=`echo "show tables where tables_in_${DB_NAME} like 'acl_%';" | mysql -uroot -p$DB_PW -h $DB_HOST $DB_NAME -A -s `
ENVERS_AUDIT_TABLES=`echo "show tables where tables_in_${DB_NAME} like '%\_aud' and tables_in_${DB_NAME} not like 'N\_%';" | mysql -uroot -p$DB_PW -h $DB_HOST $DB_NAME -A -s `

TABLES_TO_DUMP="$NAEHAS_TABLES $ENVERS_AUDIT_TABLES $ACL_TABLES $LOOKUPS $VIEWS"

echo "Backing up $DB_NAME : $TABLES_TO_DUMP"

echo "Dumping to $DUMP_DIR/$DB_NAME.sql.gz"
mysqldump --single-transaction --quick --flush-logs --master-data -u $DB_USER -p$DB_PW -h $DB_HOST $DB_NAME $TABLES_TO_DUMP | gzip -1 >  $DUMP_DIR/$DB_NAME.sql.gz

#echo "copying to $S3_BUCKET"
#s3cmd --force put $DUMP_DIR/$DB_NAME.sql.gz s3://$S3_BUCKET/$DB_NAME.sql.gz

#echo "dump $CLONE_DB_NAME to S3 complete" #, removing local dump file"
#rm -f $DUMP_DIR/$DB_NAME.sql.gz
