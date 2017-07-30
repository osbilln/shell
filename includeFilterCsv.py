#!/usr/bin/env python
# Author: A. Cin
"""
Includes rows based on a row matching certain values.

Usage:
        includeFilterCsv.py csvFile.csv delimiter column values...
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
filterColumn = sys.argv[3]
values = sys.argv[4:]       # values filterColumn is allowed to have.

reader = csv.reader(open(csvFile),delimiter=delimiterToUse)
writer = csv.writer(open(csvFile + ".tmp", 'wb'),delimiter=delimiterToUse)

OUT_OF_BOUNDS = 10000 # high number unlikely to be less than no. of cols in csv file
inputPosition = OUT_OF_BOUNDS

first = True
for row in reader:
        if first:
                i=0
                header = []
                for col in row:
                        if col.lower() == filterColumn.lower():
                                inputPosition = i
                        header.append(col)
                        i = i+1

                # error out if the columns do not exist in the file
                if inputPosition  == OUT_OF_BOUNDS:
                        print 'ERROR: '+ filterColumn + ' not found in the file'
                        sys.exit(1)

                writer.writerow(header)
                first = False
        else:
                if row[inputPosition] in values:
                        writer.writerow(row)
                        #print row

shutil.move(csvFile + '.tmp', csvFile)

