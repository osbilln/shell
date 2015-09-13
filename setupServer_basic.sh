#!/bin/bash
set -x 
# @author: Salim Kapadia
# @date: 03/26/2012
# @version: 1.1
# @description: This program setups the server

#
# @How to Run:
#
#   sh <filename>
#   sh setupServer.sh
#

#
## Things left to do
#   
# @TODO: install mongo server locally.             
# @TODO: ufw enable
# @TODO: ufw allow 80 (for default website)
# @TODO: ufw allow 443 (for SSL-enabled website)
# @TODO: ufw allow 3306 (for MySQL)
# @TODO: ufw allow 27017 (for MongoDB)
# @TODO: copy apache file over to the server and do sed replacements where needed.

# define internal variables for this file.
MYSQL=`whereis mysql`
MYSQLPATH=`which mysql`
APACHE=`whereis apache2`



echo "----------------------------------" 1>&2
echo "   Starting server setup " 1>&2
echo "----------------------------------" 1>&2   

# Check that the user that is running this script is root.
if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root" 1>&2
exit 1
fi

if [ ! -f configuration.cfg ]; then
echo "The configuration file is not present." 1>&2
exit 1
fi

echo "----------------------------------" 1>&2
echo "   loading configuration file " 1>&2
echo "----------------------------------" 1>&2   
# load configuration file
source configuration.cfg       

echo "----------------------------------" 1>&2
echo "   installing aptitude  " 1>&2
echo "----------------------------------" 1>&2
# install required binaries   
apt-get install --assume-yes --force-yes aptitude

echo "----------------------------------" 1>&2
echo "   upgrading existing packages " 1>&2
echo "----------------------------------" 1>&2
# Upgrade existing packages
aptitude upgrade -y

echo "----------------------------------" 1>&2
echo "   upgrading Ubuntu " 1>&2
echo "----------------------------------" 1>&2
# Upgrade Ubuntu to the latest long-term support release (lts) (Release 12.04 "Precise Pangolin" as of this writing):
aptitude install update-manager-core -y

# change the last line
sed -i "s|=normal|=lts|g" /etc/update-manager/release-upgrades

echo "About to run the upgrade command. Note: Server will restart at end of upgrade" 1>&2
do-release-upgrade

# Upgrade existing packages (just in case)
aptitude upgrade -y

echo "----------------------------------" 1>&2
echo "   installing apache, mysql (if not present)" 1>&2
echo "----------------------------------" 1>&2

if [ ! -f "$APACHE" ]; then       
echo "   Apache was not found. Installing now." 1>&2
aptitude install -y apache2

fi

if [ ! -f "$MYSQL" ]; then       
echo "   Mysql was not found. Installing now. You will be prompted for a password" 1>&2
aptitude install -y mysql-server mysql-client       
fi


echo "----------------------------------" 1>&2
echo "   installing dependent objects " 1>&2
echo "----------------------------------" 1>&2
# Install required dependences   
aptitude install -y php5
aptitude install -y php-pear
aptitude install -y php-soap       
aptitude install -y php5-cli
aptitude install -y php5-dev       
aptitude install -y php5-curl
aptitude install -y php5-xdebug
aptitude install -y php5-mysql
aptitude install -y libpcre3 libpcre3-dev # Perl 5 Compatible Regular Expression Library
aptitude install -y libapache2-mod-php5
aptitude install -y libapache2-mod-auth-mysql         
# aptitude install -y phpmyadmin
aptitude install -y subversion
aptitude install -y git
aptitude install -y pdftk
aptitude install -y make     
# aptitude install -y xvfb xserver-xephyr # (to support headless automation tests)
aptitude install -y firefox # (to allow (headless) automation scripts to run)
####aptitude install -y kdiff3


echo "----------------------------------" 1>&2
echo "   installing pear components " 1>&2
echo "----------------------------------" 1>&2
# install PEAR Components       
pear channel-update pear.net
pear update-channels
pear upgrade pear
pear upgrade-all
pear channel-discover pear.phpunit.de
pear channel-discover components.ez.no
pear channel-discover pear.symfony-project.com
pear install XML_Serializer-0.20.2   
pear install --alldeps phpunit/PHPUnit               
pear install phpunit/DbUnit
pear install phpunit/PHPUnit_Selenium
pecl install xdebug


echo "----------------------------------" 1>&2
echo "   Apache modules " 1>&2
echo "----------------------------------" 1>&2
a2enmod expires
a2enmod headers
a2enmod rewrite
a2enmod ssl

# restart apache
service apache2 restart


echo "----------------------------------" 1>&2
echo "   APC setup " 1>&2
echo "----------------------------------" 1>&2
# download apc, unzip, phpize, make, pecl install, clean up
cd /tmp
wget http://pecl.php.net/get/APC-3.1.9.tgz       
tar -xf APC-3.1.9.tgz
cd APC-3.1.9/
phpize
./configure --enable-apc --enable-apc-mmap --with-apxs --with-php config=/usr/local/bin/php-config
make
pecl install apc
echo "extension=apc.so" > /etc/php5/apache2/conf.d/apc.ini


echo "----------------------------------" 1>&2
echo "   openssl setup " 1>&2
echo "----------------------------------" 1>&2
# download openssl, unzip, move, and clean up
cd /tmp
wget http://www.openssl.org/source/openssl-1.0.1a.tar.gz
tar xfz openssl-1.0.1a.tar.gz
cd openssl-1.0.1a/
./config
make
make install


echo "----------------------------------" 1>&2
echo "   prince setup " 1>&2
echo "----------------------------------" 1>&2
# download prince, unzip, move, and clean up
cd /tmp
wget http://www.princexml.com/download/prince-8.0-beta1-linux-amd64.tar.gz
tar -xzf prince-8.0-beta1-linux-amd64.tar.gz
cat "" | sh prince-8.0-beta1-linux-amd64/install.sh   
rm prince-8.0-beta1-linux-amd64.tar.gz
rm -rf prince-8.0-beta1-linux-amd64

echo "----------------------------------" 1>&2
echo "   zend  setup " 1>&2
echo "----------------------------------" 1>&2
# download zend, unzip, move, and clean up
cd /tmp
wget http://framework.zend.com/releases/ZendFramework-1.9.2/ZendFramework-1.9.2.tar.gz
tar xf ZendFramework-1.9.2.tar.gz
mv /tmp/ZendFramework-1.9.2/library/Zend $ZEND_PATH
rm ZendFramework-1.9.2.tar.gz;
rm -rf ZendFramework-1.9.2/

echo "----------------------------------" 1>&2
echo "   doctrine setup " 1>&2
echo "----------------------------------" 1>&2
# download doctrine unzip, move, and clean up
cd /tmp;
wget http://www.doctrine-project.org/downloads/DoctrineORM-2.0.5-full.tar.gz
tar xf DoctrineORM-2.0.5-full.tar.gz
mv /tmp/doctrine-orm/Doctrine $DOCTRINE_PATH
rm -rf doctrine-orm
rm DoctrineORM-2.0.5-full.tar.gz

echo "----------------------------------" 1>&2
echo "   doctrine extension " 1>&2
echo "----------------------------------" 1>&2
# download doctrine extensions unzip, move, and clean up
cd /tmp
svn export http://svn.github.com/beberlei/DoctrineExtensions
mv /tmp/DoctrineExtensions/lib/DoctrineExtensions $DOCTRINE_EXTENSIONS_PATH
rm -rf /tmp/DoctrineExtensions

echo "----------------------------------" 1>&2
echo "   copy configuration files over " 1>&2
echo "----------------------------------" 1>&2
# copy my.ini file over
cd /tmp
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/conf/mysql/my.cnf
mv my.cnf /etc/mysql/my.cnf

# copy php.ini file over
cd /tmp
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/conf/php/php.ini
mv php.ini /etc/php5/apache2/php.ini

# copy mongodb.conf file over
cd /tmp
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/conf/mongodb/mongodb.conf
mv mongodb.conf /etc/mongodb.conf

echo "----------------------------------" 1>&2
echo "   copy php extensions " 1>&2
echo "----------------------------------" 1>&2
# copy extensions over to proper place.
cd /tmp
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/server/cloud/extensions/mongo.so
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/server/cloud/extensions/phpchartdir530.dll
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/trunk/batch/setup/server/cloud/extensions/libchartdir.so
mv mongo.so /usr/lib/php5/20090626/
mv phpchartdir530.dll /usr/lib/php5/20090626
mv libchartdir.so /usr/lib/php5/20090626

echo "----------------------------------" 1>&2
echo "   copying bashrc files           " 1>&2
echo "----------------------------------" 1>&2
cd /tmp
wget --user=$SVNUSER --password=$SVNPASS http://svn.cleanpowerfinance.com/spt/branches/Project2.11/batch/setup/server/ci/bashrc
mv bashrc ~/.bashrc

echo "----------------------------------" 1>&2
echo "   Mysql user setup               " 1>&2
echo "----------------------------------" 1>&2   
SQL_QUERY="CREATE DATABASE IF NOT EXISTS protools;GRANT ALL ON *.* TO 'cpf_spt'@'localhost' IDENTIFIED BY 'sunshine';FLUSH PRIVILEGES;"
$MYSQLPATH -u root -e "$SQL_QUERY"

echo "----------------------------------" 1>&2
echo "   Misc setup               " 1>&2
echo "----------------------------------" 1>&2   
touch /var/log/php_errors.log
chmod 777 /var/log/php_errors.log

touch /var/log/xdebug.log
chmod 777 /var/log/xdebug.log

mkdir -p cd /var/lib/php5/session
chown root:www-data /var/lib/php5/session/
chmod 770 /var/lib/php5/session/

# setup timezone
echo "America/Los_Angeles" > /etc/timezone       

echo "----------------------------------" 1>&2
echo "   restart of apache " 1>&2
echo "----------------------------------" 1>&2
# restart apache
/etc/init.d/apache2 restart

echo "----------------------------------" 1>&2
echo "   Server setup is complete.              " 1>&2
echo "   Please remember to do a db import.     " 1>&2
echo "----------------------------------" 1>&2
