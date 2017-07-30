#!/usr/bin/env python
"""
Converts a list of groups into a sql statement

  ./makeAuditSelector.py inputGroups.csv lpId inclusionTable naehas_list_id

  o inputGroups.csv must be a comma separated file of the 
      LETTERCODE,LISTID,NETWORKSTATE,RATE_GROUP
    Do not include a header row.
    The word 'Blank' will be replaced with ' '.
  o lpId must be id of the project.
  o inclusionTable must be the database name of the table containing the inclusion data.
  o naehas_list_id must the DataList id for the above table.

"""
import csv
import sys
import datetime

if len(sys.argv) < 5:
  print __doc__
  sys.exit(1)

csvFile = sys.argv[1]
reader = csv.reader(open(csvFile),delimiter=',',dialect=csv.excel)

today = datetime.date.today()
lpId = sys.argv[2]

auditTmpTable = 'ALB_AUDIT_' + today.isoformat().replace('-', '') + '_LP' + lpId

lpId = sys.argv[2]
sourceTable = sys.argv[3]
naehas_list_id = sys.argv[4]
salt = 'basketballs'

print 'drop table ' + auditTmpTable + ' if exists;'
print 'create table ' + auditTmpTable + ' ('
print '  `NAEHAS_ID` varbinary(16) DEFAULT NULL, '
print '  `NAEHAS_LIST_ID` varbinary(16) DEFAULT NULL, '
print '  `RATE_GROUP` varchar(2) NOT NULL DEFAULT "", '
print '  `NETWORKSTATE` varchar(2) NOT NULL DEFAULT "", '
print '  `LETTERCODE` varchar(28) NOT NULL DEFAULT "", '
print '  `LISTID` varchar(28) NOT NULL DEFAULT "" '
print ');'

print ''
print '-- Query for records'


print 'insert into ' + auditTmpTable
print ' select aes_decrypt(nzid, "'+ salt + '") naehas_id'
print '      , naehas_list_id'
print '      , RATE_GROUP as RATE_GROUP'
print '      , NETWORKSTATE'
print '      , LETTERCODE as LETTERCODE '
print '      , LISTID as LISTID '
print ' from ( '
print '  select min(aes_encrypt(naehas_id, "' + salt + '")) as nzid'
print '        , naehas_list_id , RATE_GROUP, NETWORKSTATE, LETTERCODE, LISTID '
print '    from ' + sourceTable 
print '   where ASPENID not like "S%" AND (FALSE '

for row in reader:
  if row[3] == 'Blank':
    rg = ' '
  else:
    rg = row[3]
  print 'OR (LETTERCODE = "' + row[0] + '" and LISTID = ' + row[1] + ' and NETWORKSTATE = "' + row[2] + '" and RATE_GROUP = "' + rg + '")'
  
print ') '
print 'group by LETTERCODE, LISTID, NETWORKSTATE, RATE_GROUP '
print ') x;'

print ''

print '-- Now for Updating N_DATA_MAPPINGS'
print 'update N_DATA_MAPPINGS set audit_flag = 1 '
print ' where landing_page_id = ' + lpId
print '   and naehas_list_id = ' + naehas_list_id
print '   and naehas_id in '
print '       (select naehas_id from ' + auditTmpTable + ' where naehas_list_id = ' + naehas_list_id + ')'
print ';'
