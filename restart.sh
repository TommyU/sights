#! bin/sh
ps afux | grep nginx | grep -v grep | awk '{print $2}' | xargs kill -9
openresty -p /root/sights/
