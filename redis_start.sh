#!/bin/sh

start() {
  sed -i 's/^slaveof.*/slaveof '${MASTER_IP-127.0.0.1}'/g' /etc/redis/6479.conf 
  sed -i 's/^slaveof.*/slaveof '${MASTER_IP-127.0.0.1}'/g' /etc/redis/6579.conf 
  sed -i 's/^sentinel monitor mymaster.*/sentinel monitor mymaster '${MASTER_IP-127.0.0.1}' 6379 1/g' /etc/redis/26379.conf 
  echo start:6379 
  redis-server /etc/redis/6379.conf
  echo start:6479 
  redis-server /etc/redis/6479.conf
  echo start:6579 
  redis-server /etc/redis/6579.conf

  echo start:26379 
  redis-sentinel /etc/redis/26379.conf
}

stop() {
    ps -ef | grep redis | grep -v grep|awk '{print $2}'| xargs kill -9 
}

restart(){
    stop
    sleep 2
    start
}

case "$1" in
  start)
      start
      RETVAL=$?
  ;;
  stop)
      stop
      RETVAL=$?
  ;;
  restart)
      restart
      RETVAL=$?
  ;;
  *)
  echo "USAGE:$0 {start|stop|restart}"
esac