#!/usr/bin/expect
set timeout 5
spawn telnet localhost 8081
expect "Please enter password:"
send "sanity\r";
set interval 140
set sleep 3

send "admin add xShoudenx 0\r"
sleep 1
send "rendermap\r"
sleep 1
send "enablerendering\n"
sleep 1

for {set y -3750} {$y < 3750} {incr y $interval} {

for {set x -3750} {$x < 3750} {incr x $interval} {
 send_user "Teleporting xShoudenx to $x 0 $y\n"
 send "bc-teleport entity xShoudenx $x 0 $y\r"
 sleep $sleep
}

}
send "bc-teleport entity xShoudenx 0 0 0\r"
send "exit\r";
expect eof