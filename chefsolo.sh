#!/bin/bash
set -e -x
export DEBIAN_FRONTEND=noninteractive

# tell apt-get about the opscode package repository
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | tee /etc/apt/sources.list.d/opscode.list

#get the opscode keys
mkdir -p /etc/apt/trusted.gpg.d
gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null

# update the apt library with the current versions
apt-get --yes --quiet update

# install the opscode key permanently
apt-get install opscode-keyring

# install Chef (the echo part passes in a few required variables, otherwise the chef installer prompts the user.)
echo "chef chef/chef_server_url string none" | debconf-set-selections && apt-get install chef -y

# install 'git' (required to get the cookbook repository)
apt-get --yes --quiet install git-core

# checkout the Opscode cookbook repository.
cd /var
git clone git://github.com/opscode/chef-repo.git

# use the chef 'knife' utility to grab the cookbook(s) we want
sudo knife cookbook site install wordpress --cookbook-path /var/chef-repo/cookbooks

# create the minimal config file needed for chef solo
echo -e 'file_cache_path "/var/chef-repo"\ncookbook_path "/var/chef-repo/cookbooks"' | tee /etc/chef/solo.rb

# create the 'node' config file (tells Chef what cookbooks to apply to 'me')
# note: the cookbooks themselves will look for these config settings.
echo -e '{
    "wordpress": {
        "db": {
            "database": "wordpress",
            "user": "admin",
            "password": "admin",
            "host": "localhost"
          }
      },
    "run_list": ["recipe[wordpress]"]
}' | tee /etc/chef/node.json

# kick off chef-solo
sudo chef-solo -j /etc/chef/node.json &> /tmp/myscript.log

# create a 'done' file so other scripts can know we're all finished.
touch /home/ubuntu/complete
