#!/bin/bash

KEY="/Users/billnguyen/.ssh/sq_billn" 
SSH="/home/eng/.ssh"
AUTH=authorized_keys

for i in `cat joy.2 `
  do
   echo $i ==========================
   ssh -i $KEY $i -C "mkdir $SSH "   
   scp -rp -i $KEY $AUTH $i:$SSH/
   ssh -i $KEY $i -C "chown -R eng:eng $SSH"   
   echo $i ==========================

  done
