#!/bin/bash

PIDFILE=/var/tmp/xigpi.pid

case $1 in
  start)
  echo $$ > ${PIDFILE};
  cd /opt/xigpi
  exec python ./gui/xig_app.py
  ;;
  stop)
  kill `cat ${PIDFILE}` ;;
  *)
  echo "usage: xig.sh {start|stop}" ;;
esac
exit 0
