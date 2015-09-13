#!/bin/bash

cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_btree ./
cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_conn ./
cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_lock ./
cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_mem ./
cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_ops ./
