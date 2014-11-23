#!/bin/sh

# generate config
/app/generate-conf > /etc/varnish/default.vcl

# start varnish
varnishd -f /etc/varnish/default.vcl -s malloc,100M -a 0.0.0.0:80

# trigger auto-reload on etcd change
etcdctl --no-sync --peers $ETCD_PORT_4001_TCP_ADDR:$ETCD_PORT_4001_TCP_PORT exec-watch --recursive /varnish -- /app/reload-conf &

# output logs; this will block; docker will monitor this process
sleep 1;
varnishncsa -w /log/access.log
