#!/bin/bash -ef
set -x


export JAVA_HOME="$PWD/assets/java/linux/jdk1.8.0_40"
export PATH="$PATH":"$PWD/assets/apache-ant-1.8.2/bin":"$PWD/assets/maven/apache-maven-3.0.5/bin":"$PWD/assets/java/linux/jdk1.8.0_40/bin"

echo -----DNIS Store Build-----

if [ $# -lt 2 ]; then
  echo Usage: $0 "Release" "Env"
  exit
fi
   release=$1
   profile=$2
echo $profile

if [ "$profile" = "qa" ]; then
   echo Building QA profile.
 elif [ "$profile" = "dev" ]; then
   echo Building Dev profile.
 elif [ "$profile" = "perf" ]; then
   echo Building Perf profile.
 elif [ "$profile" = "prod" ]; then
   echo Building PROD profile.
 elif [ "$profile" = "uat" ]; then
   echo Building UAT profile.
 else
   echo "Invalid input"
   exit
fi

### Backing up  the ENV template
src_dir="http://amiintegration.s3.amazonaws.com/52-1.0.165493"
dst_dir="/usr/java/coxdnis"
# DATE==`date +'%Y-%m-%d-%H:%M:%S'`
#  cp -r $PWD/BuildDeployer/build-templates/$profile-profile.properties $PWD/BuildDeployer/build-templates/$profile-profile.properties.$DATE

if [[ ! -d /usr/java/coxdnis"$profile" ]]; then
  mkdir /usr/java/coxdnis"$profile"
fi

### Get release 
cd /usr/java/coxdnis"$profile"
# wget $src_dir/Cox-Dnis-Build-1.0.165493.zip
### unzip the build
# unzip -o $release 
dos2unix Naehas-build-deployer.sh
dos2unix Naehas-build-shutdown.sh
chmod 755 Naehas-build-deployer.sh

ant -buildfile "$PWD/BuildDeployer/build-coxdnis.xml" createProfileProps -Dprofile="$profile"
echo Building DNIS 

cd coxdnisweb
mvn clean install
cd ..
echo Build Deployer starting...
ant -buildfile "$PWD/BuildDeployer/build-coxdnis.xml" runServerConfig -DIS_SERVER=true -DLINUX_OS=true -Dprofile="$profile"
