#!/bin/bash
#
# Update a freshly installed Ubuntu

set -e
set -x

SUDO="sudo -E"

# prevent ~ubuntu/.bash_history showing these commands
unset HISTFILE

export DEBIAN_FRONTEND=noninteractive

# install aptitude, a high-level interface to the package manager
$SUDO apt-get install aptitude

# enable multiverse repository
egrep " multiverse\$" /etc/apt/sources.list | sed "s/^# *//" | sudo dd of=/etc/apt/sources.list.d/multiverse.list

# update the list of available packages from the apt sources
$SUDO aptitude update

# upgrade installed packages to their most recent version
$SUDO aptitude safe-upgrade --quiet --assume-yes
