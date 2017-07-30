#!/usr/bin/env python
"""
Calculates the max widths of renderings inside a renderMap.txt padded by 10

Usage:
	maxWidthsRM.py renderMap.txt
"""
# A. Cin

import sys;

if len(sys.argv) < 2:
	print __doc__
	sys.exit(1)

f = file(sys.argv[1])
lengths = {}
for line in f:
	varname = line[0:25]
	therest = line[25:]
	varname = varname[0:varname.rfind('-')]
	leng = lengths.get(varname, 0)
	curLen = len(therest)
	if curLen > leng:
		lengths[varname] = curLen
	#lengths.


for varname, leng in lengths.iteritems():
	print '%-50s = %d' % (varname, leng+10)

