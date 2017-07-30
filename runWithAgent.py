#!/usr/bin/env python
import pexpect
import pxssh
import getpass
import sys

program = sys.argv[1]
print 'Executing', program, 'within an agent.'
child = pexpect.spawn('ssh-agent /bin/bash', timeout=600)
prompt = '.*\$ '
child.expect(prompt)
child.sendline('ssh-add')
child.expect('.*passphrase.*: ')
child.sendline("Don't tread on me!")
print 'Agent setup'
child.expect(prompt)
child.sendline(program)
child.expect(prompt)
print child.after
child.sendline('ssh-agent -k')

