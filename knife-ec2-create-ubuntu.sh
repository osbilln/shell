# knife ec2 server create -r 'role[webserver]' -I ami-7000f019 -f m1.small -A 'AKIAIV6X45VFMOZDJULQ' -K "uz8WmMkK7Xc9dIgASo0jEGlg2fj8XEoVQNlpLMZH"

# knife ec2 server list
# knife ec2 server create
# knife ec2 instance data

# knife ec2 server create -I ami-3275ee5b --flavor m1.micro -G www,default -x centos -N server01  -A 'AKIAIV6X45VFMOZDJULQ' -K "uz8WmMkK7Xc9dIgASo0jEGlg2fj8XEoVQNlpLMZH"
# knife ec2 server create -I ami-3275ee5b --flavor m1.micro -x centos -N server01  -A "AKIAIV6X45VFMOZDJULQ" -K "uz8WmMkK7Xc9dIgASo0jEGlg2fj8XEoVQNlpLMZH"
knife ec2 server create -f t1.micro --region us-east-1 \
 -I ami-7339b41a -G allow_ssh,allow_web -x ubuntu \
 -r "role[base-ubuntu]" -E development -i [PATHTOYOURKEY] -S [NAMEOFYOURKEY]
# knife ec2 server create -r 'role[webserver]' -I ami-7000f019 -f m1.small -A 'Your AWS Access Key ID' -K "Your AWS Secret Access Key"
# knife ec2 server create -r "role[ubuntu]" -I ami-399ca94d -f m1.small -S knife -i ~/.ssh/knife.pem --ssh-user ubuntu --region us-west-1 -Z us-west-1a
# knife ec2 server create -r "role[ubuntu]" -I ami-5fa88d1a -f m1.small -S knife -i ~/.ssh/knife.pem --ssh-user ubuntu --region us-west-1 -Z us-west-1a
