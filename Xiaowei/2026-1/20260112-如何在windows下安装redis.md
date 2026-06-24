# 先去github仓库下载redis

路径：[Releases · microsoftarchive/redis](https://github.com/microsoftarchive/redis/releases)

![img](https://developer.qcloudimg.com/http-save/yehe-100000/22c0e156db17221c702f97108a2b3e57.png)

# 修改redis密码

打开配置文件，找到requirepass 修改成自己想要的密码即可

![image-20260112104805758](C:\Users\admin38\AppData\Roaming\Typora\typora-user-images\image-20260112104805758.png)

# redis自启动

## 注册redis服务

```bash
redis-server.exe --service-install redis.windows.conf --loglevel verbose
```

## 设置自启动

按`Win+R`，输入`services.msc`，找到redis服务

![img](https://developer.qcloudimg.com/http-save/yehe-100000/02dccc8280585e2ff23c16d642f4d340.png)

将启动类型设置为自动即可
