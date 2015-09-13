#!/bin/bash

SERVER=$1
for i in `cat $SERVER`
 do
   scp -rp ../.bash_history $i:.bash_history
 done
