#!/bin/bash -x

die() {
  if [[ "$1" = "" ]] ; then
    echo "Exiting program due to error."
  else
    echo $1
  fi
  exit 1
}
function usage() {
  echo "upgrader v0.3"
  echo ""
  echo "upgrader.sh OPTIONS DASHBOARD_NAME"
  echo ""
  echo "Valid options:"
  echo "     -b --dashboardname		The dashboard name (Example: MyNewDashboard)"   
  echo "     -t --tagname			Tag Name (Default: trunk)"
  echo "     -c --clonedashboard	Dashboard Name to clone (Default: none)"
  echo "     -i --clonedbhost		Database Host to clone from (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -v --clonedbusername	Username to access clone database (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -q --clonedbpassword	Password to access clone database (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -y --deploydb			Deploy DB (Default: true)"
  echo "     -k --locktablesonclone	Lock tables on clone (Default: true)"  
  echo "     -h --help          	Display this help."
  exit 0
}

#defaults!

PROXY_HOST=127.0.0.1
TAG_NAME=trunk
DB_HOST=127.0.0.1
DEPLOY_DB=true

while getopts ":ht:c:i:v:q:y:b:k:-:" opt; do
 case $opt in
  -)
     case "${OPTARG}" in
       dashboardname)
         DASHBOARD_NAME="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;       
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
       deploydb)
         DEPLOY_DB="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;  
       locktablesonclone)
         LOCK_TABLES_ON_CLONE="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;          
       help)
         usage
         ;;
       *)
         echo "Unknown parameter: $OPTARG" >&2 && exit 1;
         ;;
     esac
     ;;
  b) DASHBOARD_NAME=$OPTARG
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
  y) DEPLOY_DB=$OPTARG
     ;;   
  k) LOCK_TABLES_ON_CLONE=$OPTARG
     ;;       
  h) usage
     ;;
 esac
done

echo "e-upgrader DASHBOARD_NAME=$DASHBOARD_NAME"

echo "e-upgrader TAG_NAME=$TAG_NAME"

echo "e-upgrader CLONE_DASHBOARD=$CLONE_DASHBOARD"

echo "e-upgrader CLONE_DB_HOST=$CLONE_DB_HOST"

echo "e-upgrader CLONE_DB_USER=$CLONE_DB_USER"

echo "e-upgrader CLONE_DB_PW=$CLONE_DB_PW"

echo "e-upgrader DEPLOY_DB=$DEPLOY_DB"

echo "e-upgrader LOCK_TABLES_ON_CLONE=$LOCK_TABLES_ON_CLONE"


echo "The dashboard name is ${DASHBOARD_NAME}. Checking !OPTIND value ${!OPTIND}."
if [[ ${!OPTIND} != false ]]; then
  echo "Setting dashboard name from ${DASHBOARD_NAME} to ${!OPTIND} "
  DASHBOARD_NAME=${!OPTIND}
fi

echo "Upgrading $DASHBOARD_NAME to tag $TAG_NAME"
if [[ $CLONE_DASHBOARD != "" ]]; then
  echo "From clone of $CLONE_DASHBOARD ($CLONE_DB_HOST)"
fi

DIR_NAME=`echo $DASHBOARD_NAME | tr A-Z a-z | sed "s/dashboard/-dashboard/"`
CLONE_DASHBOARD_DIR=`echo $CLONE_DASHBOARD | tr A-Z a-z | sed "s/dashboard/-dashboard/"`

cd $DIR_NAME || die "$DIR_NAME does not exist"

# load existing config
source base-dashboard.properties

export DB_NAME=${schema_name}
export DB_HOST=${dbHost}
export DB_USER=`grep username conf/Catalina/localhost/dashboard.xml | sed s/\"\//g | sed s/username\=//`
export DB_PW=`grep password conf/Catalina/localhost/dashboard.xml | sed s/\"\//g | sed s/password\=//`


# Shutdown
cd bin || die "bin does not exist"

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

# override scripts since it might be outdated FRED-19118
echo "Overriding scripts since they might be outdated on older tags FRED-19118"
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/trunk/scripts/create-first-campaign scripts/create-first-campaign --force
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/trunk/scripts/make-base-config scripts/make-base-config --force
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/trunk/setup setup --force

if [[ $CLONE_DASHBOARD != "" ]]; then
  # clone customizations

  ../e-cloner-copy.sh

  ./customize -clone:$CLONE_DASHBOARD_DIR

fi

if [[ $CLONE_DASHBOARD != "" ]]; then

  ../e-cloner-load.sh

fi

./setup -n

cd /usr/java;
./setup_newrelic.sh $DIR_NAME
cd $DIR_NAME

# startup
cd bin

ps aux | grep $DIR_NAME

BUILD_ID=dontKillDashboard ./startup.sh

cd ..

sleep 60

#cleanup
ssh-agent -k

