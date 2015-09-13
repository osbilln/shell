#!/bin/bash


for i in BIN_logs.cfg  RDR_logs.cfg  RPT_logs.cfg  SLC_logs.cfg  WA_logs.cfg  ZC_logs.cfg
  do 
  echo $i 
   for j in `cat nodes`
     do
      scp -rp -i /Users/billnguyen/.ssh/sq_billn $i $j:/usr/local/nagios/etc/.
     done
done
