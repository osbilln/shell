#!/bin/bash

# for i in cpfrcm
#   do
#     echo $i
#    scp -rp /usr/share/munin/plugins/mongo* $i:/usr/share/munin/plugins/
   for S in `cat service.text`
      do
        ssh cpfqa -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/$S ./"
   done
ssh cpfqa -C "service munin-node restart "
