<<<<<<< HEAD
<<<<<<< HEAD
knife ec2 server create -r 'recipe[all-in-one:web]' \
    -g deveng-sg \
    --flavor t2.micro  \
    --region eu-west-1 \
    --availability-zone eu-west-1a  \
    -I ami-d67c6ab2 \
    --server-connect-attribute private_ip_address \
    --tags isVPC=true,os=ubuntu-16.04,subnet_type=private-1a \
    -S deveng-key \
    --ssh-user ubuntu \
    --ssh-port 22 \
    --identity-file /Users/billn/Projects/terraform/zubedevkey.pem \
    --node-name devtesteu1a

# knife ec2 server create -r 'role[fi-aio-deploy]' \
#    --security-group-ids sg-004f0269 \
#   --image ami-d67c6ab2  \
#   --security-group-ids sg-004f0269 \
#        -E live \
#        -f m1.xlarge \
#        -x ubuntu \
#    --image ami-cc7066a8 \
#        -I ami-79fda510 \
#        --availability-zone us-east-1c \
#        -G "QAFluigIdentityApplicationServer" \
#        -S CloudpassServers  \
#        -N FI-QA-AIO-1B
#        --identity-file $CLOUDPASS \
#        --ebs-size 8
#    --run-list 'recipe[mysql::server_5_1]'
#    --subnet subnet-5c28822b \
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
knife ec2 server create \
    --flavor t1.micro  \
    --region us-west-2 \
    --availability-zone us-west-2a \
    --identity-file /Users/billnguyen/.ssh/dr-db.pem \
    --image ami-052a1c35 \
    --security-group-ids sg-0db28b68 \
    --server-connect-attribute private_ip_address \
    --subnet subnet-5c28822b \
    --ssh-user ubuntu \
    --ssh-port 22 \
    --tags isVPC=true,os=ubuntu-12.04,subnet_type=private-2a \
    --node-name drdb2 \
    --run-list 'recipe[mysql::server_5_1]'

<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
#   --server-connect-attribute private_ip_address \
#   --environment dr
#    --ssh-gateway ubuntu@<gateway_public_dns_hostname (route 53)> \
