# knife bootstrap 10.0.10.245

APP=/Users/billnguyen/chef/totvs/keys/FluigIdentityProductionServers.pem
KEYSTORE=/Users/billnguyen/chef/totvs/keys/FluigIdentityProductionKeystoreServers.pem
CLOUDPASS=/Users/billnguyen/chef/totvs/keys/CloudpassServers.pem
BILLKEY=~billnguyen/.ssh/id_rsa

if [ ! -n "$2" ]
then
  echo "Usage: `basename $0` servername cookbook etc."
  exit $E_BADARGS
fi

SERVER=$1
ROLE=$2

knife bootstrap $SERVER \
	--ssh-port 22 \
	--ssh-user fluig\
	-i $BILLKEY \
 	--sudo \
	--run-list "role[$ROLE]"
