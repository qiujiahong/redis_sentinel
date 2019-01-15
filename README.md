# redis sentinel

本项目在单台电脑部署redis哨兵,部署方式为1哨兵，1主，2从模式。


## 执行

* 后台执行

```
docker run -d -p 6379:6379 -p 6479:6479 -p 6579:6579 \
          -p 26379:26379 qiujiahong/redis_sen:latest
```

* 后台执行,指定master ip 

```
docker run -d -p 6379:6379 -p 6479:6479 -p 6579:6579 \
          -p 26379:26379 \
          -e MASTER_IP=192.168.7.77 qiujiahong/redis_sen:latest
```

## 参数

* MASTER_IP  主机ip地址 默认值为127.0.0.1,如果使用redis的应用和redis不在同一个主机上，可以修改该ip为主机ip地址；


## 端口

* 6379   master 端口
* 6479   slave  端口
* 6579   slave  端口
* 26379  sentinel端口