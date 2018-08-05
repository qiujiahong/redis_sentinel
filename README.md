# redis 

## 编译执行

```
docker build -t qiujiahong/redis_sen ./
docker run -d -p 6379:6379 -p 6479:6479 -p 6579:6579 -p 26379:26379 qiujiahong/redis_sen 
```

## 上传到docer hub

```bash
# 使用你的账户登陆dockerhub
docker login                           
docker push qiujiahong/redis_sen    
```