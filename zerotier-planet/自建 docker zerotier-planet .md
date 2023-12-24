# 自建zerotier-planet

私有部署zeroteir-planet服务
基于 [ztncui](https://github.com/key-networks/ztncui-aio) 整理成 docker-compose.yml 文件.

**特别感谢** <https://github.com/Jonnyan404/zerotier-planet/issues/11#issuecomment-1059961262> 这个issue中各位用户的贡献，基于此issue中 `@jqtmviyu` 的步骤和`kaaass`的 [mkmoonworld](https://github.com/kaaass/ZeroTierOne/releases/tag/mkmoonworld-1.0) 制作成目前的patch（集成planet和moon）。

# 必要条件

- 具有公网ip的服务器
- 安装 docker
- 安装 docker-compose
- 防火墙开放TCP端口 4000/9993/3180 和UDP端口 9993

# 用法

在要搭建的服务器 root 下创建 docker-compose.yml 空白文件，编辑docker-compose.yml文件，复制下面代码，粘贴到docker-compose.yml文件保存
```
version: '2.0'
services:
    ztncui:
        container_name: ztncui
        restart: always
        environment:
            - MYADDR=1.1.1.1 #改成自己的服务器公网IP
            - HTTP_PORT=4000
            - HTTP_ALL_INTERFACES=yes
            - ZTNCUI_PASSWD=admin
        ports:
            - '4000:4000' # web控制台入口
            - '9993:9993'
            - '9993:9993/udp'
            - '3180:3180' # planet/moon文件在线下载入口，如不对外提供。可防火墙禁用此端口。
        volumes:
            - './zerotier-one:/var/lib/zerotier-one'
            - './ztncui/etc:/opt/key-networks/ztncui/etc'
            # 按实际路径挂载卷， 冒号前面是宿主机的， 支持相对路径
        image: keynetworks/ztncui
```
运行
```
docker-compose up -d

docker images #　查看镜像
docker container ps -a # 查看容器

docker exec -it ztncui bash # 进入容器
# 在容器内操作
cd /var/lib/zerotier-one
ls -l  # 查看zerotier-idtool所在位置
# 生成moon配置文件
zerotier-idtool initmoon identity.public > moon.json
chmod 777 moon.json
```
按 Ctrl + q 退出docker容器 or 输入 exit 退出docker容器
```
docker cp ztncui:/var/lib/zerotier-one/moon.json /root/
---
在root下打开编辑moon.json文件修改  修改stableEndpoints, 注意格式和实际公网ip
```
{
 "id": "45641b5d33",
 "objtype": "world",
 "roots": [
  {
   "identity": "13241b5d33:0:e50a3fab865372a34ab9b459ce246858d94dc0a7030fa02374a083068be55f083e9e964dee71d624cfec5bfdadae0aaee311dc63592cc91a8de5e8f744954e5f",
   "stableEndpoints": ["公网ip地址/9993"]
  }
 ],
 "signingKey": "ebec873da46fd9a81e69013d3c576ea9f916a0a604d88e654dcdbb6a211daa49ce2f836527444fecc8d4d87f53790b706a5d371b0531c0b2afebd78c19dd6014",
 "signingKey_SECRET": "e3fb79d6d282c9fd1c289085a9956b4beaf6632bda10d44ded75e10dcffdfe897cfec22c1060b156a385592ad9897b2c1164666cd74d3e6e2ac6fbbcab462aaf",
 "updatesMustBeSignedBy": "ebec873da46fd9a81e69013d3c576ea9f916a0a604d88e654dcdbb6a211daa49ce2f836527444fecc8d4d87f53790b706a5d371b0531c0b2afebd78c19dd6014",
 "worldType": "moon"
}
```


# 用法 注：此用法不能独立于官方，所产生的planet也不是自己服务器ip

```
git clone https://github.com/Jonnyan404/zerotier-planet
OR
git clone https://gitee.com/Jonnyan404/zerotier-planet

cd zerotier-planet
docker-compose up -d
# 以下步骤为创建planet和moon
docker cp mkmoonworld-x86_64 ztncui:/tmp
docker cp patch.sh ztncui:/tmp
docker exec -it ztncui bash /tmp/patch.sh
docker restart ztncui
```

然后浏览器访问 `http://ip:4000` 打开web控制台界面。

浏览器访问 `http://ip:3180` 打开planet和moon文件下载页面（亦可在项目根目录的`./ztncui/etc/myfs/`里获取）。


- 用户名:admin
- 密码:mrdoc.fun

# 各客户端配置planet

限于篇幅，请到 <https://www.mrdoc.fun/doc/443/> 查阅


# 关联云服务器(带公网IP)

[【腾讯云】云产品限时秒杀，爆款2核4G云服务器，首年74元](https://curl.qcloud.com/S2Db7PLK)


### 私有 zerotier-planet 的优势:
- 解除官方 25 的设备连接数限制
- 提升手机客户端连接的稳定性

# 同类型项目推荐

https://github.com/xubiaolin/docker-zerotier-planet

# Reference Link

- <https://www.mrdoc.fun/doc/443/>
- <https://github.com/key-networks/ztncui-aio>
