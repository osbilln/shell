#!/bin/bash
#set -x

if [ "$#" -ne 6 ]; then
    echo "db_full_dump.sh usage: <db_name> <db_host> <db_user> <db_pw> <dump dir> <bucket location>"
    exit
fi

DB_NAME=$1
DB_HOST=$2
DB_USER=$3
DB_PW=$4
DUMP_DIR=$5
S3_BUCKET=$6

echo "Dumping database $DB_NAME@$DB_HOST"

echo "Dumping to $DUMP_DIR/$DB_NAME.sql.gz"
mysqldump --single-transaction --quick --flush-logs --master-data --routines -u $DB_USER -p$DB_PW -h $DB_HOST $DB_NAME | gzip -9 >  $DUMP_DIR/$DB_NAME.sql.gz

echo "copying to s3://$S3_BUCKET"
s3cmd --force put $DUMP_DIR/$DB_NAME.sql.gz s3://$S3_BUCKET/$DB_NAME.sql.gz

#echo "dump $CLONE_DB_NAME to S3 complete" #, removing local dump file"
#rm -f $DUMP_DIR/$DB_NAME.sql.gz
