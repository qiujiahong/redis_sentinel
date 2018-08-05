#!/bin/bash
echo "start redis server..........................."
echo "start master......"
redis-server /etc/redis/6379.conf
echo "start slave 1......"
redis-server /etc/redis/6479.conf
echo "start slave 2......"
redis-server /etc/redis/6579.conf

echo "start sentinel 1......"
redis-sentinel /etc/redis/26379.conf

tail -f /var/log/redis/26379.log
