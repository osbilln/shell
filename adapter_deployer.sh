#!/bin/bash -x

function usage() {
  echo "adapter_upgrader v0.1"
  echo ""
  echo "adapter_upgrader.sh OPTIONS ADAPTER_NAME"
  echo ""
  echo "Valid options:"
  echo "     -t --tagname			Tag Name (Default: trunk)"
  echo "     -h --help          	Display this help."
  exit 0
}

#defaults!

PROXY_HOST=127.0.0.1
TAG_NAME=trunk
DB_HOST=127.0.0.1
SHUTDOWN_PORT=9198

# Adds or updates an environment variable of base-dashboard.cfg
function AddOrUpdateMemOpts {
  PROP="$2"
  VALUE="$1"
  BDC="./bin/memOpts.env"
  while [[ "$VALUE" != "${VALUE# }" ]] ; do
    VALUE="${VALUE# }"
  done
  while [[ "$VALUE" != "${VALUE% }" ]] ; do
    VALUE="${VALUE% }"
  done
  if [[ ! -f $BDC ]] ; then
    touch $BDC
  fi
  if egrep -q "^export JAVA_HOME" $BDC ; then
    # update
    # sed -e 's#^${PROP}=.*#${PROP}=$VALUE#g' $BDC
    sed -e "s#^export JAVA_HOME=.*#export JAVA_HOME=$VALUE#g" ${BDC} > ${BDC}.1
    mv ${BDC}.1 ${BDC}

  else
    # insert
    echo "export JAVA_HOME=$VALUE" >> $BDC
  fi
}	

echo "PARAMETER JAVA_HOME: ${JAVA_HOME}"

#if [ -z "${JAVA_HOME}" ] ; then
  echo "SETTING ENV PARAMETER JAVA_HOME: ${JAVA_HOME}"	
  export JAVA_HOME=$JAVA_HOME || die 'Error setting JAVA_HOME.'
  AddOrUpdateMemOpts $JAVA_HOME
#fi

echo "PARAMETER SHUTDOWN_PORT: ${SHUTDOWN_PORT}"
echo "SETTING ENV PARAMETER SHUTDOWN_PORT: ${SHUTDOWN_PORT}"	
export SHUTDOWN_PORT=$SHUTDOWN_PORT || die 'Error setting SHUTDOWN_PORT.'

while getopts ":ht:t:p:h:-:" opt; do
 case $opt in
  -)
     case "${OPTARG}" in
       tagname)
         TAG_NAME="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       port)
         SHUTDOWN_PORT="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
  p) SHUTDOWN_PORT=$OPTARG
     ;;   
  h) usage
     ;;
 esac
done

ADAPTER_NAME=${!OPTIND}

echo "Upgrading $ADAPTER_NAME to tag $TAG_NAME"

DIR_NAME=`echo $ADAPTER_NAME | tr A-Z a-z | sed "s/adapter/-adapter/"`

echo "FINAL ENV PARAMETER SHUTDOWN_PORT: ${SHUTDOWN_PORT}"	

cd /usr/java/

if [ ! -d $DIR_NAME ]; then
mkdir /usr/java/$DIR_NAME
fi

cd $DIR_NAME

# Print current hostname
echo "Current Host: "
hostname

# Print current directory
echo "Current Directory: "
pwd

# Shutdown
if [ -f /usr/java/${DIR_NAME}/${DIR_NAME}.pid ]; then
    kill -9 $(cat /usr/java/${DIR_NAME}/${DIR_NAME}.pid)
fi
if [ -f /usr/java/${DIR_NAME}/${DIR_NAME}_${SHUTDOWN_PORT}.pid ]; then
    kill -9 $(cat /usr/java/${DIR_NAME}/${DIR_NAME}_${SHUTDOWN_PORT}.pid)
fi
lsof -i TCP:${SHUTDOWN_PORT} > adapter_processes_by_port_${SHUTDOWN_PORT}.log
awk 'NR==2 {print $2}' adapter_processes_by_port_${SHUTDOWN_PORT}.log > ${DIR_NAME}_${SHUTDOWN_PORT}.pid
rm adapter_processes_by_port_${SHUTDOWN_PORT}.log
ant shutdown

# setup ssh-agent
eval `ssh-agent`
ssh-add /home/naehas/.au/id_rsa

svn info svn+ssh://svn.naehas.com/home/svn/repository/adapter/$TAG_NAME > SVN_INFO

# clean up old directories to handle files deleted in the new version
# we don't remove everything because we want to keep logs, downloads, etc.
rm -rf conf/adapter.properties
rm -rf dist
rm -rf doc
rm -rf external
rm -rf generated
rm -rf lib
rm -rf scripts
rm -rf static
rm -rf test
rm -rf webapps
rm -rf src
rm -rf testdata

# Backup TacticConfiguration.xml
if [[ ! -d backups ]] ; then
  mkdir backups
fi
if [[ ! -f ./backups/TacticConfiguration.xml ]] ; then
  cp conf/TacticConfiguration.xml backups/TacticConfiguration.xml
  ./customize -n backups/TacticConfiguration.xml
fi
if [[ -f .customizations/backups/TacticConfiguration.xml ]] ; then
  svn revert .customizations/backups/TacticConfiguration.xml
  svn up .customizations/backups/TacticConfiguration.xml
  cp conf/TacticConfiguration.xml backups/TacticConfiguration.xml
  ./customize -n ./backups/TacticConfiguration.xml
fi

# svn export
svn export svn+ssh://svn.naehas.com/home/svn/repository/adapter/$TAG_NAME . --force
        
# Restore customizations
./customize -restore || echo 'Could not restore Adapter customizations'

# Copy back the backed up TacticConfiguration.xml into conf/ directory
if [[ -f ./backups/TacticConfiguration.xml ]] ; then
  cp backups/TacticConfiguration.xml conf/TacticConfiguration.xml
fi

# startup
if [[ $DIR_NAME != "" ]]; then
	ant clean compile
fi

BUILD_ID=dontKillAdapter ./scripts/startupforked

# Store PID in file by port
lsof -i TCP:${SHUTDOWN_PORT} > adapter_processes_by_port_${SHUTDOWN_PORT}.log
awk 'NR==2 {print $2}' adapter_processes_by_port_${SHUTDOWN_PORT}.log > ${DIR_NAME}_${SHUTDOWN_PORT}.pid
rm adapter_processes_by_port_${SHUTDOWN_PORT}.log

# Store PID in file by ps
ps aux | grep $DIR_NAME > ${DIR_NAME}_processes.log
awk 'NR==1 {print $2}' ${DIR_NAME}_processes.log > ${DIR_NAME}.pid
rm ${DIR_NAME}_processes.log

sleep 60

#cleanup
ssh-agent -k

#nohup dont-kill-process.sh /usr/java/${DIR_NAME}/pidFileName /usr/java/${DIR_NAME}/scripts/startupforked script args >script.out 2>&1 &

