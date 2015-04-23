#!/usr/bin/env bash

SRC=$(cd $(dirname "$0"); pwd)
source "${SRC}/include.sh"

cd $file_path

function should_more {
    sleep 0.5
    $pm2 jlist > /tmp/tmp_out.txt
    OUT=`cat /tmp/tmp_out.txt | grep -o "$2" | wc -l`
    [ $OUT -eq $3 ] || fail "$1"
    success "$1"
}

echo "################## PMX INJECTION  ###################"

$pm2 kill

echo "Testing pmx injection in fork mode"

$pm2 start child.js
sleep 1
should 'should have injected pmx in fork mode' 'axm_monitor: \[Object\]' 1
should_more 'should have http monitored' '"latency":true' 1

$pm2 delete all
$pm2 start child.js -i 2
sleep 1
should 'should have injected pmx in cluster mode' 'axm_monitor: \[Object\]' 2
should_more 'should have http monitored' '"latency":true' 2

echo "################## PMX OPTIONS OVERRIDE  ###################"

$pm2 delete all
$pm2 start child_no_http.js
sleep 1
should_more 'should not have http monitored' '"latency":true' 0
should_more 'should not have http monitored' '"latency":false' 1

$pm2 delete all
$pm2 start child_no_http.js -i 2
sleep 1
should_more 'should not have http monitored' '"latency":true' 0
should_more 'should not have http monitored' '"latency":false' 2

$pm2 kill
