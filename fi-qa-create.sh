#!/bin/bash

CLOUDPASS="/Users/billnguyen/chef/totvs/keys/CloudpassServers.pem"
# ASSETS = m1.small, 2GB, 1 core
# knife ec2 server create -r 'role[fi-qa-assets]' \
# 	-E live \
# 	-f m1.small \
# 	-x ubuntu -I ami-1b5a0772 \
# 	--availability-zone us-east-1c \
# 	-G CloudpassAppServer \
# 	-N FI-QA-ASSETS-1A \
# 	--identity-file $CLOUDPASS \
# 	--ebs-size 8 

# sleep 3
# APP = m3.2xlarge 30GB, 26 cores 
### 8GB -
knife ec2 server create -r 'role[fi-aio-deploy]' \
	-E live \
	-f m1.xlarge \
	-x ubuntu \
	-I ami-79fda510 \
	--availability-zone us-east-1c \
	-G "QAFluigIdentityApplicationServer" \
	-S CloudpassServers  \
	-N FI-QA-AIO-1B
	--identity-file $CLOUDPASS \
	--ebs-size 8

# sleep 3
# COUCHBASE = m1.xlarge, 16GB, 8 cores
# knife ec2 server create -r 'role[fi-qa-couchbase]' -E live -f m1.large -x ubuntu -I ami-ef5a0786 --availability-zone us-east-1c -G "QACouchbaseServer" -S CloudpassServers  -N FI-QA-COUCHBASE-1A --identity-file $CLOUDPASS --ebs-size 8

# knife ec2 server create -r 'role[fi-qa-couchbase]' -E live -f m1.large -x ubuntu -I ami-ef5a0786 --availability-zone us-east-1c -G "QACouchbaseServer" -S CloudpassServers  -N FI-QA-COUCHBASE-1B --identity-file $CLOUDPASS --ebs-size 8

# sleep 3
# MESSAGING =  m1.xlarge, 15GB, 8 Cores
# knife ec2 server create -r 'role[fi-qa-messaging]' -E live -f m1.medium -x ubuntu -I ami-e95a0780 --availability-zone us-east-1c -G "Messaging & Search Server" -N FI-QA-MESSAGING-1A --identity-file $CLOUDPASS --ebs-size 8
