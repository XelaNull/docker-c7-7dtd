#!/usr/bin/expect
set timeout 5
set command [lindex $argv 0]
spawn telnet localhost 8081
expect "Please enter password:"
send "sanity\r";
send "$command\r"
send "exit\r";
sleep 1
expect eof
send_user "Sent command to 7DTD: $command"