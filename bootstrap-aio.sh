CLOUDPASS=/Users/billnguyen/chef/totvs/keys/CloudpassServers.pem
BILLKEY=~billnguyen/.ssh/id_rsa

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` server name etc."
  exit $E_BADARGS
fi

SERVER=$1

knife bootstrap $1 --ssh-port 22 --ssh-user root -i /Users/billnguyen/.ssh/id_rsa -r 'role[fi-aio]' --sudo
