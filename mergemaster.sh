#!/bin/bash
set -x

echo -----MergeMaster Build-----

if [ $# -lt 3 ]; then
  echo Usage: $0 "mergemasterName" "ReleaseNUmber" "Env"
  exit
fi
   mergemastername=$1
   release=$2
   profile=$3



backup_config () {
  DATE==`date +'%Y-%m-%d-%H:%M:%S'`
  cp -r $PWD/BuildDeployer/build-templates/$profile-profile.properties $PWD/BuildDeployer/build-templates/$profile-profile.properties.$DATE
}

get_release () {
  release_version=`echo "$release"  | cut -d'/' -f5`
  if [[ ! -f $release_version ]]; then
    wget $release
  fi
  release_number=`echo "$release"  | cut -d'.' -f3`
  dst_dir=Mergeserver-Build-2.0."$release_number"
  if [[ ! -d $dst_dir ]]; then
  mkdir $dst_dir
  fi
  mkdir $dst_dir
  mv $release $dst_dir
  cd $dst_dir
  unzip $release_version 
  chmod -R 755 assets 
  dos2unix Naehas-build-deployer.sh
  dos2unix Naehas-build-shutdown.sh
  chmod 754 Naehas-build-deployer.sh
  chmod 754 Naehas-build-shutdown.sh
  find . -type f -name "*.sh" -exec dos2unix {} \;
  find . -type f -name "*.sh" -exec chmod 755 {} \;

}

shutdown_mergemaster (){
  echo Shutting down mergemaster
  bash ./Naehas-build-shutdown.sh
}

start_mergemaster () {
  echo starting $mergemastername
  bash ./Naehas-build-deployer.sh
}

create_profile () {
  ant -buildfile "$dst_dir/BuildDeployer/build-coxmergemaster.xml" createProfileProps -Dprofile="$profile"
}

build () {
  echo Building mergemaster 
  cd coxmergemasterweb
  mvn clean install
}

build_start_deployer () {
  cd ..
  echo Build Deployer starting...
  ant -buildfile "$dst_dir/BuildDeployer/build-coxmergemaster.xml" runServerConfig -DIS_SERVER=true -DLINUX_OS=true -Dprofile="$profile"

}

start_mergemaster () {
  create_profile
  build
  build_start_deployer
}


cd $dst_dir
export JAVA_HOME="${dst_dir}/assets/java/linux/jdk1.8.0_40"
export PATH="$PATH":"${dst_dir}/assets/apache-ant-1.8.2/bin":"${dst_dir}/assets/maven/apache-maven-3.0.5/bin":"${dst_dir}/assets/java/linux/jdk1.8.0_40/bin"
#shutdown_mergemaster
bash ./Naehas-build-shutdown.sh
check_dir
get_release

sed -i "15 s/read buildFor//" Naehas-build-deployer.sh
./Naehas-build-deployer.sh $service $port $env 



