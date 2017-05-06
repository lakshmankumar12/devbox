#!/usr/bin/python

import pexpect

child = pexpect.spawn("sudo",["/etc/init.d/ssh","restart"])
child.expect("word.*:")
child.sendline("lakshman")

child = pexpect.spawn("bash")
child.interact()
