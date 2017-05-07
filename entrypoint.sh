#!/usr/bin/python

import pexpect

child = pexpect.spawn("sudo",["/etc/init.d/ssh","start"])
child.expect("word.*:")
child.sendline("lakshman")
child.expect("Starting OpenBSD")

child = pexpect.spawn("bash")
child.interact()
