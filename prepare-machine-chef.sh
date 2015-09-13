#!/bin/bash
#
# This script is used as part of preparing a host as an AMI,
# and is typically piped over ssh:
#   ssh ubuntu@ec2-50-17-133-247.compute-1.amazonaws.com < prepare-machine-chef.sh
# It installs chef and sets up a client.rb such that on first boot, chef-client
# will configure itself from userdata, and write a new client.rb for future
# invocations.
# This is a bit of a hack; it'd be cleaner to have a separate service that
# runs at first boot

set -e
set -x

SUDO="sudo -E"

unset HISTFILE

export DEBIAN_FRONTEND=noninteractive

# install chef client, based loosely on
# http://wiki.opscode.com/display/chef/Installing+Chef+Client+on+Ubuntu+or+Debian
if [ ! -f /usr/bin/chef-client ]; then
  echo "chef    chef/chef_server_url    string  http://chef.example.com:4000/" | sudo debconf-set-selections
  if [ ! -f /etc/apt/sources.list.d/opscode.list ]; then
    echo "deb http://apt.opscode.com "`lsb_release -cs`"-0.10 main" | sudo dd of=/etc/apt/sources.list.d/opscode.list

    sudo mkdir -p /etc/apt/trusted.gpg.d
    gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
    gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null

    $SUDO apt-get update
    $SUDO apt-get install opscode-keyring # permanent upgradeable keyring
  fi

  # use policy-rc.d to prevent chef-client starting and registering before we write our custom client.rb
  sudo dd of=/usr/sbin/policy-rc.d <<EOP
#!/bin/sh
exit 101
EOP
  sudo chmod 755 /usr/sbin/policy-rc.d

  $SUDO apt-get install -y chef

  sudo rm -f /usr/sbin/policy-rc.d
fi

# Now write a client.rb that will use EC2 instance user data when a new instance boots
sudo cp /etc/chef/client.rb /etc/chef/client.rb.dist

sudo dd of=/etc/chef/client.rb <<'EOP'
# client.rb for first boot

@client_key_file="/etc/chef/client.pem"
@client_rb_new_filename = "/etc/chef/client.registered.rb"

def first_boot
  require 'ohai'
  require 'json'

  log_level        :info
  log_location     STDOUT

  warn "executing /etc/chef/client.rb for first boot"
  o = Ohai::System.new
  o.all_plugins
  raise "no ec2 data from Ohai. Could be a bad PATH" unless o[:ec2]

  # allow userdata.json to override EC2 metadata
  userdata_file="/etc/chef/userdata.json"
  if ::File.exists? userdata_file then
    warn "obtaining user_data from #{userdata_file}"
    userdata_content = IO.read(userdata_file)
  else
    warn "obtaining userdata from ohai"
    userdata_content = o[:ec2][:userdata]
    if userdata_content.kind_of?(Array)
     userdata_content = userdata_content[o[:ec2][:ami_launch_index]]
    end
  end
  raise "missing userdata" if userdata_content.nil? or userdata_content.empty?
  warn "got user data: #{userdata_content}"
  warn "parsing userdata"
  userdata = JSON.parse(userdata_content)
  warn "parsed userdata"

  raise "missing chef_server" if userdata["chef_server"].nil?
  raise "missing validation_key" if userdata["validation_key"].nil?

  chef_server_url userdata["chef_server"]
  warn "chef_server_url #{chef_server_url}"

  my_node_name = o[:ec2][:instance_id]
  if userdata.has_key?("attributes")
    if userdata["attributes"].has_key?("node_name_prefix")
      my_node_name = userdata["attributes"]["node_name_prefix"] + my_node_name
    end
    if userdata["attributes"].has_key?("node_name_override")
      my_node_name = userdata["attributes"]["node_name_override"]
    end

    attrs_file = "/etc/chef/attributes.json"
    Chef::Log.info "writing and loading #{attrs_file}"
    File.open(attrs_file, "w") do |f|
      f.print(JSON.pretty_generate(userdata["attributes"]))
    end

    json_attribs attrs_file
  end
  node_name my_node_name
  warn "node_name #{node_name}"

  ssl_verify_mode    :verify_none
  file_cache_path    "/var/cache/chef"
  file_backup_path   "/var/lib/chef/backup"
  pid_file           "/var/run/chef/client.pid"
  cache_options({ :path => "/var/cache/chef/checksums", :skip_expires => true})
  signing_ca_user "chef"
  Mixlib::Log::Formatter.show_time = true

  unless File.exists?("/etc/chef/validation.pem")
    File.open("/etc/chef/validation.pem", "w", 0600) do |f|
      f.print(userdata["validation_key"])
    end
  end

  warn "writing to #{@client_rb_new_filename}"
  new_client_rb = File.open(@client_rb_new_filename, 'w')
  new_client_rb.write <<END
# this client.rb was created by ./client.rb.firstboot

# if your roles get lost, uncomment the following line and re-run
# json_attribs '/etc/chef/attributes.json'

log_level        :info
log_location     STDOUT
chef_server_url    "#{chef_server_url}"
node_name          "#{node_name}"
ssl_verify_mode    :verify_none
file_cache_path    "/var/cache/chef"
file_backup_path   "/var/lib/chef/backup"
pid_file           "/var/run/chef/client.pid"
cache_options({ :path => "/var/cache/chef/checksums", :skip_expires => true})
signing_ca_user "chef"
Mixlib::Log::Formatter.show_time = true
END

  if userdata.has_key?("environment")
    my_environment = userdata["environment"]
    environment my_environment
    new_client_rb.write("environment \"#{environment}\"\n")
  end

  new_client_rb.close
  warn "closed #{@client_rb_new_filename}"

  ::File.rename('/etc/chef/client.rb', '/etc/chef/client.rb.firstboot')
  ::File.rename(@client_rb_new_filename, '/etc/chef/client.rb')
end

first_boot

EOP

$SUDO apt-get install -y libxml2-dev libxslt1-dev
sudo gem install --no-rdoc --no-ri --verbose --include-dependencies fog knife-ec2 highline net-ssh net-ssh-multi
