#!/usr/bin/expect
set timeout 5; set first_height 200; set second_height 0; set viewed_block_size 140; set sleep 2; set count 0; 
spawn telnet localhost 8081; expect "Please enter password:"; send "sanity\r";
for {set y $2} {$y < $3} {incr y $viewed_block_size} {
  for {set x $2} {$x < $3} {incr x $viewed_block_size} { 
    incr count; send "bc-teleport entity $1 $x $first_height $y\r"; sleep $sleep; send "bc-teleport entity $1 $x $second_height $y\r"; sleep $sleep
  }
}
send "bc-teleport entity $1 0 0 0\r"; send "exit\r"; expect eof