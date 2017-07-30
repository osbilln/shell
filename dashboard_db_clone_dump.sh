#!/bin/bash
#set -x

if [ "$#" -ne 6 ]; then
    echo "dashboard_db_dump.sh usage: <db_name> <db_host> <db_user> <db_pw> <dump dir> <bucket location>"
    exit
fi

CLONE_DB_NAME=$1
CLONE_DB_HOST=$2
CLONE_DB_USER=$3
CLONE_DB_PW=$4
DUMP_DIR=$5
S3_BUCKET=$6

# ./customize clone:$CLONE_DASHBOARD

#echo "Cloning dashboard $CLONE_DASHBOARD"

# get dbname

#  DB_HOST=$db_Host

#  CLONE_DB_NAME=`echo $CLONE_DASHBOARD | tr -C -d 'A-Z0-9a-z' | tr 'A-Z' 'a-z' | sed s/dashboard//`

#  DB_NAME=`echo $DASHBOARD_NAME | tr -C -d 'A-Z0-9a-z' | tr 'A-Z' 'a-z' | sed s/dashboard//`

SET_CLONE_DB_NAME=$CLONE_DB_NAME
SET_CLONE_DB_STAGING_NAME=$SET_CLONE_DB_NAME

stagingdbExists=`mysql -uroot -p$CLONE_DB_PW -h $CLONE_DB_HOST --skip-column-names -e "SHOW DATABASES like '${SET_CLONE_DB_NAME}_staging'"`
if [[ ! -z "$stagingdbExists" ]]; then
  SET_CLONE_DB_NAME=${SET_CLONE_DB_NAME}_staging
  SET_CLONE_DB_STAGING_NAME=$SET_CLONE_DB_NAME
fi
  
echo "CLONE_DB_NAME is ${CLONE_DB_NAME}"
echo "SET_CLONE_DB_NAME is ${SET_CLONE_DB_NAME}"
echo "SET_CLONE_DB_STAGING_NAME is ${SET_CLONE_DB_STAGING_NAME}"

echo "Dumping database $SET_CLONE_DB_NAME@$CLONE_DB_HOST"

# get table list now will grab all VCB tables for lookup
# OPS-2012 Converted query from subselect to Dave's new version with join
#LOOKUPS=`echo "select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id=df.id where dl.type not in ('DATA_FILE') and df.purpose='LOOKUP_LIST' and tablename in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = '${SET_CLONE_DB_STAGING_NAME}') UNION select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id=df.id where dl.type not in ('DATA_FILE','TMP','STAGING','EXTENSION') and df.purpose='DATA_LIST' and tablename in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = '${SET_CLONE_DB_STAGING_NAME}')" | mysql -uroot -p$CLONE_DB_PW -h $CLONE_DB_HOST ${SET_CLONE_DB_STAGING_NAME} -A -s`
LOOKUPS=`echo "select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id = df.id JOIN INFORMATION_SCHEMA.TABLES it on it.TABLE_NAME = dl.tablename and it.TABLE_SCHEMA='${SET_CLONE_DB_STAGING_NAME}' where dl.type not in ('DATA_FILE') and df.purpose = 'LOOKUP_LIST' UNION select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id = df.id JOIN INFORMATION_SCHEMA.TABLES it on it.TABLE_NAME = dl.tablename and it.TABLE_SCHEMA='${SET_CLONE_DB_STAGING_NAME}' where dl.type not in ('DATA_FILE', 'TMP', 'STAGING', 'EXTENSION') and df.purpose = 'DATA_LIST'" | mysql -uroot -p$CLONE_DB_PW -h $CLONE_DB_HOST ${SET_CLONE_DB_STAGING_NAME} -A -s`

NAEHAS_TABLES=`echo "show tables where tables_in_${SET_CLONE_DB_NAME} like 'N\_%' and tables_in_${SET_CLONE_DB_NAME} not like 'N\_DATA\_MAPPINGS%';" | mysql -uroot -p$CLONE_DB_PW -h $CLONE_DB_HOST $SET_CLONE_DB_NAME -A -s `
#ACL_TABLES="acl_entry acl_object_identity"
ENVERS_AUDIT_TABLES=`echo "show tables where tables_in_${SET_CLONE_DB_NAME} like '%\_aud' and tables_in_${SET_CLONE_DB_NAME} not like 'N\_%';" | mysql -uroot -p$CLONE_DB_PW -h $CLONE_DB_HOST $SET_CLONE_DB_NAME -A -s `

#NAEHAS_TABLES="$NAEHAS_TABLES $ACL_TABLES $ENVERS_AUDIT_TABLES $LOOKUPS"
NAEHAS_TABLES="$NAEHAS_TABLES $ENVERS_AUDIT_TABLES $LOOKUPS"

echo Backing up $SET_CLONE_DB_NAME : $NAEHAS_TABLES

echo "Dumping to $DUMP_DIR/$SET_CLONE_DB_NAME.sql.gz"
# dump
echo "LOCK_TABLES_ON_CLONE is ${LOCK_TABLES_ON_CLONE}"
if [[ "$LOCK_TABLES_ON_CLONE" = "false" ]] ; then
  mysqldump --single-transaction --lock-tables=false -u $CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST $SET_CLONE_DB_NAME $NAEHAS_TABLES | gzip -9 >  $DUMP_DIR/$SET_CLONE_DB_NAME.sql.gz
else
  mysqldump --single-transaction -u $CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST $SET_CLONE_DB_NAME $NAEHAS_TABLES | gzip -9 >  $DUMP_DIR/$SET_CLONE_DB_NAME.sql.gz
fi

echo "Dumping to $DUMP_DIR/$CLONE_DB_NAME.sql.gz"
# dump
echo "LOCK_TABLES_ON_CLONE is ${LOCK_TABLES_ON_CLONE}"
if [[ "$LOCK_TABLES_ON_CLONE" = "false" ]] ; then
  mysqldump --single-transaction --lock-tables=false -u $CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST $CLONE_DB_NAME $NAEHAS_TABLES | gzip -9 >  $DUMP_DIR/$CLONE_DB_NAME.sql.gz
else
  mysqldump --single-transaction -u $CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST $CLONE_DB_NAME $NAEHAS_TABLES | gzip -9 >  $DUMP_DIR/$CLONE_DB_NAME.sql.gz
fi

echo "copying to $S3_BUCKET"
s3cmd --force put $DUMP_DIR/$CLONE_DB_NAME.sql.gz s3://$S3_BUCKET/$CLONE_DB_NAME.sql.gz

echo "dump $CLONE_DB_NAME to S3 complete, removing local dump file"
rm -f $DUMP_DIR/$CLONE_DB_NAME.sql.gz
