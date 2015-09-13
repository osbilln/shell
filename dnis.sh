#!/bin/bash
set -x

echo -----DNIS Store Build-----

if [ $# -lt 3 ]; then
  echo Usage: $0 "DnisName" "ReleaseNUmber" "Env"
  exit
fi
   dnisname=$1
   release=$2
   profile=$3

check_dir () {
if [[ ! -d $dst_dir ]]; then
  mkdir $dst_dir
fi
}

backup_config () {
  DATE==`date +'%Y-%m-%d-%H:%M:%S'`
  cp -r $PWD/BuildDeployer/build-templates/$profile-profile.properties $PWD/BuildDeployer/build-templates/$profile-profile.properties.$DATE
}

get_release () {
  release_version=`echo "$release"  | cut -d'/' -f5`
  if [[ ! -f $release_version ]]; then
    wget $release
  fi
  unzip -o $release_version 
  chmod -R 755 assets 
#  dos2unix Naehas-build-deployer.sh
#  dos2unix Naehas-build-shutdown.sh
#  chmod 754 Naehas-build-deployer.sh
#  chmod 754 Naehas-build-shutdown.sh
  find . -type f -name "*.sh" -exec dos2unix {} \;
  find . -type f -name "*.sh" -exec chmod 755 {} \;

}

shutdown_dnis (){
  echo Shutting down DNIS
  bash ./Naehas-build-shutdown.sh
}

start_dnis () {
  echo starting $dnisname
  bash ./Naehas-build-deployer.sh
}

create_profile () {
  ant -buildfile "$dst_dir/BuildDeployer/build-coxdnis.xml" createProfileProps -Dprofile="$profile"
}

build () {
  echo Building DNIS 
  cd coxdnisweb
  mvn clean install
}

build_start_deployer () {
  cd ..
  echo Build Deployer starting...
  ant -buildfile "$dst_dir/BuildDeployer/build-coxdnis.xml" runServerConfig -DIS_SERVER=true -DLINUX_OS=true -Dprofile="$profile"

}

start_dnis () {
  create_profile
  build
  build_start_deployer
}

dst_dir=/usr/java/"${dnisname}"
cd $dst_dir
export JAVA_HOME="${dst_dir}/assets/java/linux/jdk1.8.0_40"
export PATH="$PATH":"${dst_dir}/assets/apache-ant-1.8.2/bin":"${dst_dir}/assets/maven/apache-maven-3.0.5/bin":"${dst_dir}/assets/java/linux/jdk1.8.0_40/bin"
#shutdown_dnis
bash ./Naehas-build-shutdown.sh
check_dir
get_release

sed -i "21 s/read profile/profile=\$1/" Naehas-build-deployer.sh
./Naehas-build-deployer.sh $profile


