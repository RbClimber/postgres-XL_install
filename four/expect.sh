#!/bin/sh
expect <<!
spawn ssh pgnode1 exit
expect "(yes/no)?"
send "yes\n"
spawn ssh pgnode2 exit
expect "(yes/no)?"
send "yes\n"
spawn ssh pgnode3 exit
expect "(yes/no)?"
send "yes\n"
expect "#"
interact
!
