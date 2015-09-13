cat id_rsa.pub | ssh billn@$1 "cat >> ~/.ssh/authorized_keys"
