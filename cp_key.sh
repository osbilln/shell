cat ~/.ssh/id_rsa.pub | ssh root@$1 "cat >> ~/.ssh/authorized_keys"
