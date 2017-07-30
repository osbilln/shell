# knife bootstrap chef.zubops.net --sudo -x root -p root --bootstrap-version 11.12.8 
knife bootstrap chef.zubops.net --sudo --ssh-user root --identity-file ~/.ssh/id_rsa -N "node1" --bootstrap-version 11.12.8 
