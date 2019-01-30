#!/usr/bin/expect
set timeout 5
spawn telnet localhost 8081
expect "Please enter password:"
send "sanity\r";
send "$1\r"
send "exit\r";
sleep 1
expect eof