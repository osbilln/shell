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

#   --server-connect-attribute private_ip_address \
#   --environment dr
#    --ssh-gateway ubuntu@<gateway_public_dns_hostname (route 53)> \
