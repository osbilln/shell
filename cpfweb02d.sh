#!/bin/bash

for S in `cat service.text`
      do
        ssh cpfstaging -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/$S ./"
done
ssh rcpfweb02d -C "service munin-node restart "
