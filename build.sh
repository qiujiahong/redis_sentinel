#!/bin/bash

export ver=v1.1
# docker build --no-cache -t qiujiahong/redis_sen:$ver ./
docker build -t qiujiahong/redis_sen:$ver ./
# docker run -d -p 6379:6379 -p 6479:6479 -p 6579:6579 -p 26379:26379 qiujiahong/redis_sen 

docker push qiujiahong/redis_sen:$ver


docker tag qiujiahong/redis_sen:$ver qiujiahong/redis_sen:latest
docker push qiujiahong/redis_sen:$ver
docker push qiujiahong/redis_sen:latest


# docker run -d -p 6379:6379 -p 6479:6479 -p 6579:6579 \
#           -p 26379:26379 qiujiahong/redis_sen