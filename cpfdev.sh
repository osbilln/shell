#!/bin/bash

for S in `cat service.text`
     do
      ssh cpfdev -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/$S ./"
done
