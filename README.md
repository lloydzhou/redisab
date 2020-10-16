# RedisAB

## 总体设计
1. 数据持久化到redis里面
2. 大量使用redis-lua脚本（基本每一个接口都是使用redis-lua脚本实现，提升性能的同时，能利用redis-lua脚本的原子性达到类似事务的效果）
3. 设计一个测试环境和正式环境，通过"X-Env"识别，数据通过redis db分开存储
4. 通过"X-User-Id"传递user_id
5. 设计一个控制台管理流量层和实验（登录使用http auth_basic）


## 启动项目
> Makefile中已经将各个任务综合起来，单独运行一下make命令就可以完成整个流程
```
make
```
1. 首先build docker镜像
2. 然后编译控制台页面
3. 使用docker-compose启动项目
4. 运行Makefile中的init-redis将redis-lua脚本load进去


## 接口
1. 获取变量接口
```
curl "localhost:8011/ab/var?name=var1" -H 'X-Env: dev' -H 'X-User-Id: 0001'

--> 

返回当前user_id(0001)在这个实验中分配的变量: 类型是数字，值为2
{"value":"2","msg":"success","layer":"layer1","code":0,"hash":838060847,"test":"test1","type":"number"}
```
2. 回传指标接口

```
上传名字为target1的指标，代表user_id=0001这个用户在当前实验版本下产生转化的指标
curl "localhost:8011/ab/track?name=var1" -H 'X-Env: dev' -H 'X-User-Id: 0001' -d '{"target1": 1}'

--> 

{"msg":"success","code":0}
```

## demo
1. 创建一个名字叫layer1的流量层
![image](https://user-images.githubusercontent.com/1826685/96210922-92180400-0fa5-11eb-9b35-6d818ec3f820.png)
2. 在这个流量曾创建一个名字叫test1的实验
3. 给这个实验创建两个版本(value=0/1)分别分配50%的流量
4. 给这个实验创建一个叫做target1的指标
![image](https://user-images.githubusercontent.com/1826685/96210953-a2c87a00-0fa5-11eb-988e-de6645b9c852.png)
![image](https://user-images.githubusercontent.com/1826685/96210985-b542b380-0fa5-11eb-8183-6118a49cd3ba.png)

