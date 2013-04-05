#!/bin/sh

script/donmai/downbooru
sleep 5
ps aux | grep Rack | grep Rl | cut -c10-15 | xargs kill -SIGTERM
script/donmai/upbooru
