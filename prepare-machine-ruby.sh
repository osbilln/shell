#!/bin/bash
#
# Install Ruby via RVM, into our user directory, and install some common gems

set -e
set -x

SUDO="sudo -E"

unset HISTFILE

export DEBIAN_FRONTEND=noninteractive

MY_USER=changeme
MY_GROUP=changeme

sudo addgroup $MY_GROUP --gid 8989
sudo adduser --gecos "$MY_USER User" --uid 8989 --ingroup $MY_GROUP --disabled-password $MY_USER

# ruby dependencies, from the RVM notes that get displayed when you do "rvm install"
$SUDO apt-get install -y curl git patch
$SUDO apt-get install -y build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config

# install RVM, ruby, and some common gems
( cat <<'EOP'
 MY_RUBY=1.9.3.-p0
 MY_GEMSET=changeme

 echo "downloading RVM"
 curl -L -s --output rvm-install.bash https://get.rvm.io
 echo "installing RVM"
 bash -s stable < rvm-install.bash
 echo "loading RVM"
 source ".rvm/scripts/rvm"
 rvm install $MY_RUBY
 rvm use $MY_RUBY
 rvm gemset create $MY_GEMSET
 rvm $MY_RUBY@$MY_GEMSET
 gem install bundler --no-rdoc --no-ri
 gem install json
 gem install etc
 gem install nokogiri
 gem install amqp --pre
 gem install amqp-utils
 gem install bunny
EOP
) | sudo -i -u $MY_USER bash

# bash script to show RVM info and git repo in your bash prompt
(base64 -d <<EOM
IyBiYXNoIHNjcmlwdCB0byBzaG93IFJWTSBpbmZvIGFuZCBnaXQgcmVwbyBpbiB5b3VyIGJhc2gg
cHJvbXB0CiMgaW5zdGFsbGVkIGR1cmluZyB0aGUgQU1JIGNyZWF0aW9uIHByb2Nlc3MgYnkgcHJl
cGFyZS1tYWNoaW5lLXJ1Ynkuc2gKCmlmIFsgLWYgIiRIT01FLy5ydm0vc2NyaXB0cy9ydm0iIF0g
OyB0aGVuCiAgLiAiJEhPTUUvLnJ2bS9zY3JpcHRzL3J2bSIKZmkKClsgLXogIiRQUzEiIF0gJiYg
cmV0dXJuClsgLXogIiRCQVNIIiBdICYmIHJldHVybgoKZnVuY3Rpb24gZmluZF9naXRfYnJhbmNo
IHsKICBsb2NhbCBkaXI9LiBoZWFkCiAgdW50aWwgWyAiJGRpciIgLWVmIC8gXTsgZG8KICAgIGlm
IFsgLWYgIiRkaXIvLmdpdC9IRUFEIiBdOyB0aGVuCiAgICAgIGhlYWQ9JCg8ICIkZGlyLy5naXQv
SEVBRCIpCiAgICAgIGlmIFtbICRoZWFkID09IHJlZjpcIHJlZnMvaGVhZHMvKiBdXTsgdGhlbgog
ICAgICAgIGdpdF9icmFuY2g9Ilske2hlYWQjIyovfV0gIgogICAgICBlbGlmIFtbICRoZWFkICE9
ICcnIF1dOyB0aGVuCiAgICAgICAgZ2l0X2JyYW5jaD0nW2RldGFjaGVkXSAnCiAgICAgIGVsc2UK
ICAgICAgICBnaXRfYnJhbmNoPSdbdW5rbm93bl0gJwogICAgICBmaQogICAgICByZXR1cm4KICAg
IGZpCiAgICBkaXI9Ii4uLyRkaXIiCiAgZG9uZQogIGdpdF9icmFuY2g9JycKfQoKUFJPTVBUX0NP
TU1BTkQ9ImZpbmRfZ2l0X2JyYW5jaDsgJFBST01QVF9DT01NQU5EIgoKUkVEPSJcXFtcXDAzM1sz
MW1cXF0iCkdSRUVOPSJcXFtcXDAzM1szMm1cXF0iCllFTExPVz0iXFxbXFwwMzNbMzNtXFxdIgpC
TFVFPSJcXFtcXDAzM1szNG1cXF0iCk1BR0VOVEE9IlxcW1xcMDMzWzM1bVxcXSIKV0hJVEU9Ilxc
W1xcMDMzWzBtXFxdIgogIAppZiBbICIkcnZtX3ZlcnNpb24iIF07IHRoZW4KICBQUzE9IiRSRURc
dUBcaCRCTFVFXCQoJEhPTUUvLnJ2bS9iaW4vcnZtLXByb21wdCB1IHYgZ3xzZWQgLUUgJ3MjXihb
XlxzXSkjIFwxIycpICRHUkVFTlxXICRNQUdFTlRBXCRnaXRfYnJhbmNoJEdSRUVOJCAkV0hJVEUi
CmVsc2UKICBQUzE9IiRSRURcdUBcaCAkV0hJVEVcISAkR1JFRU5cVyAkTUFHRU5UQVwkZ2l0X2Jy
YW5jaCRHUkVFTiQgJFdISVRFIgpmaQo=
EOM
) | sudo dd of=/home/$MY_USER/.rvm-git-prompt.sh
sudo chown $MY_USER:$MY_GROUP /home/$MY_USER/.rvm-git-prompt.sh
