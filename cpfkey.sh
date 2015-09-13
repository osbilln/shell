#!/bin/bash

SERVER=$1

ssh $SERVER -C "mkdir /root/.ssh && chmod 600 /root/.ssh"
scp -r /root/.ssh/authorized_keys $SERVER:.ssh/.
ssh $SERVER
