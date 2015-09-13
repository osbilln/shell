#!/bin/bash
#set -x

if [ "$#" -ne 6 ]; then
    echo "db_proc_dump.sh usage: <db_name> <db_host> <db_user> <db_pw> <dump dir> <bucket location>"
    exit
fi

DB_NAME=$1
DB_HOST=$2
DB_USER=$3
DB_PW=$4
DUMP_DIR=$5
S3_BUCKET=$6

DUMP_FILE=$DB_NAME
DUMP_FILE+="_proc"

echo "Dumping stored procedureds and trigger from database $DB_NAME@$DB_HOST"

echo "Dumping to $DUMP_DIR/$DUMP_FILE.sql.gz"
mysqldump --routines --no-create-info --no-data --no-create-db -u $DB_USER -p$DB_PW -h $DB_HOST $DB_NAME | gzip -9 >  $DUMP_DIR/$DUMP_FILE.sql.gz

echo "copying to s3://$S3_BUCKET"
s3cmd --force put $DUMP_DIR/$DUMP_FILE.sql.gz s3://$S3_BUCKET/$DUMP_FILE.sql.gz

#echo "dump $CLONE_DB_NAME to S3 complete" #, removing local dump file"
#rm -f $DUMP_DIR/$DB_NAME.sql.gz
