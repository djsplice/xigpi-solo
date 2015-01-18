#!/bin/bash

PATH=/bin:/usr/bin:/sbin:/usr/sbin

PIDFILE=/var/tmp/phonehome.pid

case $1 in
  start)
  `autossh -f -M 0 -TqNC -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=5 -i /home/pi/.ssh/phonehome.key -R *:2013:localhost:8000 jeff@192.168.1.69`;
  p=$(pidof autossh)
  echo $p > ${PIDFILE};
  ;;
  stop)
  kill `cat ${PIDFILE}`
  ;;
  *)
  echo "usage: phonehome {start|stop}" ;;
esac
exit 0
