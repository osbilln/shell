#!/usr/bin/env python
"""
selects desired columns from a CSV file.

Usage:
        selectCsvColumns.py csvFile.csv delimiter ColumnName(s)+
"""
import csv
import sys
import shutil

if len(sys.argv) < 4:
        print __doc__
        sys.exit(1)

csvFile = sys.argv[1]
headersToKeep = sys.argv[3:]
delimiterToUse = sys.argv[2]
reader = csv.reader(open(csvFile),delimiter=delimiterToUse)
writer = csv.writer(open(csvFile + ".tmp", 'wb'),delimiter=',')

first = True
keeps = []  # positions to keep
for row in reader:
        if first:
                i=0
                header = []
                for col in row:
                        if col in headersToKeep:
                                keeps.append(i)
				header.append(col)
                        i = i+1
                writer.writerow(header)
                first = False
        else:
                i=0
                newRow = [] # only include the targets
                for col in row:
                        if i in keeps:
                                newRow.append(col)
                        i = i+1
                writer.writerow(newRow)

shutil.move(csvFile + '.tmp', csvFile)
