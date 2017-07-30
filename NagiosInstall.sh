#!/bin/bash

case "$1" in

5)

	### add nagios monitoring packages
	rpm -ivh http://192.168.150.6/linux/CentOS/5.8/extras/x86_64/Packages/nrpe-2.13-1.el5.x86_64.rpm
	mv /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg.0
	### Install STO monitoring config file
	wget -P /etc/nagios/ http://192.168.150.6/linux/STO/STO_repo.local/x86_64/nrpe/nrpe.cfg
	### install xinetd file, from previously install xinetd package 
	wget -P /etc/xinetd.d/ http://192.168.150.6/linux/STO/STO_repo.local/x86_64/nrpe/nrpe
	### get nagios plugin payload all packages, rather than individual files
	wget -P /usr/lib64/nagios/ http://192.168.150.6/linux/CentOS/5.8/extras/x86_64/Packages/nagios-plugins_el5.tgz
	cd /usr/lib64/nagios/
	tar xzf /usr/lib64/nagios/nagios-plugins_el5.tgz
	;;

6)
	### add xinetd package again.  xinetd package config does not seem to install
	rpm -ivh http://192.168.150.6/linux/CentOS/6.3/os/x86_64/Packages/xinetd-2.3.14-34.el6.x86_64.rpm
	### add nagios monitoring packages
	rpm -ivh http://192.168.150.6/linux/CentOS/6.3/extras/x86_64/Packages/nrpe-2.13-1.el6.x86_64.rpm
	mv /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg.0
	### Install STO monitoring config file
	wget -P /etc/nagios/ http://192.168.150.6/linux/STO/STO_repo.local/x86_64/nrpe/nrpe.cfg
	### install xinetd file, from previously install xinetd package 
	wget -P /etc/xinetd.d/ http://192.168.150.6/linux/STO/STO_repo.local/x86_64/nrpe/nrpe
	### get nagios plugin payload all packages, rather than individual files
	wget -P /usr/lib64/nagios/ http://192.168.150.6/linux/CentOS/5.8/extras/x86_64/Packages/nagios-plugins_el5.tgz
	cd /usr/lib64/nagios/
	tar xzf /usr/lib64/nagios/nagios-plugins_el5.tgz
	;;
*)
	echo usage $0 5|6 
	;;
esac





