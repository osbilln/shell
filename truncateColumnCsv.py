#!/usr/bin/env python
"""
Transforms target sequences for input columns by removing everything 
from the match to the end of the string

Author: Yaw Anku, yawa@naehas.com

Usage:
        truncate.py csvFile.csv delimiter inputCol1 inputCol2 pattern
"""
import csv
import sys
import shutil
import re

if len(sys.argv) < 5:
        print __doc__
        sys.exit(1)

csvFile = sys.argv[1]
delimiterToUse= sys.argv[2]
headersToTransform = sys.argv[3:-1]
pattern = sys.argv[-1]

reader = csv.reader(open(csvFile),delimiter=delimiterToUse)
writer = csv.writer(open(csvFile + ".tmp", 'wb'),delimiter=delimiterToUse)


# MATCH_REGEX = "Spc \d{0,3}" # can add more matching sequences here
MATCH_PATTERN = re.compile(pattern)

positionsToTransform = []


first = True
for row in reader:
        if first:
                i=0
                header = []
                for col in row:
                        if col in headersToTransform:
                                positionsToTransform.append(i)
			header.append(col)
                        i = i+1

		# error out if the columns do not exist in the file
		if len(positionsToTransform) != len(headersToTransform) :
			print 'ERROR: '+ ",".join(headersToTransform) + ' columns not found in the file'
			sys.exit(1)

                writer.writerow(header)
                first = False
        else:
                i=0
                newRow = [] 
                for col in row:
			
                        if i in positionsToTransform:			
				matchObj = MATCH_PATTERN.search(col)
				if matchObj:
					col = col[:matchObj.start()]
			newRow.append(col)
                        i = i+1

                writer.writerow(newRow)

shutil.move(csvFile + '.tmp', csvFile)
