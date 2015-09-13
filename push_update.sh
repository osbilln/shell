#!/bin/bash
export SERVERNAME=$1
#
scp -rp yum.conf $SERVERNAME:/etc/yum.conf
#
ssh $SERVERNAME -C "yum clean all" 
ssh $SERVERNAME -C "yum install yum-utils -y"
# ssh $SERVERNAME -C "yum  groupinstall "Administration Tools" "NFS file server" "Development Tools" "Server Configuration Tools" "PostgreSQL Database server" -y"

ssh $SERVERNAME -C "yum -y install sgpio certmonger pam_krb5 krb5-workstation nscd"
ssh $SERVERNAME -C " yum install ruby ruby-devel ruby-libs ruby-irb ruby-rdoc make gcc -y"
#
scp -rp /var/www/html/centos/6/centosdeploy/rubygems-1.3.7.tgz $SERVERNAME:
#
ssh $SERVERNAME -C "tar zxf rubygems-1.3.7.tgz"
ssh $SERVERNAME -C "cd rubygems-1.3.7 && ruby setup.rb"
ssh $SERVERNAME -C "/usr/bin/gem install chef --no-rdoc --no-ri"
#
ssh $SERVERNAME -C "mkdir /etc/chef"
#
scp -rp client.rb $SERVERNAME:/etc/chef/.
scp -rp validation.pem $SERVERNAME:/etc/chef/validation.pem
#
ssh $SERVERNAME -C "chmod 600 /etc/chef/validation.pem"
ssh $SERVERNAME -C "service ntpd stop"
ssh $SERVERNAME -C "rm -rf /etc/localtime"
ssh $SERVERNAME -C "ln -s /usr/share/zoneinfo/GMT /etc/localtime"
ssh $SERVERNAME -C "ntpdate pool.ntp.org"
ssh $SERVERNAME -C "chkconfig ntpd on"
ssh $SERVERNAME -C "service ntpd start"
ssh $SERVERNAME -C "yum update -y"
ssh $SERVERNAME -C "ln -s /home /home.local"
# ssh $SERVERNAME -C "chef-client"
