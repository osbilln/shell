#!/bin/bash

# for i in cpfrcm
#   do
#     echo $i
#    scp -rp /usr/share/munin/plugins/mongo* $i:/usr/share/munin/plugins/
   for S in `cat service.text`
      do
        ssh cpfstaging -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/$S ./"
   done
ssh cpfstaging -C "service munin-node restart "
