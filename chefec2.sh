# knife ec2 server create -r 'role[webserver]' -I ami-7000f019 -f m1.small -A 'Your AWS Access Key ID' -K "Your AWS Secret Access Key"
# knife ec2 server create -r "role[ubuntu]" -I ami-399ca94d -f m1.small -S knife -i ~/.ssh/knife.pem --ssh-user ubuntu --region us-west-1 -Z us-west-1a
knife ec2 server create -r "role[ubuntu]" -I ami-5fa88d1a -f m1.small -S knife -i ~/.ssh/knife.pem --ssh-user ubuntu --region us-west-1 -Z us-west-1a
