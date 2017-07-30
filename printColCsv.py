#!/usr/bin/env python
"""
Prints up to 100 unique values of COLUMN in CSV_FILE.

Usage:
	printCsvCol.py CSV_FILE COLUMN
	
"""
#A. Cin

import csv
import sys

if len(sys.argv) < 3:
	print __doc__
	sys.exit(1)

reader = csv.reader(open(sys.argv[1]))
lengths = {}
headers = {}
first = True
MAX_ROWS = 100
printed = 0
values = set()
for row in reader:
	if first:
		i=0
		for col in row:
			headers[col] = i
			i=i+1
		first = False
	else:
		value = row[headers[sys.argv[2]]]
		if printed < MAX_ROWS and value not in values:
			print value
			values.add(value)
			printed = printed + 1
		if printed >= MAX_ROWS:
			print '    .'
			print '    .'
			print '    .'
			print 'Continues...'
			sys.exit(0)
