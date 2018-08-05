# redis sentinel

本项目在单台电脑部署redis哨兵

## 编译执行

```
docker build -t qiujiahong/redis_sen ./
docker run -d -p 6379:6379 -p 6479:6479 -p 6579:6579 -p 26379:26379 qiujiahong/redis_sen 
```

## 上传到docer hub

* 上传

```bash
# 使用你的账户登陆dockerhub
docker login                           
docker push qiujiahong/redis_sen    
```

* 标记版本，上传

```bash
docker tag qiujiahong/redis_sen qiujiahong/redis_sen:v1
docker push qiujiahong/redis_sen:v1
```