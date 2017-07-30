#!/bin/bash

# Change into our working directory
cd /backups/mysql/

# Export needed variables and make needed directory
export d=`date +%G%m%d`
export h=`date +%H`
mkdir -p $d/$h

# Remove backups older than X days
rm -fr `date +%G%m%d -d "14 days ago"`

# Create backup with mysqldump
date > $d/$h/start.txt
export now=`date "+%Y-%m-%d %H:%M:00"`

if [ "x$1" == "xbackupsmall" ]
then
  mysqldump --opt -ucpf_spt -psunshine --ignore-table=protools.solardata1 --ignore-table=protools.shadedata --ignore-table=protools.apiusage --ignore-table=protools.quoting_yearly_calcs --ignore-table=protools.proposals --ignore-table=protools.daily_report_editionxstate --ignore-table=protools.solardata2 --ignore-table=protools.audit_trail protools > $d/$h/backupsmall.sql; gzip $d/$h/backupsmall.sql
#  copy to latest dir
/bin/cp $d/$h/backupsmall.sql.gz /backups/mysql/latest
else
  mysqldump --opt -ucpf_spt -psunshine protools > $d/$h/backup.sql; gzip $d/$h/backup.sql
  mysqldump --opt -ucpf_spt -psunshine --ignore-table=protools.solardata1 --ignore-table=protools.shadedata --ignore-table=protools.apiusage --ignore-table=protools.quoting_yearly_calcs --ignore-table=protools.proposals --ignore-table=protools.daily_report_editionxstate --ignore-table=protools.solardata2 --ignore-table=protools.audit_trail protools > $d/$h/backupsmall.sql; gzip $d/$h/backupsmall.sql
#  copy to latest dir
/bin/cp $d/$h/backupsmall.sql.gz /backups/mysql/latest
/bin/cp $d/$h/backup.sql.gz /backups/mysql/latest
fi


# Encrypt backup with GPG
#gpg -e -r "spt@cleanpowerfinance.com" $d/$h/backup.sql.gz

# Remove unencrypted backups
#rm -f $d/$h/backup.sql.gz

date > $d/$h/end.txt

# Copy backup to Dreamhost via rsync
#  (our key here under ~/.ssh must be in authorized_keys at DH)
rsync -av -e ssh --compress --ignore-errors --perms --times --recursive /backups/mysql b248795@hanjin.dreamhost.com:production
# rsync -av -e ssh --compress --ignore-errors --perms --times --recursive /backups/mysql cpf_backup@bawls.dreamhost.com:spt_production


