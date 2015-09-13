#!/bin/bash
#set -x

if [ "$#" -ne 6 ]; then
    echo "dashboard_db_import.sh usage: <db_name> <db_host> <db_user> <db_pw> <import_dir> <bucket location>"
    exit
fi

DB_NAME=$1
DB_HOST=$2
DB_USER=$3
DB_PW=$4
IMPORT_DIR=$5
S3_BUCKET=$6

echo "downloading $DB_NAME.sql.gz from $S3_BUCKET/$DB_NAME.sql.gz"
s3cmd --force get s3://$S3_BUCKET/$DB_NAME.sql.gz $IMPORT_DIR/$DB_NAME.sql.gz

echo "expanding $DB_NAME.sql.gz"
cd $IMPORT_DIR
gunzip --force $DB_NAME.sql.gz

echo "check if database exists, else create it"
dbexists=`mysql -u $DB_USER -h $DB_HOST -p$DB_PW --skip-column-names -e "SHOW DATABASES like '${DB_NAME}'"`
if [[ -z "$dbexists" ]]; then
    echo "creating database $DB_NAME"
    `mysql -u $DB_USER -h $DB_HOST -p$DB_PW -e "create database $DB_NAME"`
fi

echo "importing $DB_NAME.sql"
mysql -u $DB_USER -h $DB_HOST -p$DB_PW $DB_NAME < $DB_NAME.sql

echo "import of $DB_NAME complete"
