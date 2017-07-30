#!/bin/bash

#DB_NAME=
#DB_HOST=
#DB_USER=
#DB_PW=

#CLONE_DASHBOARD=
#CLONE_DB_HOST=
#CLONE_DB_USER=
#CLONE_DB_PW=

  # get dbname

  CLONE_DB_NAME=`echo $CLONE_DASHBOARD | tr -C -d 'A-Z0-9a-z' | tr 'A-Z' 'a-z' | sed s/dashboard//`

  # get table list
  LOOKUPS=`echo "select distinct tablename from N_DATA_LISTS where type not in ('DATA_FILE','TMP','STAGING','EXTENSION') and tablename in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = '${CLONE_DB_NAME}_staging')" | mysql -uroot -p$DB_PW -h $CLONE_DB_HOST ${CLONE_DB_NAME}_staging -A -s`
  NAEHAS_TABLES=`echo "show tables where tables_in_${CLONE_DB_NAME} like 'N\_%' and tables_in_${CLONE_DB_NAME} not like 'N\_%DATA\_MAPPINGS%';" | mysql -uroot -p$CLONE_DB_PW -h $CLONE_DB_HOST $CLONE_DB_NAME -A -s `

  echo Backing up $CLONE_DB_NAME $NAEHAS_TABLE

  # dump
  mysqldump -u $CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST $CLONE_DB_NAME $NAEHAS_TABLES | gzip > $CLONE_DB_NAME.sql.gz

  NAEHAS_TABLES=`echo "show tables where tables_in_${CLONE_DB_NAME}_staging like 'N\_%' and tables_in_${CLONE_DB_NAME}_staging not like 'N\_%DATA\_MAPPINGS%';" | mysql -u$CLONE_DB_USER -p$CLONE_DB_PW ${CLONE_DB_NAME}_staging -A -s `

  echo Backing up ${CLONE_DB_NAME}_staging $NAEHAS_TABLES $LOOKUPS for ${CLONE_DB_NAME}_staging

  echo ""

  mysqldump -u $CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST ${CLONE_DB_NAME}_staging $NAEHAS_TABLES $LOOKUPS | gzip > ${CLONE_DB_NAME}_staging.sql.gz

# import into the target

URL=`echo "select distinct URL from N_DOMAINS" | mysql -u$DB_USER -p$DB_PW -h $DB_HOST ${DB_NAME}_staging -A -s`
PARENTDIR=`echo "select distinct PARENT_DIRECTORY from N_ASSET_DIRECTORIES" | mysql -u$DB_USER -p$DB_PW -h $DB_HOST ${DB_NAME}_staging -A -s`

echo $URL
echo $PARENTDIR

echo "Loading into ${DB_NAME}"
zcat ${CLONE_DB_NAME}.sql.gz | mysql -u$DB_USER -p$DB_PW -h $DB_HOST -A ${DB_NAME}
echo "Loading into ${DB_NAME}_staging"
zcat ${CLONE_DB_NAME}_staging.sql.gz | mysql -u$DB_USER -p$DB_PW -h $DB_HOST -A ${DB_NAME}_staging

echo Resetting the URL and PARENTDIR
echo
echo $URL
echo $PARENTDIR
echo

echo "update N_DOMAINS set URL = '$URL'" | mysql -u$DB_USER -p$DB_PW -h $DB_HOST ${DB_NAME}_staging -A -s
echo "update N_ASSET_DIRECTORIES set PARENT_DIRECTORY = '$PARENTDIR'" | mysql -u$DB_USER -p$DB_PW -h $DB_HOST ${DB_NAME}_staging -A -s

