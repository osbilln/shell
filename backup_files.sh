#!/bin/bash
#
# This script runs on cpftools nightly cron (/usr/local/bin/backup_files.sh) to create gzip backups of logos, uploads, and templates
# and saves the files locally as well as to DreamHost
#

# Change into our working directory
cd /backups/files/

# Export needed variables and make needed directory
export d=`date +%G%m%d`
export h=`date +%H`
mkdir -p $d/$h

# Remove backups older than X days
rm -fr `date +%G%m%d -d "14 days ago"`

# Create backup with tar/gzip
date > $d/$h/start.txt
export now=`date "+%Y-%m-%d %H:%M:00"`
# tar czpf $d/$h/archive.tar.gz --directory /home/spt/current_app/logos /home/spt/current_app/secure/shadefiles
cd /home/spt/current_app/public/logos
tar czpf logos.tar.gz .
cp logos.tar.gz /backups/files/$d/$h/logos.tar.gz
mv logos.tar.gz /backups/files/latest/logos.tar.gz

cd /home/spt/current_app/public/uploads
tar czpf uploads.tar.gz .
cp uploads.tar.gz /backups/files/$d/$h/uploads.tar.gz
mv uploads.tar.gz /backups/files/latest/uploads.tar.gz

cd /home/spt/current_app/templates
tar czpf templates.tar.gz .
cp templates.tar.gz /backups/files/$d/$h/templates.tar.gz
mv templates.tar.gz /backups/files/latest/templates.tar.gz

# Encrypt backup with GPG
#gpg -e -r "spt@cleanpowerfinance.com" $d/$h/archive.tar.gz

# Remove unencrypted backups
#rm -f $d/$h/archive.tar.gz
cd /backups/files/
date > $d/$h/end.txt

# Copy backup to Dreamhost via rsync
rsync -av -e ssh --compress  --delete --ignore-errors --perms --times --recursive /backups/files cpf_backup@bawls.dreamhost.com:spt_production

    
