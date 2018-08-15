#!/bin/bash

HOST='127.0.0.1' 
NODE_PORTS=(6379 6479 6579)
SEN_PORTS=(26379)
CMD='help'
DOWNLOAD=false
CONF_PATH='/etc/redis/'
# CONF_PATH='./'

MASTER_PORT=''


array=()
function split(){
  split_ret=${1//=/ }
  count=0
  for e in $split_ret
  do 
    array[$count]=$e
    let count++
  done 
}

function help(){
  echo "help cmd:"
  echo "./redis.sh --[options]=[options values] ... [cmd]  "
  echo ""
  echo "             --h=[ip]          eg: --h=127.0.0.1         -host ip address"
  echo "             --n=[port],...    eg: --n=6379,6479,6579    -nodes port"
  echo "             --s=[port],...    eg: --s=26379,26479,26579 -sentinels port"
  echo "             --download                                  -download redis from web"
  echo ""
  echo "           [cmd]"
  echo "             install  ...... install redis"
  echo "             remove   ...... remove redis"
  echo "             conf     ...... generate conf file in current path"
  echo ""
  echo "           [examples]"
  echo "             ./redis.sh install                 # install redis by the default command"
  echo "             ./redis.sh --download  install     # download and install redis by the default command"
  echo "             ./redis.sh remove                  # remove redis"
  return ;
}

function install_tools(){
  echo "install tools"
  yum install -y wget 
  yum -y install net-tools 
  yum -y install gcc automake autoconf libtool make 
}

function download_redis(){
    if $DOWNLOAD ; then
      echo "download redis..."
      rm -rf 4.0.9.tar.gz
      wget https://github.com/antirez/redis/archive/4.0.9.tar.gz
    else
      echo "do not download redis..."
    fi
}

function nodes_conf(){
cat > ${CONF_PATH}redis.conf <<"EOF"
#bind {REDIS_IP}
protected-mode no
port {PORT}
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
pidfile "/var/run/redis_{PORT}.pid"
loglevel notice
logfile "/var/log/redis/{PORT}.log"
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename "dump_{PORT}.rdb"
dir /opt/soft/redis/data
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no
appendonly no
appendfilename "appendonly_{PORT}.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble no
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
EOF


first=true
for port in ${NODE_PORTS[@]}
do 
  sed "s/{PORT}/${port}/g" ${CONF_PATH}redis.conf > ${CONF_PATH}${port}.conf
  sed -i "s/{REDIS_IP}/${HOST}/g" ${CONF_PATH}${port}.conf

  if $first ; then
    first=false
    MASTER_PORT=$port
    echo "first port:"$port
  else
    echo "port:"$port
    echo "REDIS_IP:"$HOST
    echo "slaveof $HOST $MASTER_PORT" >> ${CONF_PATH}${port}.conf
  fi
done

}

function sentinels_conf(){
cat > ${CONF_PATH}sen_redis.conf<<"EOF"
port {PORT}
protected-mode no
daemonize yes
dir "/opt/soft/redis/data"
logfile "/var/log/redis/{PORT}.log"
sentinel monitor mymaster {MASTER_IP} {MASTER_PORT} {quorum}
sentinel failover-timeout mymaster 60000
sentinel down-after-milliseconds mymaster 10000
EOF

quorum=${#SEN_PORTS[@]}
quorum=`expr $quorum / 2`
quorum=`expr $quorum + 1`
echo $quorum


first=true
for port in ${SEN_PORTS[@]}
do 
  sed "s/{PORT}/${port}/g" ${CONF_PATH}sen_redis.conf > ${CONF_PATH}${port}.conf
  sed -i "s/{MASTER_IP}/${HOST}/g" ${CONF_PATH}${port}.conf
  sed -i "s/{MASTER_PORT}/${MASTER_PORT}/g" ${CONF_PATH}${port}.conf
  sed -i "s/{quorum}/${quorum}/g" ${CONF_PATH}${port}.conf

  if $first ; then
    first=false
    echo ""
  else
    echo ""
    #echo "sentinel down-after-milliseconds mymaster 10000" >> ${CONF_PATH}${port}.conf
  fi

done
}

function mk_path(){
  sed -i '/^export PATH.*/d' ~/.bash_profile 
  echo "PATH=$PATH:/usr/local/redis/bin" >> ~/.bash_profile 
  echo "export PATH" >> ~/.bash_profile 
  source ~/.bash_profile   
  mkdir -p /etc/redis 
  mkdir -p /opt/soft/redis/data 
  mkdir -p /var/log/redis 
}

function poweron_start(){
cat > /etc/rc.d/init.d/redis <<"EOF"
#!/bin/sh
#chkconfig:345 86 15
#description:redis service

start() {
EOF
echo "source ~/.bash_profile" >> /etc/rc.d/init.d/redis

for port in ${NODE_PORTS[@]}
do 
  echo "echo start:${port}" >> /etc/rc.d/init.d/redis
  echo "redis-server /etc/redis/${port}.conf" >> /etc/rc.d/init.d/redis
done

for port in ${SEN_PORTS[@]}
do 
  echo "echo start sentinel:${port}" >> /etc/rc.d/init.d/redis
  echo "redis-sentinel /etc/redis/${port}.conf" >> /etc/rc.d/init.d/redis
done


cat >> /etc/rc.d/init.d/redis <<"EOF"
}

stop() {
    ps -ef | grep redis | grep -v grep|awk '{print $2}'| xargs kill -9 
}

restart(){
    stop
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
EOF

chmod +x /etc/rc.d/init.d/redis
chkconfig redis
chkconfig --add redis
service redis start
# config service port 

# config iptables
for port in ${NODE_PORTS[@]}
do 
  iptables -A INPUT -p tcp --dport ${port} -j ACCEPT 
done

for port in ${SEN_PORTS[@]}
do 
  iptables -A INPUT -p tcp --dport ${port} -j ACCEPT 
done
service iptables restart
}


function get_conf(){
  mkdir ./conf
  rm -rf ./conf/* 
  CONF_PATH='./conf/'
  echo "get redis conf."
  mk_path
  nodes_conf
  sentinels_conf
  echo "end get redis conf."
}

function install_redis(){
  echo "install redis..."
  remove_redis
  install_tools
  download_redis
  tar -xzvf 4.0.9.tar.gz 
  cd redis-4.0.9 && make && make PREFIX=/usr/local/redis install 
  mk_path
  nodes_conf
  sentinels_conf
  poweron_start
  echo "end install redis..."
}

function remove_redis(){
  rm -rf ./redis-4.0.9
  sed -i '/^PATH=\/usr.*/d' ~/.bash_profile 
  source ~/.bash_profile   
  rm -rf /usr/local/redis
  rm -rf /etc/redis 
  rm -rf /opt/soft/redis/data 
  rm -rf /var/log/redis 
  rm -rf ./redis-4.0.9
}

for arg in $*
do 
  split $arg
  case ${array[0]} in
        --h)
          HOST=${array[1]}
        ;;
        --n)
          # SENS=${array[1]}
          echo ${array[1]}
        ;;
        --s)
          # SENS=${array[1]}
          echo ${array[1]}
        ;;
        --download)
          DOWNLOAD=true
        ;;
        conf)
          CMD=${array[0]}
        ;;
        install)
          CMD=${array[0]}
        ;;
        remove)
          CMD=${array[0]}
        ;;
        *)
        help
        ;;
  esac
done


# main function 
case $CMD in
  help)
    help
  ;;
  install)
    install_redis
  ;;
  remove)
    remove_redis
  ;;
  conf)
    get_conf
  ;;
  *)
    help
  ;;
esac 

