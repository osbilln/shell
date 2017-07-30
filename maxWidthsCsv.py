#!/usr/bin/env python
"""
Prints the max widths of the columns of the given CSV_FILE padded by 10.

Usage:
	maxWidthsCsv.py CSV_FILE

Bugs:
	Calculates the widths in bytes, not characters.

"""
import csv
import sys

if len(sys.argv) < 2:
	print __doc__
	sys.exit(1)

reader = csv.reader(open(sys.argv[1]))
lengths = {}
first = True
for row in reader:
	if first:
		headers = row
		i=0
		for col in row:
			lengths[i] = 0
			i = i+1
		first = False
	else:
		i=0
		for col in row:
			leng = len(col)
			if leng > lengths[i]:
				lengths[i] = leng
			i = i+1

i=0
for col in headers:
	print '%-50s = %d' % (headers[i], lengths[i]+10)
	i = i+1
