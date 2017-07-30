#!/usr/bin/python

import sys
import subprocess
cmd = "knife cookbook upload mv-fi-aio-test"
p = subprocess.Popen(cmd, shell=True, stderr=subprocess.PIPE)
while True:
    out = p.stderr.read(1)
    if out == '' and p.poll() != None:
        break
    if out != '':
        sys.stdout.write(out)
        sys.stdout.flush()
