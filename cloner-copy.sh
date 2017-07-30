#!/bin/bash -x

#DB_NAME=dgtest3
#DB_HOST=qadb1
#DB_USER=root
#DB_PW=n3admin

#CLONE_DASHBOARD=dmiperf
#PASSWORD=n3admin
#CLONE_DB_HOST=192.168.201.85
#CLONE_DB_USER=root
#CLONE_DB_PW=n3admin

  # ./customize clone:$CLONE_DASHBOARD

echo "Cloning dashboard $CLONE_DASHBOARD"

  # get dbname

  CLONE_DB_NAME=`echo $CLONE_DASHBOARD | tr -C -d 'A-Z0-9a-z' | tr 'A-Z' 'a-z' | sed s/dashboard//`

  DB_NAME=`echo $DASHBOARD_NAME | tr -C -d 'A-Z0-9a-z' | tr 'A-Z' 'a-z' | sed s/dashboard//`

echo "Copying database $CLONE_DB_NAME@$CLONE_DB_HOST to $DB_NAME@$DB_HOST"

  # get table list
  LOOKUPS=`echo "select distinct tablename from N_DATA_LISTS where type not in ('DATA_FILE','TMP','STAGING','EXTENSION') and tablename in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = '${CLONE_DB_NAME}_staging')" | mysql -uroot -p$CLONE_DB_PW -h $CLONE_DB_HOST ${CLONE_DB_NAME}_staging -A -s`
  NAEHAS_TABLES=`echo "show tables where tables_in_${CLONE_DB_NAME} like 'N\_%' and tables_in_${CLONE_DB_NAME} not like 'N\_%DATA\_MAPPINGS%';" | mysql -uroot -p$CLONE_DB_PW -h $CLONE_DB_HOST $CLONE_DB_NAME -A -s `
  ACL_TABLES="acl_entry acl_object_identity"

  NAEHAS_TABLES="$NAEHAS_TABLES $ACL_TABLES"

  echo Backing up $CLONE_DB_NAME $NAEHAS_TABLES

  # dump
  mysqldump -u $CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST $CLONE_DB_NAME $NAEHAS_TABLES | gzip > $CLONE_DB_NAME.sql.gz

  NAEHAS_TABLES=`echo "show tables where tables_in_${CLONE_DB_NAME}_staging like 'N\_%' and tables_in_${CLONE_DB_NAME}_staging not like 'N\_%DATA\_MAPPINGS%';" | mysql -u$CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST ${CLONE_DB_NAME}_staging -A -s `

  NAEHAS_TABLES="$NAEHAS_TABLES $ACL_TABLES"

  echo Backing up ${CLONE_DB_NAME}_staging $NAEHAS_TABLES $LOOKUPS for ${CLONE_DB_NAME}_staging

  echo ""

  mysqldump -u $CLONE_DB_USER -p$CLONE_DB_PW -h $CLONE_DB_HOST ${CLONE_DB_NAME}_staging $NAEHAS_TABLES $LOOKUPS | gzip > ${CLONE_DB_NAME}_staging.sql.gz

