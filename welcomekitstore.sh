#!/bin/bash -ef
set -x


export JAVA_HOME="$PWD/assets/java/linux/jdk1.8.0_40"
export PATH="$PATH":"$PWD/assets/apache-ant-1.8.2/bin":"$PWD/assets/maven/apache-maven-3.0.5/bin":"$PWD/assets/java/linux/jdk1.8.0_40/bin"

echo -----store Store Build-----

if [ $# -lt 3 ]; then
  echo Usage: $0 "storeName" "ReleaseNUmber" "Env"
  exit
fi
   storename=$1
   release=$2
   profile=$3
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

check_dir () {
if [[ ! -d $dst_dir ]]; then
  mkdir $dst_dir
fi
}

backup_config () {
  DATE==`date +'%Y-%m-%d-%H:%M:%S'`
  cp -r $PWD/BuildDeployer/build-templates/$profile-profile.properties $PWD/BuildDeployer/build-templates/$profile-profile.properties.$DATE
}

get_build () {
  src_dir="http://amiintegration.s3.amazonaws.com/52-1.0.165493"
  if [[ ! -f $release ]]; then
    wget $src_dir/$release
  fi
  unzip -o $release 
  chmod -R 755 assets 
  dos2unix Naehas-build-deployer.sh
  dos2unix Naehas-build-shutdown.sh
  chmod 755 Naehas-build-deployer.sh
  chmod 755 Naehas-build-shutdown.sh

}

shutdown_store (){
  echo Shutting down store
  ./Naehas-build-shutdown.sh
sleep 10
}

create_profile () {
  ant -buildfile "$PWD/BuildDeployer/build-welcomekitstore.xml" createProfileProps -Dprofile="$profile"
}

grunt () {
  cd welcomekitstoreui
  grunt
}

build () {
  echo Building store 
  cd welcomekitstoreweb
  mvn clean install
}

build_start_deployer () {
  cd ..
  echo Build Deployer starting...
ant -buildfile "$PWD/BuildDeployer/build-welcomekitstore.xml" runServerConfig -DIS_SERVER=true -DLINUX_OS=true -Dprofile="$profile"
}

dst_dir=$storename
check_dir
cd $dst_dir

get_build
shutdown_store

create_profile
build
build_start_deployer

