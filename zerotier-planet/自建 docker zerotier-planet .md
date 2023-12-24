# 自建zerotier-planet

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
```

## 下载并编译配置文件 破解成真正的planet服务器，并使用你真正的服务器上的公网ip

```
git clone https://github.com/zerotier/ZeroTierOne.git
```
从容器中拷贝identity.public文件到到宿主机root下，打开复制文件代码
```
docker cp ztncui:/var/lib/zerotier-one/identity.public /root/
```
修改 mkworld.cpp 内容，破解成真正的planet服务器，并使用你真正的服务器上的公网ip
```
cd ./ZeroTierOne/attic/world/
```
```
sed -i '/roots.push_back/d' ./mkworld.cpp                                                                      # 删除mkworld.cpp文件内的所有roots.push_back源代码
sed -i '/roots.back()/d' ./mkworld.cpp                                                                         # 删除mkworld.cpp文件内的所有roots.back()源代码
sed -i '85i roots.push_back(World::Root());' ./mkworld.cpp                                                     # 在85行重新添加roots.push_back(World::Root())mkworld.cpp
sed -i '86i roots.back().identity = Identity(\"'"填写identity.public里的字符串"'\");' ./mkworld.cpp             # 在86行重新添加
sed -i '87i roots.back().stableEndpoints.push_back(InetAddress(\"'"服务器ip地址/通讯端口"'\"));' ./mkworld.cpp   # 在8７行默认通讯端口是9993，可以自行修改
```
注：如使用FinalShell ssh工具 用ssh工具直接编辑修改  删除 // Miami // Tokyo // Amsterdam 下的所有内容

修改 // Los Angeles 下内容
```
	// Los Angeles
	roots.push_back(World::Root());
	roots.back().identity = Identity("填写identity.public里的字符串");
	roots.back().stableEndpoints.push_back(InetAddress("185.180.13.82/9993"));      # 服务器ip地址/9993  默认通讯端口是9993，可以自行修改
```
build & 生成 planet 文件
```
source ./build.sh
./mkworld
mv ./world.bin ./planet
cp -r ./planet /root/﻿​       # 保存 planet 文件，用于客户端
docker cp -r /root/planet ﻿​ztncui:/var/lib/zerotier-one/  # 把生成的planet拷贝到docker容器，替换原来的planet文件
```

## 在容器内操作

进入docker容器
```
docker exec -it ztncui bash

cd /var/lib/zerotier-one
ls -l  # 查看zerotier-idtool所在位置

# 生成moon配置文件
zerotier-idtool initmoon identity.public > moon.json
chmod 777 moon.json
```
按 Ctrl + q 退出docker容器 or 输入 exit 退出docker容器

拷贝moon.json到宿主机, 修改stableEndpoints
```
docker cp ztncui:/var/lib/zerotier-one/moon.json /root/
```
## 在root下打开编辑moon.json文件修改  修改stableEndpoints, 注意格式和实际公网ip
```
{
 "id": "45641b5d33",   # 注 45641b5d33 就是moon id
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
把修改好的moon.json拷贝回docker容器中
```
docker cp root/moon.json ztncui:/var/lib/zerotier-one/
```
在容器内生成moon文件
```
zerotier-idtool genmoon moon.json
mkdir moons.d
cp *.moon moons.d/
```
从容器中拷贝moon文件到宿主机root下
```
docker cp ztncui:/var/lib/zerotier-one/*.moon /root/
```
## 重启容器

```
docker restart ztncui
docker exec -it ztncui bash # 进入容器
# 在容器内操作
cd /var/lib/zerotier-one
#　查看ｍoon
zerotier-cli listmoons
```
访问ip+端口对应的设置页面

替换客户端的planet文件并重启服务， 再加入网络， 在网页端授权

---

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
