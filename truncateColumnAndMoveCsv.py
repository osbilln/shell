#!/usr/bin/env python
"""
Transforms target sequences for input columns by moving everything 
from the match to the end of the string to another output column

Author: Yaw Anku, yawa@naehas.com

Usage:
        truncateAndMove.py csvFile.csv delimiter inputColumn outputColumn pattern
"""
import csv
import sys
import shutil
import re

if len(sys.argv) != 6:
        print __doc__
        sys.exit(1)

csvFile = sys.argv[1]
delimiterToUse= sys.argv[2]
inputColumn = sys.argv[3]
outputColumn = sys.argv[4]
pattern = sys.argv[5]

reader = csv.reader(open(csvFile),delimiter=delimiterToUse)
writer = csv.writer(open(csvFile + ".tmp", 'wb'),delimiter=delimiterToUse)


MATCH_PATTERN = re.compile(pattern)

OUT_OF_BOUNDS = 1000000 # a very large number unrealistic for no. of columns

inputPosition = OUT_OF_BOUNDS
outputPosition = OUT_OF_BOUNDS


first = True
for row in reader:
        if first:
                i=0
                header = []
                for col in row:
                        if col in inputColumn:
                                inputPosition = i
			if col in outputColumn:
				outputPosition = i
			header.append(col)
                        i = i+1

		# error out if the columns do not exist in the file
		if inputPosition == OUT_OF_BOUNDS:
			print 'ERROR: '+ inputColumn + ' column not found in the file'
			sys.exit(1)
		if outputPosition == OUT_OF_BOUNDS:
			print 'ERROR: '+ outputColumn + ' column not found in the file'
			sys.exit(1)
			
                writer.writerow(header)
                first = False
        else:
                i=0
                newRow = [] 
		matchObj = None
		tail ='';
                for col in row:
			
                        if i == inputPosition:
				matchObj = MATCH_PATTERN.search(col)
				if matchObj:
					tail = col[matchObj.start():]
					col = col[:matchObj.start()]
			newRow.append(col)
                        i = i+1
		
		if matchObj:
			newRow[outputPosition] = newRow[outputPosition] +  tail
                writer.writerow(newRow)
		
shutil.move(csvFile + '.tmp', csvFile)
