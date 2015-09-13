#!/bin/bash

DBUSER=root
DBPASSWORD=n3admin
DBSNAME=comcast
DBNAME=comcast_staging
DBSERVER=dev

fCreateTable=""
fInsertData=""
echo "Copying database ... (may take a while ...)"
DBCONN="-h${DBSERVER} -u ${DBUSER} --password=${DBPASSWORD}"
echo "DROP DATABASE IF EXISTS ${DBNAME}" | mysql ${DBCONN}
echo "CREATE DATABASE ${DBNAME}" | mysql ${DBCONN}
for TABLE in `echo "SHOW TABLES like 'N%';" | mysql $DBCONN $DBSNAME | tail -n +2`; do
        createTable="CREATE TABLE ${DBNAME}.${TABLE} LIKE ${DBSNAME}.${TABLE}"
        fCreateTable="${fCreateTable} ; ${createTable}"
        insertData="INSERT INTO ${DBNAME}.${TABLE} SELECT * FROM ${DBSNAME}.${TABLE}"
        fInsertData="${fInsertData} ; ${insertData}"
done;
echo "$fCreateTable ; $fInsertData" | mysql $DBCONN $DBNAME
