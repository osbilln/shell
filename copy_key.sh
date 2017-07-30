#!/bin/bash -e

# set -x 

ssh billn@$1 -C "mkdir .ssh"
cat ~/.ssh/id_rsa.pub | ssh billn@$1 "cat >> ~/.ssh/authorized_keys"
ssh billn@$1 -C "chmod 600 .ssh/authorized_keys"
ssh billn@$1 -C "chmod 700 .ssh"
