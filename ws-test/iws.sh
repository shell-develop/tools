#!/bin/bash
read -p "=====INPUT SERVER PORT:" port
pid=`netstat -nlpt|grep $port|awk '{print $NF}'|awk -F / '{print $1}'`
kill -9 $pid
yum install epel-release -y
yum install python2-pip -y
pip install gevent ws4py
cat > /usr/bin/ws-server.py <<eof
#!/usr/bin/env python
import sys
port = int(sys.argv[1])
from gevent import monkey; monkey.patch_all()
from ws4py.websocket import EchoWebSocket
from ws4py.server.geventserver import WSGIServer
from ws4py.server.wsgiutils import WebSocketWSGIApplication
import logging
from ws4py import configure_logger
try:

    logger = logging.getLogger('ws4py')
    configure_logger()
    server = WSGIServer(('0.0.0.0', port), WebSocketWSGIApplication(handler_cls=EchoWebSocket))
    print("=====START 0.0.0.0:{}=====".format(port))
    server.serve_forever()
except KeyboardInterrupt:
    print ("=====STOP 0.0.0.0:{}=====".format(port))
eof
chmod 755 /usr/bin/ws-server.py
echo ""
/usr/bin/ws-server.py $port
