#!/bin/bash -x

function usage() {
  echo "deployer v0.23"
  echo ""
  echo "deployer.sh OPTIONS DASHBOARD_NAME"
  echo ""
  echo "Valid options:"
  echo "     -b --dashboardname		The dashboard name (Example: MyNewDashboard)"  
  echo "     -l --baseurl			Base URL (Default: https://dashboard.naehas.com)"
  echo "     -t --tagname			Tag Name (Default: trunk)"
  echo "     -y --deploydb			Deploy DB (Default: true)"  
  echo "     -k --locktablesonclone	Lock tables on clone (Default: true)"  
  echo "     -p --proxyhost			Proxy Host Name (Default: 127.0.0.1).  Host must be accessible by SSH and have correct sudo permissions."
  echo "     -d --dbhost			Database Host (Default: 127.0.0.1).  Host must be accessible by mysql."
  echo "     -u --schemaUser		Database Username (Default: none).  User must have permissions to create database."
  echo "     -w --schemaPassword		Database Password (Default: none)"
  echo "     -c --clonedashboard	Dashboard Name to clone (Default: none)"
  echo "     -i --clonedbhost		Database Host to clone from (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -v --clonedbusername	Username to access clone database (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -q --clonedbpassword	Password to access clone database (Default: none).  Not used if --clone_dashboard is not set"
  echo "     -h --help          	Display this help."
  exit 0
}

#defaults!
echo "Setting deployer defaults"
PROXY_HOST=127.0.0.1
TAG_NAME=trunk
DB_HOST=127.0.0.1
echo "args: $@"

while getopts ":ht:p:d:u:w:c:i:v:q:l:y:b:k:r:s:x:-:" opt; do
 case $opt in
  -)
     case "${OPTARG}" in
       dashboardname)
         DASHBOARD_NAME="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;     
       baseurl)
         BASE_URL="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       tagname)
         TAG_NAME="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       deploydb)
         DEPLOY_DB="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;  
       locktablesonclone)
         LOCK_TABLES_ON_CLONE="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;    
       proxyhost)
         PROXY_HOST="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       dbhost)
         DB_HOST="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       schemaUser)
         DB_USER="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       schemaPassword)
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
       saveclone)
         SAVE_CLONE="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       usesavedclone)
         USE_SAVED_CLONE="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       clonefilename)
         CLONE_FILE_NAME="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
  l) BASE_URL=$OPTARG
     ;;
  t) TAG_NAME=$OPTARG
     ;;
  y) DEPLOY_DB=$OPTARG
     ;;
  k) LOCK_TABLES_ON_CLONE=$OPTARG
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
  r) SAVE_CLONE=$OPTARG
     ;;
  s) USE_SAVED_CLONE=$OPTARG
     ;;
  x) CLONE_FILE_NAME=$OPTARG
     ;;
  h) usage
     ;;
 esac
done

echo "e-deployer DASHBOARD_NAME=$DASHBOARD_NAME"

echo "e-deployer BASE_URL=$BASE_URL"

echo "e-deployer TAG_NAME=$TAG_NAME"

echo "e-deployer DEPLOY_DB=$DEPLOY_DB"

echo "e-deployer LOCK_TABLES_ON_CLONE=$LOCK_TABLES_ON_CLONE"

echo "e-deployer PROXY_HOST=$PROXY_HOST"

echo "e-deployer DB_HOST=$DB_HOST"

echo "e-deployer DB_USER=$DB_USER"

echo "e-deployer DB_PW=$DB_PW"

echo "e-deployer CLONE_DASHBOARD=$CLONE_DASHBOARD"

echo "e-deployer CLONE_DB_HOST=$CLONE_DB_HOST"

echo "e-deployer CLONE_DB_USER=$CLONE_DB_USER"

echo "e-deployer CLONE_DB_PW=$CLONE_DB_PW"

echo "e-deployer SAVE_CLONE=$SAVE_CLONE"

echo "e-deployer USE_SAVED_CLONE=$USE_SAVED_CLONE"

echo "e-deployer CLONE_FILE_NAME=$CLONE_FILE_NAME"


#echo "The dashboard name is ${DASHBOARD_NAME}. Checking !OPTIND value ${!OPTIND}."
#if [[ ${!OPTIND} != false ]]; then
#    if [[ ${!OPTIND} != true ]]; then
#        echo "Setting dashboard name from ${DASHBOARD_NAME} to ${!OPTIND} "
#        DASHBOARD_NAME=${!OPTIND}
#    fi
#fi

echo "Creating $DASHBOARD_NAME ($DB_HOST) from tag $TAG_NAME Proxy: $PROXY_HOST with Base URL: $BASE_URL and Deploy DB: $DEPLOY_DB"
if [[ $CLONE_DASHBOARD != "" ]]; then
  echo "From clone of $CLONE_DASHBOARD ($CLONE_DB_HOST)"
fi

CLONE_DB_NAME=`echo $CLONE_DASHBOARD | tr -C -d 'A-Z0-9a-z' | tr 'A-Z' 'a-z' | sed s/dashboard//`
echo "CLONE_DB_NAME is ${CLONE_DB_NAME}"

DIR_NAME=`echo $DASHBOARD_NAME | tr A-Z a-z | sed "s/dashboard/-dashboard/"`
CLONE_DASHBOARD_DIR=`echo $CLONE_DASHBOARD | tr A-Z a-z | sed "s/dashboard/-dashboard/"`
#make directory
mkdir $DIR_NAME

cd $DIR_NAME

# setup ssh-agent
eval `ssh-agent`
ssh-add /home/naehas/.au/id_rsa

echo "Deploying with TAG_NAME=$TAG_NAME"
if [[ "$TAG_NAME" != "trunk" ]]; then
  TAG_NAME="tags/$TAG_NAME"
fi

# svn export
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/$TAG_NAME . --force
svn info svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/$TAG_NAME > SVN_INFO

# override scripts since it might be outdated FRED-19118
echo "Overriding scripts since they might be outdated on older tags FRED-19118"
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/trunk/scripts/create-first-campaign scripts/create-first-campaign --force
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/trunk/scripts/make-base-config scripts/make-base-config --force
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/trunk/setup setup --force
svn export svn+ssh://svn.naehas.com/home/svn/repository/base-dashboard/trunk/setup-haproxy /home/naehas/proxy-bin/setup-haproxy --force

#setup params

if [[ $CLONE_DASHBOARD != "" ]]; then
  # clone customizations

  if [[ "$USE_SAVED_CLONE" = "false" ]] ; then
  	../e-cloner-copy.sh
  else
  	cp /nfs1/db-clones/$CLONE_FILE_NAME.sql.gz $CLONE_DB_NAME.sql.gz
        cp /nfs1/db-clones/${CLONE_FILE_NAME}_staging.sql.gz ${CLONE_DB_NAME}_staging.sql.gz 
  fi

  ./customize -clone:$CLONE_DASHBOARD_DIR

  # remove the clone dashboard properties
  # we want to revert to defaults for these things - port number, database name, database host, dashboard name, etc.

  rm base-dashboard.properties
fi

# Adds or updates an environment variable of base-dashboard.cfg
function AddOrUpdateCfg {
  PROP="$1"
  VALUE="$2"
  BDC="base-dashboard.properties"
  while [[ "$VALUE" != "${VALUE# }" ]] ; do
    VALUE="${VALUE# }"
  done
  while [[ "$VALUE" != "${VALUE% }" ]] ; do
    VALUE="${VALUE% }"
  done
  if [[ ! -f $BDC ]] ; then
    touch $BDC
  fi
  if egrep -q "^${PROP}=" $BDC ; then
    # update
    sed -i "s#^${PROP}=.*#${PROP}=$VALUE#" $BDC
  else
    # insert
    echo "${PROP}=$VALUE" >> $BDC
  fi
}

var=$(grep -w dbHost base-dashboard.properties | sed s/dbHost\=//)
if [[ $var != $DB_HOST ]]; then
  AddOrUpdateCfg dbHost "$DB_HOST"
  # echo "dbHost=$DB_HOST" >> base-dashboard.properties
fi

var=$(grep -w PROXY_HOST_NAME base-dashboard.properties | sed s/PROXY_HOST_NAME\=//)
if [[ $var != $PROXY_HOST ]]; then
  AddOrUpdateCfg PROXY_HOST_NAME "$PROXY_HOST"
  # echo "PROXY_HOST_NAME=$PROXY_HOST" >> base-dashboard.properties
fi

var=$(grep -w BASE_URL base-dashboard.properties | sed s/BASE_URL\=//)
if [[ $var != $BASE_URL ]]; then
  AddOrUpdateCfg BASE_URL "$BASE_URL"
  # echo "BASE_URL=$BASE_URL" >> base-dashboard.properties
fi

var=$(grep -w URL base-dashboard.properties | sed s/URL\=//)
if [[ $var != $DASHBOARD_NAME ]]; then
  AddOrUpdateCfg URL "$DASHBOARD_NAME"
  # echo "URL=$DASHBOARD_NAME" >> base-dashboard.properties
fi

var=$(grep -w schemaUser base-dashboard.properties | sed s/schemaUser\=//)
if [[ $var != $DB_USER ]]; then
  AddOrUpdateCfg schemaUser "$DB_USER"
  # echo "schemaUser=$DB_USER" >> base-dashboard.properties
fi

var=$(grep -w schemaPassword base-dashboard.properties | sed s/schemaPassword\=//)
if [[ $var != $DB_PW  ]]; then
  AddOrUpdateCfg schemaPassword "$DB_PW"
  # echo "schemaPassword=$DB_PW" >> base-dashboard.properties
fi
  
if [[ "$SAVE_CLONE" = "true" ]] ; then
	cp $CLONE_DB_NAME.sql.gz /nfs1/db-clones/$CLONE_FILE_NAME.sql.gz
	cp ${CLONE_DB_NAME}_staging.sql.gz /nfs1/db-clones/${CLONE_FILE_NAME}_staging.sql.gz
fi

if [[ $CLONE_DASHBOARD != "" ]]; then
  echo "Calling setup before running cloner so that the schema is created.  The setup script will be run again after clone just in case we need to upgrade the database."
  ./setup -n
  ../e-cloner-load.sh

fi

./setup -n
URL=$DASHBOARD_NAME

echo "The proxy host is $PROXY_HOST"

ssh ${PROXY_HOST} 'test -f /var/run/haproxy.pid'
if [ $? = 0 ]; then
cd /usr/java;
cp -r setup-proxy $DIR_NAME/setup-proxy
fi
cd $DIR_NAME
./setup-proxy $PROXY_HOST

cd /usr/java;
./setup_newrelic.sh $DIR_NAME
cd $DIR_NAME

# startup
cd bin

BUILD_ID=dontKillNewDashboard ./startup.sh

cd ..

sleep 60

if [[ $CLONE_DASHBOARD = "" ]] && [[ $DEPLOY_DB = "true" ]]; then

  #only create initial campaign if we are not cloning
  ant c0
else
  echo "Skipping campaign creation with CLONE_DASHBOARD = ${CLONE_DASHBOARD} and DEPLOY_DB = ${DEPLOY_DB}"
fi

#cleanup
ssh-agent -k

