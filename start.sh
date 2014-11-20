#!/bin/sh

. /app/conf/varnish_vars.sh
handlebars --redirects "$VARNISH_REDIRECTS" --apps "$VARNISH_APPS" < /app/conf/varnish.vcl.handlebars > /etc/varnish/default.vcl
varnishd -f /etc/varnish/default.vcl -s malloc,100M -a 0.0.0.0:80
varnishncsa -w /log/access.log
