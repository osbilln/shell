#!/bin/bash

## Run either an XtraBackup or a mysqldump, depending upon the value of
## the first argument.  Other arguments can be specified as needed, or
## hardcoded into the script.

##
## pass these in as necessary.
##

# The first parameter should be 'mysqldump' or 'xtrabackup'.
# The default is 'usage',just get some information on how the script runs.
#
BACKUP_TYPE="${1-usage}"
BACKUP_USER="${2-backup}"
BACKUP_PASS="${3-backup}"
BACKUP_RETENTION="${4-30}";

# for pushing older backups to s3.
S3_BUCKET="s3://fi-mysql-backup"
S3_CFG="/etc/.s3cfg"
S3_RETENTION_DAYS="${5-180}"

# to skip over the S3 steps, set this to 0.
S3_ENABLED=1


# -----------------------
# don't change anything below here unless you're sure it's the right thing
# to do.
# -----------------------
S3_RETENTION=$(($S3_RETENTION_DAYS * 86400))
BACKUP_EBS=/var/lib/mysql
BACKUP_LOCAL=/mnt/backups
XB_LOG=/tmp/backup.log.xb
MD_LOG=/tmp/backup.log.md
BACKUP_TIMESTAMP=`date +%Y%m%d.%H.%s`


# create the backup directories, if they don't exist.
#
create_directories() {
  mkdir -p ${BACKUP_LOCAL}/{mysqldump,xtrabackup}
  return $?
}


# this is specific to ubuntu/debian, because of the location of the MySQL
# defaults file.
#
run_xtrabackup() {
  echo "`date +%Y-%m-%d.%H:%M:%S`: Full backup (xtrabackup) started." | tee ${XB_LOG}

  innobackupex --no-timestamp --user=${BACKUP_USER} --password=${BACKUP_PASS} \
    --defaults-file=/etc/mysql/my.cnf \
    "${BACKUP_LOCAL}/xtrabackup/xtrabackup-${BACKUP_TIMESTAMP}" >> ${XB_LOG} 2>&1

  # make sure the backup completes OK.
  #
  if grep -i 'innobackupex: completed OK' ${XB_LOG} ;
  then
    echo "`date +%Y-%m-%d.%H:%M:%S`: Completed stage 1.  Start stage 2." | tee -a ${XB_LOG}
    innobackupex --apply-log \
       "${BACKUP_LOCAL}/xtrabackup/xtrabackup-${BACKUP_TIMESTAMP}" >> ${XB_LOG} 2>&1

    if [ $(grep -i 'innobackupex: completed OK' ${XB_LOG} | wc -l) -eq 2 ];
    then
      echo "`date +%Y-%m-%d.%H:%M:%S`: Completed backup, stage 2." | tee -a ${XB_LOG}

      # tarball it and replace the most current backup on the EBS volume.
      #
      rm -f ${BACKUP_EBS}/xtrabackup_latest.tar.gz &&
       cd ${BACKUP_LOCAL}/xtrabackup/ &&
       tar cfz xtrabackup-${BACKUP_TIMESTAMP}.tar.gz xtrabackup-${BACKUP_TIMESTAMP}/ &&
       rm -rf xtrabackup-${BACKUP_TIMESTAMP} &&
       cp -f xtrabackup-${BACKUP_TIMESTAMP} ${BACKUP_EBS}/xtrabackup_latest.tar.gz
      RETVAL=$?
    else
      echo "`date +%Y-%m-%d.%H:%M:%S`: Backup preparation failed." | tee -a ${XB_LOG}
      RETVAL=127
    fi
  else
    echo "`date +%Y-%m-%d.%H:%M:%S`: Xtrabackup failed." | tee -a ${XB_LOG}
    RETVAL=63
  fi

  return $RETVAL
}


# Run a mysqldump
#
run_mysqldump() {
  echo "`date +%Y-%m-%d.%H:%M:%S`: Full mysqldump started." | tee ${MD_LOG}

  cd ${BACKUP_LOCAL}/mysqldump
  mysqldump --single-transaction -A --routines --triggers --events \
    -u "${BACKUP_USER}" -p${BACKUP_PASS} > mysqldump-${BACKUP_TIMESTAMP}.sql 2>>${MD_LOG}
  RETVAL=$?

  if [[ $RETVAL -eq 0 ]];
  then
    echo "`date +%Y-%m-%d.%H:%M:%S`: Full mysqldump completed OK." | tee -a ${MD_LOG}

    # replace the most current backup on the EBS volume with this one.
    rm -f ${BACKUP_EBS}/mysqldump_latest.sql.gz
    gzip --fast mysqldump-${BACKUP_TIMESTAMP}.sql
    cp -f mysqldump-${BACKUP_TIMESTAMP}.sql.gz ${BACKUP_EBS}/mysqldump_latest.sql.gz
  else
    echo "`date +%Y-%m-%d.%H:%M:%S`: Full mysqldump failed, error code $RETVAL" | tee -a ${MD_LOG}
  fi

  return $RETVAL
}


# push a file to our s3 bucket.
#
push_to_s3() {
  echo "`date +%Y-%m-%d.%H:%M:%S`: Pushing $1 to Amazon S3"
  s3cmd -c ${S3_CFG} put $1 ${S3_BUCKET}
  RETVAL=$?

  if [[ $RETVAL -eq 0 ]];
  then
    echo "`date +%Y-%m-%d.%H:%M:%S`: Done."
  fi
  return $RETVAL
}


# clean up old files in our S3 bucket.
#
purge_old_s3() {
  echo "`date +%Y-%m-%d.%H:%M:%S`: Cleaning up old S3 files."
  NOW=`date +%s`
  CUTOFF_TIME=$(($NOW - $S3_RETENTION))
  for BACKUP_FILE in `s3cmd -c ${S3_CFG} ls ${S3_BUCKET} | awk '{print $4}' ` ;
  do
     TIMESTAMP=`echo $BACKUP_FILE | cut -d. -f3`
     if [[ $TIMESTAMP -lt $CUTOFF_TIME ]] ;
     then
       echo "`date +%Y-%m-%d.%H:%M:%S`: Purging $BACKUP_FILE"
       s3cmd -c ${S3_CFG} del ${BACKUP_FILE}
       RETVAL=$?
       if [[ $RETVAL -eq 0 ]] ;
       then
         echo "`date +%Y-%m-%d.%H:%M:%S`: S3 purge of ${BACKUP_FILE} completed OK."
       else
         echo "`date +%Y-%m-%d.%H:%M:%S`: S3 purge of ${BACKUP_FILE} failed. Error code $RETVAL"
       fi
     fi
  done
}



# Clean up old backups from the instance-local storage.  We find all files that are
# older than $BACKUP_RETENTION and push them to S3 before we delete them.
purge_old_local() {

  echo "`date +%Y-%m-%d.%H:%M:%S`: Archiving and purging old local backups."
  cd ${BACKUP_LOCAL}
  for BACKUP_FILE in `find . -mtime +${BACKUP_RETENTION} -type f` ;
  do
    echo "`date +%Y-%m-%d.%H:%M:%S`: Found file $BACKUP_FILE"
    RETVAL=0

    # are we using S3 ?
    if [[ $S3_ENABLED -eq 1 ]];
    then
      push_to_s3 $BACKUP_FILE
      RETVAL=$?
    fi

    if [[ $RETVAL -eq 0 ]];
    then
      rm -f $BACKUP_FILE
      echo "`date +%Y-%m-%d.%H:%M:%S`: Archive/purge of $BACKUP_FILE complete."
    else
      echo "`date +%Y-%m-%d.%H:%M:%S`: S3 push of $BACKUP_FILE failed.  Error code $RETVAL"
    fi
  done

  echo "`date +%Y-%m-%d.%H:%M:%S`: Archive and purge complete."
}


######## script start.

create_directories
RETVAL=$?

if [[ $RETVAL -ne 0 ]];
then
  echo "`date +%Y-%m-%d.%H:%M:%S`: Unable to create backup directories."
  exit $RETVAL
fi


# run the kind of backup that we want to run.  or, by default, just print the usage
# and some examples.
#
case "${BACKUP_TYPE}" in
  mysqldump)
    run_mysqldump
    RETVAL=$?
  ;;

  xtrabackup)
    run_xtrabackup
    RETVAL=$?
  ;;

  usage)
    echo "Usage: $0 [mysqldump|xtrabackup] user password local_retention s3_retention"
    cat <<EOF
Where user and password are credentials of a MySQL user that has
sufficient privileges, and where local_retention and s3_retention
are the numbers of days to retain backups locally and on S3.

Examples:
 $0 mysqldump user password 30 180 :
    create a mysqldump backup with 30 days of retention locally
    (in ${BACKUP_LOCAL}).  Backups that are between 31 and 180
    days old will be stored in S3.

 $0 xtrabackup user password 15 90 :
    create an XtraBackup backup with 15 days of retention locally.
    Backups that are between 16 and 90 days old will be stored in S3.

 $0 mysqldump :
    create a mysqldump backup using the default credentials and
    retention settings that are specified in the script itself.

NOTE: You probably should *NOT* use different retention periods between
invocations of this script.  If, for example, you were to run the two
command examples, the retention periods specified in the second example
would take effect immediately and be applied to any backups currently
on the system.

EOF

    exit 1
    ;;

  *)
    echo "Invalid backup type specified.  Must be mysqldump or xtrabackup."
    exit 1

esac


# check the return code from our backup, and if it was 0, go ahead and purge
# outdated backups.
#
if [[ $RETVAL -eq 0 ]];
then
  purge_old_local

  if [[ $S3_ENABLED -eq 1 ]];
  then
    purge_old_s3
  fi

  echo "`date +%Y-%m-%d.%H:%M:%S`: All backup and purge operations complete."
  exit 0
else
  echo "`date +%Y-%m-%d.%H:%M:%S`: Backup failed, purge aborted."
  exit $RETVAL
fi
