#!/bin/bash -x

#DB_HOST=
#DB_USER=
#DB_PW=

#CLONE_DASHBOARD=
#PASSWORD=
#CLONE_DB_HOST=
#CLONE_DB_USER=
#CLONE_DB_PW=

if [[ $DB_HOST = "" ]]; then
  echo "DB_HOST must be set.  Aborting!"
  exit 1
fi

if [[ $DB_USER = "" ]]; then
  echo "DB_USER must be set.  Aborting!"
  exit 1
fi

if [[ $DB_PW = "" ]]; then
  echo "DB_PW must be set.  Aborting!"
  exit 1
fi


echo "Cloning dashboard $CLONE_DASHBOARD"

  # get dbname

  CLONE_DB_NAME=`echo $CLONE_DASHBOARD | tr -C -d 'A-Z0-9a-z' | tr 'A-Z' 'a-z' | sed s/dashboard//`

  DB_NAME=`echo $DASHBOARD_NAME | tr -C -d 'A-Z0-9a-z' | tr 'A-Z' 'a-z' | sed s/dashboard//`

# import into the target

DB_USER=`echo $DB_USER | tr -d ' '`
DB_PW=`echo $DB_PW | tr -d ' '`

SET_DB_SCHEMA_NAME=$DB_NAME
if [[ $DB_SCHEMA_NAME != "" ]]; then

  SET_DB_SCHEMA_NAME=$DB_SCHEMA_NAME

fi

SET_DB_STAGING_SCHEMA_NAME=${DB_NAME}_staging
if [[ $DB_STAGING_SCHEMA_NAME != "" ]]; then

  SET_DB_STAGING_SCHEMA_NAME=$DB_STAGING_SCHEMA_NAME

fi
  
echo "INFO: DB_NAME=$DB_NAME"
echo "INFO: DB_SCHEMA_NAME=$DB_SCHEMA_NAME"
echo "INFO: DB_STAGING_SCHEMA_NAME=$DB_STAGING_SCHEMA_NAME"
  
echo "Loading into ${SET_DB_SCHEMA_NAME}"
zcat ${CLONE_DB_NAME}.sql.gz | mysql -u$DB_USER -p$DB_PW -h $DB_HOST -A ${SET_DB_SCHEMA_NAME}

echo "Loading into ${SET_DB_STAGING_SCHEMA_NAME}"
zcat ${CLONE_DB_NAME}_staging.sql.gz | mysql -u$DB_USER -p$DB_PW -h $DB_HOST -A ${SET_DB_STAGING_SCHEMA_NAME}

echo Resetting the URL and PARENTDIR
echo
echo $URL
echo $PARENTDIR
echo


