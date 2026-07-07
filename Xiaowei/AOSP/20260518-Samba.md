# 什么是Samba？

Samba是可以在Debian/LInux上用于和Windows系统共享文件的服务程序。利用SMB协议实现局域网内不同设备之间的文件互访。通过在本地部署Samba，可以方便地向Windows、LInux或者macOS客户端提供共享目录，实现跨平台的文件传输与写作。

# 安装Samba

## 1.更新软件包列表

```shell
# 使系统获取最新的软件源信息，避免安装旧版本软件
sudo apt-get update
```

## 2.安装Samba及客户端工具

```shell
# 1.安装Samba服务
sudo apt install samba

# 2.安装客户端工具（可选）
sudo apt install smbclient
```

## 3.确认Samba安装成功

```shell
# 查看版本
sudo samba -V
```

# 创建共享文件夹

## 1.创建共享目录

```shell
# -p:递归创建文件夹
mkdir -p <路径>
# 例子
mkdir -p /home/pi/share
```

## 2.创建测试文件

```shell
# touch:创建/刷新文件
touch /home/pi/share/test.txt
```

## 3.修改权限

```shell
chmod -R 777 /home/pi/share
```

# 配置Samba服务

## 1.打开配置文件

```shell
sudo vim /etc/samba/smb.conf
```

## 2.滚动到文件末尾，添加以下内容

```shell
[myshare] #这里的myshare可以改成任意你想要的名字，Windows客户端访问时看到的共享名称
    comment = My Shared Folder
    browseable = yes
    path = /home/pi/share #想要共享的文件夹，共享目录的实际路径
    create mask = 0777 #新建文件/文件夹的默认权限
    directory mask = 0777
    valid users = pi
    force user = android #允许访问Samba服务器的合法用户，此处示例用户为android
    force group = pi
    public = yes
    writable = yes #允许客户端在此目录中创建、修改和删除文件
    available = yes
```

# 设置Samba用户和密码

Samba的登录用户需要单独设置密码。
以系统用户`android`为例：

```shell
sudo smbpasswd -a android
```

# 设置Samba服务开机自启动，并使配置生效

```shell
# 设置Samba服务开机自启动
sudo systemctl enable smbd
# 重启Samba服务
sudo systemctl restart smbd
```

# 查看设备IP地址

```shell
ifconfig
```

# Windows电脑访问共享文件夹

1.按下"Win+R"打开运行窗口

2.输入"`\\+设备的IP地址`"

3.输入用户名和密码，即可看到共享文件夹的内容