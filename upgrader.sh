#!/bin/bash -x

function usage() {
  echo "upgrader v0.3"
  echo ""
  echo "upgrader.sh OPTIONS DASHBOARD_NAME"
  echo ""
  echo "Valid options:"
  echo "     -t --tagname			Tag Name (Default: trunk)"
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

while getopts ":ht:c:i:v:q:-:" opt; do
 case $opt in
  -)
     case "${OPTARG}" in
       tagname)
         TAG_NAME="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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

echo "Upgrading $DASHBOARD_NAME to tag $TAG_NAME"
if [[ $CLONE_DASHBOARD != "" ]]; then
  echo "From clone of $CLONE_DASHBOARD ($CLONE_DB_HOST)"
fi

DIR_NAME=`echo $DASHBOARD_NAME | tr A-Z a-z | sed "s/dashboard/-dashboard/"`
CLONE_DASHBOARD_DIR=`echo $CLONE_DASHBOARD | tr A-Z a-z | sed "s/dashboard/-dashboard/"`

cd $DIR_NAME

# load existing config
source base-dashboard.properties

export DB_NAME=${schema_name}
export DB_HOST=${dbHost}
export DB_USER=`grep username conf/Catalina/localhost/dashboard.xml | sed s/\"\//g | sed s/username\=//`
export DB_PW=`grep password conf/Catalina/localhost/dashboard.xml | sed s/\"\//g | sed s/password\=//`


# Shutdown
cd bin

./shutdown.sh

cd ..


# setup ssh-agent
eval `ssh-agent`
ssh-add /home/naehas/.au/id_rsa

if [[ "$TAG_NAME" != "trunk" ]]; then
  TAG_NAME="tags/$TAG_NAME"
fi

svn info svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/$TAG_NAME > SVN_INFO

# clean up old directories to handle files deleted in the new version
# we don't remove everything because we want to keep logs, downloads, etc.
rm -rf bin
rm -rf conf
rm -rf endorsed
rm -rf lib
rm -rf scripts
rm -rf src
rm -f webapps/dashboard/*
rm -rf webapps/dashboard/resources
rm -rf webapps/dashboard/scripts
rm -rf webapps/dashboard/styles
rm -f webapps/dashboard/WEB-INF/*
rm -rf webapps/dashboard/WEB-INF/lib
rm -rf webapps/dashboard/WEB-INF/classes
rm -rf webapps/dashboard/WEB-INF/build
rm -rf webapps/dashboard/WEB-INF/jsp
rm -rf webapps/dashboard/WEB-INF/lib
rm -rf webapps/dashboard/WEB-INF/messages
rm -rf webapps/dashboard/WEB-INF/tiles
rm -rf work

# svn export
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/$TAG_NAME . --force

if [[ $CLONE_DASHBOARD != "" ]]; then
  # clone customizations

  ../cloner-copy.sh

  ./customize -clone:$CLONE_DASHBOARD_DIR

fi

if [[ $CLONE_DASHBOARD != "" ]]; then

  ../cloner-load.sh

fi

./setup -n

# startup
cd bin

ps aux | grep $DIR_NAME

BUILD_ID=dontKillDashboard ./startup.sh

cd ..

sleep 60

#cleanup
ssh-agent -k

