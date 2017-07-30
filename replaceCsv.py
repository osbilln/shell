#!/usr/bin/env python
"""
Transforms target sequences for input columns by replacing matching patterns

Author: Yaw Anku, yawa@naehas.com

Usage:
        replace.py csvFile.csv delimiter inputCol pattern replacement 
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
pattern = sys.argv[4]
replacement = sys.argv[5]


reader = csv.reader(open(csvFile),delimiter=delimiterToUse)
writer = csv.writer(open(csvFile + ".tmp", 'wb'),delimiter=delimiterToUse)

MATCH_PATTERN = re.compile(pattern)

OUT_OF_BOUNDS = 1000000 # high number unlikely to be less than no. of cols in csv file
inputPosition = OUT_OF_BOUNDS

first = True
for row in reader:
        if first:
                i=0
                header = []
                for col in row:
                        if col in inputColumn:
                                inputPosition = i
			header.append(col)
                        i = i+1

		# error out if the columns do not exist in the file
		if inputPosition  == OUT_OF_BOUNDS :
			print 'ERROR: '+ inputColumn + ' not found in the file'
			sys.exit(1)

                writer.writerow(header)
                first = False
        else:
                i=0
                newRow = [] 
                for col in row:
			
                        if i == inputPosition:			
				matchObj = MATCH_PATTERN.search(col)
				if matchObj:
					col = re.sub(matchObj.group(),replacement,col)
			newRow.append(col)
                        i = i+1

                writer.writerow(newRow)

shutil.move(csvFile + '.tmp', csvFile)
