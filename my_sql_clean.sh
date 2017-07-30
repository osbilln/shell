#!/bin/bash
$(/usr/bin/which mysql) -v --user=root --password=password < ../dbscripts/create-database.txt
