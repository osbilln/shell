#!/bin/bash



mkdir /data

# apt-get install tomcat7 apache2 apache2-mpm-prefork apache2-utils  apache2.2-bin apache2.2-common libapache2-mod-jk libapache2-mod-php5 libapache2-mod-proxy-html

tar zcvf /tmp/tomcat-7-aio.tar.gz /usr/share/tomcat7 /usr/share/doc/tomcat7-common  /usr/share/tomcat7-root /usr/share/doc/tomcat7 /var/log/tomcat7 /var/cache/tomcat7 /var/lib/tomcat7 /etc/init.d/tomcat7 /etc/tomcat7 /var/lib/tomcat7/ /usr/share/tomcat7 /usr/share/doc/tomcat7-common

tar zcvf /tmp/data-aio.tar.gz /var/www
tar zcvf /tmp/apache2-aio.tar.gz /etc/apache2 /etc/libapache2-mod-jk /etc/ssl
tar zcvf /tmp/search-aio.tar.gz /data/totvslabs
tar zcvf /tmp/jdk1.7.0_40tar.tar.gz /opt/jdk1.7.0_40

