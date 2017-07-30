#!/bin/bash
set -x
SERVER=$1
POST="/etc/postfix"
SASL="/etc/postfix/sasl"
KEY="/etc/pki/tls/certs"

for i in $SERVER
  do
   echo $i
   ssh $i -C "yum clean all && yum -y install postfix postfix-perl-scripts"
   ssh $i -C "cd $POST && mv main.cf main.cf_ORIG"
   scp -rp main.cf $i:$POST/.
   ssh $i -C "mkdir -p $SASL"
   scp -r postpasswd $i:$SASL/passwd
   ssh $i -C "cd $SASL && postmap passwd"
   ssh $i -C "cd $SASL && chmod 600 passwd*"
   ssh $i -C "cd $KEY && make hostname.pem"
   ssh $i -C "cp $KEY/hostname.pem /etc/postfix/cacert.pem"
   ssh $i -C "service sendmail stop"
   ssh $i -C "service postfix restart"
   ssh $i -C "chkconfig sendmail off"
   ssh $i -C "chkconfig postfix on"
   ssh $i -C "mailx -s " Test From $i" bill@zuberance.com < /dev/null"
  done
