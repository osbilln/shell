#!/bin/bash
#
# this file is sourced by create-ami-32.sh and create-ami-64.sh

set -e

create_ami () {
 local ami_id instance_type $arch
 ami_id=$1
 instance_type=$2
 arch=$3
 region=$4
 availability_zone=$5

 check_environment
 create_machine $ami_id $instance_type
 wait_for_ssh
 run_script_remote prepare-machine-update.sh
 run_script_remote prepare-machine-reboot.sh
 wait_for_ssh
 install_software
 finish
}

check_environment () {
  # These are set by e.g.
  for e in AWS_ACCESS_KEY_ID AWS_SECRET_KEY EC2_PRIVATE_KEY EC2_CERT AWS_CREDENTIAL_FILE AWS_IAM_HOME; do
    val=$(eval "echo \$$e")
    if [ "$val" == "" ]; then
      echo environment variable $e not set
      exit -1
    fi
  done

  # we need a keypair that is present in AWS. For now hardcode,
  # consider creating a throwaway keypair
  SSH_KEY_NAME=changeme-kp1
  SSH_KEY_FILE=$HOME/changeme-kp1.pem
  
  if [ -f $SSH_KEY_FILE ]; then
    echo using key file $SSH_KEY_FILE
  else
    echo cannot find key file $SSH_KEY_FILE
    exit -1
  fi
}

create_machine () {
  local ami_id instance_type
  ami_id=$1
  instance_type=$2

  create_cmd="ec2-run-instances \
    --private-key $EC2_PRIVATE_KEY \
    --cert $EC2_CERT \
    --region $region \
    --availability-zone $availability_zone \
    --connection-timeout 30 \
    --request-timeout 30 \
    $ami_id \
    --key $SSH_KEY_NAME \
    --instance-count 1 \
    --instance-type $instance_type \
    --instance-initiated-shutdown-behavior stop "
  echo creating instance: $create_cmd
  result="/tmp/ec2-ami-template.out.$$"
  $create_cmd | tee $result
  instance=`egrep '^INSTANCE' $result |awk '{print $2}'`
  echo instance id: $instance

  tag_cmd="ec2-create-tags --tag=Name=ami-tmp-$(date +%Y%m%d01) $instance"
  echo tagging instance: $tag_cmd
  $tag_cmd

  /bin/echo -n "waiting for instance $instance to start running..."
  while host=$(ec2-describe-instances "$instance" | egrep ^INSTANCE | cut -f4) && test -z $host; do
    echo -n .
    sleep 1
  done
  echo "instance $instance is running"
  echo $instance > /tmp/instance
  
  ec2-describe-instances $instance
}

wait_for_ssh () {
  echo -n "waiting for ssh on $host to start..."
  while ssh -o StrictHostKeyChecking=no -q -i $SSH_KEY_FILE ubuntu@$host true && test; do
    echo -n .
    sleep 1
  done
  echo ""
  period=60
  echo "giving it a little while longer to re-generate keys; sleeping for $period seconds"
  sleep $period
}

run_script_remote () {
    local script
    script=$1
    echo
    echo "ready to run $script: ssh -T -i $SSH_KEY_FILE -o StrictHostKeyChecking=no ubuntu@$host < $script"
    read -p "proceed? (y|n) " yn
    case $yn in
    [Yy]* ) ssh -T -i $SSH_KEY_FILE -o StrictHostKeyChecking=no ubuntu@$host < $script;;
    * ) echo "skipped";;
    esac
}

install_software () {
  for script in prepare-machine-software.sh prepare-machine-ruby.sh prepare-machine-chef.sh prepare-machine-cleanup.sh; do
    run_script_remote $script
  done
}

finish () {
  echo "Now from the AWS console, find instance $instance and do Create Image (EBS AMI)"
  echo "e.g. Name=changeme-precise-amd64-$(date +%Y%m%d%H%M)"
  echo "once that is done, don't forget to terminate $instance"
}
