#!/usr/bin/env python
"""
Removes desired columns from a CSV file.

Usage:
        deleteCsvColumns.py csvFile.csv ColumnName(s)+
"""
import csv
import sys
import shutil

if len(sys.argv) < 3:
        print __doc__
        sys.exit(1)

csvFile = sys.argv[1]
headersToDelete = sys.argv[2:]

reader = csv.reader(open(csvFile))
writer = csv.writer(open(csvFile + ".tmp", 'wb'))

first = True
skips = []  # positions to skip
for row in reader:
        if first:
                i=0
                header = []
                for col in row:
                        if col in headersToDelete:
                                skips.append(i)
                        else:
                                header.append(col)
                        i = i+1
                writer.writerow(header)
                first = False
        else:
                i=0
                newRow = [] # excluding the delete targets
                for col in row:
                        if i not in skips:
                                newRow.append(col)
                        i = i+1
                writer.writerow(newRow)

shutil.move(csvFile + '.tmp', csvFile)
