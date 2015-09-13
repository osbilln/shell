#!/bin/sh
sed -e 's/$//; s/"/""/g; s/^/"/; s/$/"/; s/\t/","/g;' $1 > $1.csv

