#!/usr/bin/env python
"""
Parses the jobs for a day.
  collectionJobStats.py path/to/dashboard.xml YYYY-mm-dd

-- Here is an example table to store the events
create table N_EVENTS(
  ID bigint(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  DASHBOARD char(100) NOT NULL,
  REVISION bigint(20) NOT NULL,
  JOB bigint(20) NOT NULL default 0,
  LOAD_DATE timestamp NOT NULL,
  LOAD_HOST char(100) NOT NULL,
  FINISH_DATE date NOT NULL,
  FINISH_TIME time NOT NULL,
  TYPE char(50) NOT NULL,
  URI char(200) NOT NULL,
  ACTION char(100) NOT NULL default '',
  DETAILS char(255) NOT NULL default '',
  SIZE bigint(20) NOT NULL default 0,
  RESULT char(255) NOT NULL,
  CONTROLLER_MILLIS bigint(20) NOT NULL,
  FULL_MILLIS bigint(20) NOT NULL
);

alter table N_EVENTS add index DATE_IDX (FINISH_DATE)
                   , add index URI_ACT_IDX (URI,ACTION)
                   , add index DASH_JOB_IDX (DASHBOARD,JOB);

-- SQL to import results
load data local infile 'N_EVENTS.all'
into table N_EVENTS
fields terminated by ',' optionally enclosed by '"' 
lines terminated by '\\n' 
(LOST_HOST,DASHBOARD,REVISION,TYPE,JOB,FINISH_DATE,FINISH_TIME,URI,ACTION,DETAILS,RESULT,CONTROLLER_MILLIS,FULL_MILLIS,SIZE) 

-- Here is an example to store your results.
mysqlimport --compress --columns='LOAD_HOST,DASHBOARD,REVISION,TYPE,JOB,FINISH_DATE,FINISH_TIME,URI,ACTION,DETAILS,RESULT,CONTROLLER_MILLIS,FULL_MILLIS,SIZE' --fields-optionally-enclosed-by='"' --fields-terminated-by=',' --lines-terminated-by='\\n' --local -uroot -p -h localhost stats events.csv

"""
import MySQLdb
import re
import sys
import datetime
import os
import os.path

from xml.dom.minidom import parse
from socket import gethostname;

def getConfigs(dbConfig):
  p = os.path.abspath(dbConfig)
  d = os.path.dirname(p)
  d = os.path.dirname(d)
  d = os.path.dirname(d)
  d = os.path.dirname(d)
  cfg = d + "/base-dashboard.cfg"
  props = {}
  parse = re.compile(r"export (\w+)=(.*)")
  for pair in open(cfg):
    k,v = parse.search(pair).group(1,2)
    props[k] = v.strip('"')
  return props

if len(sys.argv) <= 2:
  print __doc__
  sys.exit(1)

def timeToMillis(delta):
  if delta != None:
    seconds = (delta.seconds + delta.days * 24 * 3600)
    return seconds * 1000
  else:
    return None

feedQuery = """
select e.id job_id
     , e.type
     , date(s.end_date)
     , time(s.end_date)
     , s.name
     , s.description description
     , s.status
     , timediff(s.end_date, s.start_date) c_time 
     , ${SIZE_CLAUSE}
  from N_JOB_EXECUTIONS e
  join N_STEPS s on e.id = s.job_id
where e.type in ('DataFeed', 'Publish')
  and e.end_date between '${END}' and DATE_ADD('${END}', INTERVAL 1 DAY) 
  and s.name != 'Render Map Builder - aggregate table creation'
  and s.type not in ('Publish', 'Generate Fill Data Files', 'Generate Full Data Files', 'Generate Preview Files', 'Generate Print Sample Files', 'Generate Proofs', 'Generate Additional Files', 'Cleanup')
group by e.id, s.id
"""

def q(input):
  return str(input).replace('"', '""').replace("\n","\\n")

def format(hostname, dashboard, revision, row):
  job, jobType, date, time, name, description, status, millis, size = row
  millis = timeToMillis(millis)
  if millis != None:
    fields = (hostname, dashboard, revision, jobType, job, date, time, name, description[0:100], description, status, millis, millis, size)
    fields2 = tuple(map(q, fields))
    return '"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s",%s,%s,%s,%s' % fields2
  else:
    print >> sys.stderr, 'Ignoring empty time for job', job, ' step:', name
    return None

def hasSizeColumn(cur):
  cur.execute("show columns from N_JOB_EXECUTIONS like 'SIZE'")
  numrows = int(cur.rowcount)
  return numrows > 0

dom = parse(sys.argv[1])
configs = getConfigs(sys.argv[1])
dashboard = configs['URL']
revision = configs['REVISION']
date = sys.argv[2]
resources = dom.getElementsByTagName("Resource")
if len(resources) > 1:
  print "Config had too many datasources."
  sys.exit(2)
if len(resources) == 0:
  print "Config had zero datasources."
  sys.exit(3)

resource = resources[0]
url = resource.getAttribute('url')
parser = re.compile(r"jdbc:mysql://(?P<host>[^/]+)/(?P<dbName>[^\?]+)")
m = parser.search(url)
host, dbName = m.group('host', 'dbName')

username = resource.getAttribute('username')
password = resource.getAttribute('password')
#print host, dbName, username, password


#sys.exit(0)

con = None
cur = None
#print feedQuery

try:
  hostname = gethostname()
  outFile = "N_EVENTS.jobs." + date
  out = open(outFile, 'w')
  con = MySQLdb.connect(host, username, password, dbName)
  cur = con.cursor()
  # Pre-shadowcat does not have this column.
  if hasSizeColumn(cur):
    sizeClause = 'e.size as size'
  else:
    sizeClause = 'NULL as size'
  feedQuery = feedQuery.replace('${END}', date)
  feedQuery = feedQuery.replace('${SIZE_CLAUSE}', sizeClause)
  cur.execute(feedQuery)
  numrows = int(cur.rowcount)

  # Do DataFeeds
  for i in range(numrows):
    row = cur.fetchone()
    output = format(hostname, dashboard, revision, row)
    if output != None:
      out.write(output)
      out.write('\n')

  #  cur.execute(publishQuery)

finally:
  if con != None:
    con.close()
  if cur != None:
    cur.close()
  out.close()

