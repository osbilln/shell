#!/bin/bash
# CloudpassServers.pem
# ASSETS = m1.small, 2GB, 1 core
knife ec2 server create -r 'role[fluigidentity-development-assets-server]' -E live -f m1.small -x ubuntu -S CloudpassServers.pem -I ami-4f9fc926 --availability-zone us-east-1c -G CloudpassAppServer -N FI-QA-ASSETS-1A --ebs-size 8 

# sleep 3
# MESSAGING =  m1.xlarge, 15GB, 8 Cores
knife ec2 server create -r 'role[fi-qa-messaging],role[fi-qa-keystore]' -E live -f m1.medium -x ubuntu -I ami-559fc93c --availability-zone us-east-1c -G "Messaging & Search Server" -N FI-QA-MESSAGING-1A --ebs-size 8
# sleep 3

# APPS = m3.2xlarge 30GB, 26 cores 
### 8GB -
knife ec2 server create -r 'role[fi-qa-app]' -E live -f m1.medium -x ubuntu -I ami-a194c2c8 --availability-zone us-east-1c -G "QAFluigIdentityApplicationServer" -S CloudpassServers  -N FI-QA-APPS-1A --ebs-size 8

# sleep 3
# COUCHBASE = m1.xlarge, 16GB, 8 cores
knife ec2 server create -r 'role[fi-qa-couchbase]' -E live -f m1.large -x ubuntu -I ami-d594c2bc --availability-zone us-east-1c -G "QACouchbaseServer" -S CloudpassServers  -N FI-QA-COUCHBASE-1A --ebs-size 8
# knife ec2 server create -r 'role[fluigidentity-production-couchbase-server]' -E live -f m1.large -x ubuntu -I ami-d594c2bc --availability-zone us-east-1c -G "QACouchbaseServer" -S CloudpassServers  -N FI-QA-COUCHBASE-1B --ebs-size 8

