#!/bin/bash
##-------------------------------------------------------------------
## File : install_chef_solo.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-08-04>
## Updated: Time-stamp: <2014-09-19 00:12:08>
##-------------------------------------------------------------------
. $(dirname $0)/fluig_chef_utility.sh

function install_chef_solo()
{
    log "Install chef-solo"

    os_version=${1?}
    if [ "$os_version" == "ubuntu" ]; then
        ubuntu_conf_apt_source

        apt-get install -y ruby1.9.1
        apt-get install -y ruby1.9.1-dev
        apt-get install -y build-essential
        log "make sure ruby --version >=1.9.1"
        if [ -f /usr/bin/ruby1.9.1 ]; then
            rm -rf /usr/bin/ruby && ln -s /usr/bin/ruby1.9.1 /usr/bin/ruby
        else
            log "Error: ruby version should be >= 1.9.1"
            exit 1
        fi
    elif [ "$os_version" == "redhat" ] || [ "$os_version" == "centos" ]; then
        # install epel repo
        if ! rpm -q epel-release 1>/dev/null; then
            wget -O /tmp/epel-release-6-8.noarch.rpm http://mirror-fpt-telecom.fpt.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
            rpm -ivh /tmp/epel-release-6-8.noarch.rpm
        fi
        # install ruby and rubygem
        yum groupinstall -y "Development Tools"
        yum install -y curl wget git
        yum install -y libyaml libyaml-devel zlib-devel openssl-devel
        if which ruby 1>/dev/null 2>/dev/null; then
            ruby_version=$(ruby --version | awk -F' ' '{print $2}')
        else
            ruby_version=""
        fi
        if [ "$ruby_version" != "1.9.3p547" ]; then
            log "install ruby 1.9.3"
            working_dir="/tmp/$$"
            mkdir $working_dir
            cd $working_dir
            wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p547.tar.gz

            tar xvzf ruby-1.9.3-p547.tar.gz
            cd ruby-1.9.3-p547

            cd ./ext/psych
            ruby extconf.rb
            cd -

            cd ./ext/zlib
            ruby extconf.rb
            cd -

            ./configure
            make
            make install

            log "link ruby"
            [ ! -f /usr/bin/ruby ] || rm -rf /usr/bin/ruby
            ln -s /usr/local/bin/ruby /usr/bin/ruby

            log "install ruby gem"
            cd $working_dir
            wget http://production.cf.rubygems.org/rubygems/rubygems-2.4.1.tgz
            tar xvzf rubygems-2.4.1.tgz
            cd rubygems-2.4.1
            ruby setup.rb
            cd /tmp/

            rm -rf $working_dir
        fi
    else
        log "Error: Not supported version"
    fi

    # install chef-solo
    which chef-solo 1>/dev/null
    status=$?
    if [ $status -ne 0 ]; then
        log "gem install chef. This shall take several minutes."
        gem install chef --no-ri --no-rdoc
    fi
    $(gem list | grep ruby-shadow 1>/dev/null) || gem install ruby-shadow

    # link chef-solo
    if [ -f /usr/local/bin/chef-solo ]; then
        if [ ! -f /usr/bin/chef-solo ]; then
            ln -s /usr/local/bin/chef-solo /usr/bin/chef-solo
        fi
    fi
}

ensure_is_root
install_chef_solo $(os_release)

log "install_chef_solo.sh ends"
## File : install_chef_solo.sh ends
