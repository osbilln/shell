#!/bin/bash
#
# Install software packages and basic configuration

set -e
set -x

SUDO="sudo -E"

unset HISTFILE

export DEBIAN_FRONTEND=noninteractive

$SUDO apt-get install -y openjdk-7-jre-headless
$SUDO apt-get install -y openjdk-7-jdk
sudo update-alternatives --auto java

# add a hold on openjdk so it is not updated behind us with unintended consequences
for pkg in `dpkg -l '*java*' | grep '^ii' | awk '{print $2}'` ; do
 echo $pkg hold | sudo dpkg --set-selections
done

# install build tools, ec2 tools and sysadmin tools
$SUDO apt-get install -y build-essential binutils-doc autoconf flex bison \
  s3cmd  \
  xfsprogs dstat sysstat iotop ntp git \
  debconf-utils wipe file strace screen tmux \
  zip unzip sqlite3

# the runit cookbook does this; not sure why
sudo /usr/bin/debconf-set-selections <<EOM
runit   runit/signalinit        boolean true
EOM
$SUDO apt-get install -y runit

# keep logins quiet
touch $HOME/.hushlogin

# disable pam in sshd logins because it sometimes causes hangs
sudo perl -pi.bak -e "s/session +optional +pam_motd.so/#session optional pam_motd.so/" /etc/pam.d/sshd
