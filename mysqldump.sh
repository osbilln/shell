#!/bin/bash

NODE=$1
 for i in $NODE
   do 
     echo $i
      ssh $i -C "mysqldump --opt -ucpf_spt -psunshine prootools_financing > /tmp/backup_financing.sql; gzip -9 /tmp/backup_financing.sql"
      ssh $i -C "mysqldump --opt -ucpf_spt -psunshine protoolsbackuptest > /tmp/backup_backuptest.sql; gzip -9 /tmp/backup_backuptest.sql"
     echo " ============================================================="
   done
