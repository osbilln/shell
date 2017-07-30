#!/usr/bin/env python
"""
Produces a CSV that represents UI events.
  ./parseDashboardRequests.py dashboard.log

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

alter table N_EVENTS 
    add index DATE_IDX (FINISH_DATE)
  , add index URI_ACT_IDX (URI,ACTION)
  , add index JOB_IDX (JOB)
  , add index DASH_RELEASE_IDX (DASHBOARD,REVISION);

-- SQL to import results
load data local infile 'N_EVENTS.all'
into table N_EVENTS
fields terminated by ',' optionally enclosed by '"' 
lines terminated by '\n' 
(LOAD_HOST,DASHBOARD,REVISION,FINISH_DATE,FINISH_TIME,TYPE,URI,ACTION,RESULT,CONTROLLER_MILLIS,FULL_MILLIS) 

-- Here is an example to store your results.
mysqlimport --compress --columns='LOAD_HOST,DASHBOARD,REVISION,FIN_DATE,FIN_TIME,TYPE,URI,ACTION,RESULT,C_MILLIS,F_MILLIS' --fields-optionally-enclosed-by='"' --fields-terminated-by=',' --lines-terminated-by='\\n' --local -uroot -p -h localhost stats events.csv
  
-- Here is an example of how to query the table
select dashboard
     , finish_date
     -- , hour(finish_time) hr
     , uri,action
     , min(controller_millis) min_ms
     , avg(controller_millis) average
     , max(controller_millis) max_ms
     , stddev(controller_millis) stddev
     , count(*) count 
from N_EVENTS 
where finish_date > '2012-02-08'
 and uri = '/dashboard/lp/job/getjobs'
 and dashboard like 'DMI%'
group by dashboard, finish_date, 
-- hour(finish_time), 
uri, action
order by finish_date
;

select distinct finish_date from N_EVENTS where dashboard = 'DMIPlatformDashboard'
;

"""
import re
import sys
import datetime
import os
import os.path
from socket import gethostname;

def timeToMillis(delta):
  hours, minutes, seconds = delta.split(':')
  return 1000*60*(60*int(hours) + int(minutes)) + int(float(seconds)*1000)

def q(input):
  return str(input).replace('"', '""').replace("\n","\\n")

def printStats(hostname, dashboard, revision, stats):
  finishDate, finishTime, method, uri, action, result, conTime, fullTime = stats
  conTime = timeToMillis(conTime)
  fullTime = timeToMillis(fullTime)
  fields = (hostname, dashboard, revision, finishDate, finishTime, method, uri, action, result, conTime, fullTime)
  fields2 = tuple(map(q, fields))
  #       hst, dash,rev, fin, time,mthd,uri, act, res, ct,ft
  return '"%s","%s","%s","%s","%s","%s","%s","%s","%s",%s,%s' % fields2

def parseEvent(parser, hostname, dashboard, revision, event):
  event = event.replace('\n', '\\n')
  m = parser.search(event)

  # print event
  if m != None:
    return printStats(hostname, dashboard, revision, m.group('finishDate', 'finishTime', 'method', 'uri', 'action', 'result', 'conTime', 'fullTime'))
  else:
    print >> sys.stderr, event
    return ''

# Search for base-dashboard.cfg

def getConfigs(logFilename):
  p = os.path.abspath(logFilename)
  d = os.path.dirname(p)
  d = os.path.dirname(d)
  cfg = d + "/base-dashboard.cfg"
  props = {}
  parse = re.compile(r"export (\w+)=(.*)")
  for pair in open(cfg):
    k,v = parse.search(pair).group(1,2)
    props[k] = v.strip('"')
  return props

if len(sys.argv) <= 1:
  print __doc__
  sys.exit(1)

parser = re.compile(r" INFO (?P<finishDate>[-\d]+) (?P<finishTime>[\d:,]+).*METHOD=(?P<method>\w+), URI=(?P<uri>[^,]+), (PARAMS=\{.*action=(?P<action>\w+).*\}, )?.*RESULT=(?P<result>.+), TIMES=(?P<conTime>[\d:.]+)/(?P<fullTime>[\d:.]+)")

# Since audit events can be multi-lined, need a state machine to join them.
state = 0
hostname = gethostname()
for logFile in sys.argv[1:]:
  configs = getConfigs(logFile)
  dashboard = configs['URL']
  revision = configs['REVISION']
  outFile = "N_EVENTS." + os.path.basename(logFile)
  out = open(outFile, "w")
  log = open(logFile)
  for line in log:
    if state == 0:
      if line.find('AuditingInterceptor') >= 0 and line.find('METHOD=') >= 0:
        state = 1
        event = line
        if line.find('TIMES=') >= 0:
          state = 2
    elif state == 1:
      event = event + line
      if line.find('TIMES=') >= 0:
        state = 2

    if state == 2:
      # parse the event
      output = parseEvent(parser, hostname, dashboard, revision, event)
      out.write(output)
      out.write('\n')

      # reset state
      event = ''
      state = 0
  out.close()
  log.close()

