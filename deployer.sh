#!/bin/bash -x

function usage() {
  echo "deployer v0.23"
  echo ""
  echo "deployer.sh OPTIONS DASHBOARD_NAME"
  echo ""
  echo "Valid options:"
  echo "     -t --tagname			Tag Name (Default: trunk)"
  echo "     -p --proxyhost			Proxy Host Name (Default: 127.0.0.1).  Host must be accessible by SSH and have correct sudo permissions."
  echo "     -d --dbhost			Database Host (Default: 127.0.0.1).  Host must be accessible by mysql."
  echo "     -u --dbusername		Database Username (Default: none).  User must have permissions to create database."
  echo "     -w --dbpassword		Database Password (Default: none)"
  echo "     -c --clonedashboard	Dashboard Name to clone (Default: none)"
  echo "     -i --clonedbhost		Database Host to clone from (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -v --clonedbusername	Username to access clone database (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -q --clonedbpassword	Password to access clone database (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -h --help          	Display this help."
  exit 0
}

#defaults!

PROXY_HOST=127.0.0.1
TAG_NAME=trunk
DB_HOST=127.0.0.1


while getopts ":ht:p:d:u:w:c:i:v:q:-:" opt; do
 case $opt in
  -)
     case "${OPTARG}" in
       tagname)
         TAG_NAME="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       proxyhost)
         PROXY_HOST="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       dbhost)
         DB_HOST="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       dbusername)
         DB_USER="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       dbpassword)
         DB_PW="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       clonedashboard)
         CLONE_DASHBOARD="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       clonedbhost)
         CLONE_DB_HOST="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       clonedbusername)
         CLONE_DB_USER="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       clonedbpassword)
         CLONE_DB_PW="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       help)
         usage
         ;;
       *)
         echo "Unknown parameter: $OPTARG" >&2 && exit 1;
         ;;
     esac
     ;;
  t) TAG_NAME=$OPTARG
     ;;
  p) PROXY_HOST=$OPTARG
     ;;
  d) DB_HOST=$OPTARG
     ;;
  u) DB_USER=$OPTARG
     ;;
  w) DB_PW=$OPTARG
     ;;
  c) CLONE_DASHBOARD=$OPTARG
     ;;
  i) CLONE_DB_HOST=$OPTARG
     ;;
  v) CLONE_DB_USER=$OPTARG
     ;;
  q) CLONE_DB_PW=$OPTARG
     ;;
  h) usage
     ;;
 esac
done

DASHBOARD_NAME=${!OPTIND}

echo "Creating $DASHBOARD_NAME ($DB_HOST) from tag $TAG_NAME Proxy: $PROXY_HOST"
if [[ $CLONE_DASHBOARD != "" ]]; then
  echo "From clone of $CLONE_DASHBOARD ($CLONE_DB_HOST)"
fi

DIR_NAME=`echo $DASHBOARD_NAME | tr A-Z a-z | sed "s/dashboard/-dashboard/"`
CLONE_DASHBOARD_DIR=`echo $CLONE_DASHBOARD | tr A-Z a-z | sed "s/dashboard/-dashboard/"`
#make directory
mkdir $DIR_NAME

cd $DIR_NAME

# setup ssh-agent
eval `ssh-agent`
ssh-add /home/naehas/.au/id_rsa

if [[ "$TAG_NAME" != "trunk" ]]; then
  TAG_NAME="tags/$TAG_NAME"
fi

# svn export
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/$TAG_NAME . --force
svn info svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/$TAG_NAME > SVN_INFO

#setup params

if [[ $CLONE_DASHBOARD != "" ]]; then
  # clone customizations

  ../cloner-copy.sh

  ./customize -clone:$CLONE_DASHBOARD_DIR

  # remove the clone dashboard properties
  # we want to revert to defaults for these things - port number, database name, database host, dashboard name, etc.

  rm base-dashboard.properties

fi


echo "dbHost=$DB_HOST" >> base-dashboard.properties
echo "PROXY_HOST_NAME=$PROXY_HOST" >> base-dashboard.properties
echo "URL=$DASHBOARD_NAME" >> base-dashboard.properties

./setup -n

if [[ $CLONE_DASHBOARD != "" ]]; then

  ../cloner-load.sh

fi


# setup apache
URL=$DASHBOARD_NAME
./setup-proxy $PROXY_HOST

# startup
cd bin

BUILD_ID=dontKillNewDashboard ./startup.sh

cd ..

sleep 60

if [[ $CLONE_DASHBOARD = "" ]]; then

  #only create initial campaign if we are not cloning
  ant c0

fi

#cleanup
ssh-agent -k

