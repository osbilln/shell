# install cacti 0.8.7g on CentOS linux
# Make by Patrick.Ru @ China
# E-Mail : patrick.ru@hotmail.com
# Date : 30-Aug-2010

yum install -y wget
if [ "$HOSTTYPE" == "x86_64" ]; then
wget http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/apt-0.5.15lorg3.94a-5.el5.rf.x86_64.rpm
wget http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.1-1.el5.rf.x86_64.rpm
elif [ "$HOSTTYPE" == "i686" ]; then
wget http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/apt-0.5.15lorg3.94a-5.el5.rf.i386.rpm
wget http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/rpmforge-release-0.5.1-1.el5.rf.i386.rpm
fi
rpm -Uvh *.rpm
rm *.rpm

yum install -y httpd
chkconfig httpd on
service httpd start
yum install -y mysql-server
chkconfig mysqld on
service mysqld start
mysqladmin -u root password dbadmin
yum install -y php php-gd php-mysql php-cli php-ldap php-snmp php-mbstring php-mcrypt
chkconfig snmpd on
service snmpd start
/etc/init.d/httpd restart
yum install -y rrdtool net-snmp-utils 

cd /tmp
if [ ! -f ./cacti-0.8.7g.tar.gz ]
  then
  wget http://www.cacti.net/downloads/cacti-0.8.7g.tar.gz
fi
if [ ! -f ./cacti-plugin-0.8.7g-PA-v2.8.tar.gz ]
  then
  wget http://www.cacti.net/downloads/pia/cacti-plugin-0.8.7g-PA-v2.8.tar.gz
fi
if [ ! -f ./data_source_deactivate.patch ]
  then
  wget http://www.cacti.net/downloads/patches/0.8.7g/data_source_deactivate.patch
fi
if [ ! -f ./graph_list_view.patch ]
  then
  wget http://www.cacti.net/downloads/patches/0.8.7g/graph_list_view.patch
fi
if [ ! -f ./html_output.patch ]
  then  
  wget http://www.cacti.net/downloads/patches/0.8.7g/html_output.patch
fi
if [ ! -f ./ldap_group_authenication.patch ]
  then  
  wget http://www.cacti.net/downloads/patches/0.8.7g/ldap_group_authenication.patch
fi
if [ ! -f ./script_server_command_line_parse.patch ]
  then
  wget http://www.cacti.net/downloads/patches/0.8.7g/script_server_command_line_parse.patch
fi
if [ ! -f ./cacti-plugin-0.8.7g-PA-v2.8.diff ]
  then
  wget http://forums.cacti.net/download.php?id=21605 -O cacti-plugin-0.8.7g-PA-v2.8.diff
fi

if [ ! -f ./html_utility.php.diff ]
  then
  wget http://forums.cacti.net/download.php?id=21611 -O /tmp/html_utility.php.diff
fi
if [ ! -f ./global_arrays.php.diff ]
  then
  wget http://forums.cacti.net/download.php?id=21610 -O /tmp/global_arrays.php.diff
fi

tar zxvf cacti-0.8.7g.tar.gz
tar zxvf cacti-plugin-0.8.7g-PA-v2.8.tar.gz
mv cacti-0.8.7g/* /var/www/html/
cd /var/www/html

patch -p1 -N < /tmp/data_source_deactivate.patch
patch -p1 -N < /tmp/graph_list_view.patch
patch -p1 -N < /tmp/html_output.patch
patch -p1 -N < /tmp/ldap_group_authenication.patch
patch -p1 -N < /tmp/script_server_command_line_parse.patch
patch -p1 -N < /tmp/cacti-plugin-0.8.7g-PA-v2.8.diff

patch -p1 -N < /tmp/html_utility.php.diff
patch -p1 -N < /tmp/global_arrays.php.diff

mysql -u root -pdbadmin -e 'CREATE DATABASE `cacti` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -u root -pdbadmin -e "CREATE USER 'cactiuser'@'localhost' IDENTIFIED BY 'cactiuser';"
mysql -u root -pdbadmin -e 'GRANT ALL PRIVILEGES ON `cacti` . * TO 'cactiuser'@'localhost';'
mysql -u cactiuser -pcactiuser cacti < /var/www/html/cacti.sql
mysql -u cactiuser -pcactiuser cacti < /tmp/cacti-plugin-arch/pa.sql

chown -R apache:apache /var/www/html/
/etc/init.d/httpd restart
touch /etc/cron.d/cacti
echo "*/5 * * * * apache php /var/www/html/poller.php >/dev/null 2>&1" > /etc/cron.d/cacti

