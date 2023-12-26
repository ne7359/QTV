# zerotier-aio-zh

**注意，本仓库为汉化仓库，提交ISSUE请前往[原仓库](https://github.com/kmahyyg/ztncui-aio)**

- [Github](https://github.com/niliovo/zerotier-aio-zh)
- [Docker Hub](https://hub.docker.com/r/niliaerith/zerotier-aio-zh)
- [Docker 最常用的镜像命令和容器命令](https://zhuanlan.zhihu.com/p/196754771)

# 本项目基于下列项目,汉化 ztncui-aio 并打包镜像

- [zerotier/ZeroTierOne](https://github.niliovo.top/zerotier/ZeroTierOne)
- [kmahyyg/ztncui-aio](https://github.com/kmahyyg/ztncui-aio)
- [key-networks/ztncui](https://github.com/key-networks/ztncui)

# 使用指南

## Docker-Cli使用指南

- 自行构建，在宿主机创建dockerfile/Dockerfile dockerfile/RUNNER.sh dockerfile/ZTNCUI.sh 然后即行命令如下)

```sh
docker build -t zerotier-aio-zh .
```

- amd64/arm64
- host模式

```sh
docker run -itd --name ztncui --hostname ztncui --net host --restart always --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun -v /home/zerotier/opt/key-networks/ztncui/etc:/opt/key-networks/ztncui/etc -v /home/zerotier/var/lib/zerotier-one:/var/lib/zerotier-one -v /home/zerotier/etc/zt-mkworld:/etc/zt-mkworld -e PUID=0 -e PGID=0 -e TZ=Asia/Shanghai -e AUTOGEN_PLANET=0 -e NODE_ENV=production -e HTTPS_HOST=127.0.0.1 -e HTTPS_PORT=3443 -e HTTP_PORT=3000 -e HTTP_ALL_INTERFACES=yes -e MYDOMAIN=你的域名 -e ZTNCUI_PASSWD=你的密码 -e MYADDR=你的公网ip --privileged=true zerotier-aio:latest

```

- bridge模式

```sh
docker run -itd --name ztncui --hostname ztncui --net bridge -p3000:3000 -p3180:3180 -p3443:3443 -p9993:9993/udp --restart always --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun -v /home/zerotier/opt/key-networks/ztncui/etc:/opt/key-networks/ztncui/etc -v /home/zerotier/var/lib/zerotier-one:/var/lib/zerotier-one -v /home/zerotier/etc/zt-mkworld:/etc/zt-mkworld -e PUID=0 -e PGID=0 -e TZ=Asia/Shanghai -e AUTOGEN_PLANET=0 -e NODE_ENV=production -e HTTPS_HOST=127.0.0.1 -e HTTPS_PORT=3443 -e HTTP_PORT=3000 -e HTTP_ALL_INTERFACES=yes -e MYDOMAIN=你的域名 -e ZTNCUI_PASSWD=你的密码 -e MYADDR=你的公网ip --privileged=true zerotier-aio:latest
```

## Docker Compose使用指南

- amd64/arm64
- host模式

创建 docker-compose.yml 修改权限为777 然后输入 docker-compose up -d 运行zerotier 查看当前正常运行的容器：docker ps
```compose.yml
version: '2.0'
services:
  zerotier-aio:
    image: zerotier-aio:latest
    container_name: ztncui
    hostname: ztncui
    restart: always
    cap_add:
      - ALL
    devices:
      - /dev/net/tun
    network_mode: host
    volumes:
      - /home/zerotier/opt/key-networks/ztncui/etc:/opt/key-networks/ztncui/etc
      - /home/zerotier/var/lib/zerotier-one:/var/lib/zerotier-one
      - /home/zerotier/etc/zt-mkworld:/etc/zt-mkworld
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
      - AUTOGEN_PLANET=0
      - NODE_ENV=production
      - HTTPS_HOST=xxx.xxx.xxx.xxx  输入你的宿主机ip地址
      - HTTPS_PORT=3443
      - HTTP_PORT=3000
      - HTTP_ALL_INTERFACES=yes
      - MYDOMAIN=ztncui.docker.test 注：输入你用于WebUI网址域名，动态生成 TLS 证书（如果不存在）
      - ZTNCUI_PASSWD=WebUI密码 注：网页控制器密码，用户名默认为admin
      - MYADDR=你的公网ip地址  注：安装zerotier宿主机 ip地址
    privileged: true
```

- bridge模式

创建 docker-compose.yml 修改权限为777 然后输入 docker-compose up -d 运行zerotier 查看当前正常运行的容器：docker ps
```compose.yml
version: '2.0'
services:
  zerotier-aio:
    image: zerotier-aio:latest
    container_name: ztncui
    hostname: ztncui
    restart: always
    cap_add:
      - ALL
    devices:
      - /dev/net/tun
    network_mode: bridge
    ports:
      - 3000:3000
      - 3180:3180
      - 3443:3443
      - 9993:9993/udp
    volumes:
      - /home/zerotier/opt/key-networks/ztncui/etc:/opt/key-networks/ztncui/etc
      - /home/zerotier/var/lib/zerotier-one:/var/lib/zerotier-one
      - /home/zerotier/etc/zt-mkworld:/etc/zt-mkworld
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
      - AUTOGEN_PLANET=0
      - NODE_ENV=production
      - HTTPS_HOST=xxx.xxx.xxx.xxx
      - HTTPS_PORT=3443
      - HTTP_PORT=3000
      - HTTP_ALL_INTERFACES=yes
      - MYDOMAIN=ztncui.docker.test 注：输入你用于WebUI网址域名，动态生成 TLS 证书（如果不存在）
      - ZTNCUI_PASSWD=你的密码  注：网页控制器密码，用户名默认为admin
      - MYADDR=你的公网ip地址  注：安装zerotier宿主机 ip地址
    privileged: true
```
### Golang auto-mkworld（已嵌入 docker 镜像中）

此功能允许您在不使用 C 代码和编译器的情况下生成行星文件。
## 变量

- `AUTOGEN_PLANET=0`如果设置为 1，将使用此节点身份生成planet文件并放入httpfs文件夹以在外部提供服务。如果设置为 2，将使用`/etc/zt-mkworld/mkworld.config.json`. 如果设置为 0，则不执行任何操作(默认为0)。
- `mkworld,config.json`参考如下

```json
{
    "rootNodes": [   // 节点数组，可以是多个
        {
            "comments": "amsterdam official",   // 节点对象,在 AUTOGEN_PLANET=1 时将自动生成
            "identity": "992fcf1db7:0:206ed59350b31916f749a1f85dffb3a8787dcbf83b8c6e9448d4e3ea0e3369301be716c3609344a9d1533850fb4460c50af43322bcfc8e13d3301a1f1003ceb6",  
            // 节点 identity.public ^^ , 如果节点未初始化，则会在容器启动时初始化
            "endpoints": [
                "195.181.173.159/443",   // 节点服务位置，格式为：IP/端口，如果 AUTOGEN_PLANET=1 将自动生成
                "2a02:6ea0:c024::/443"   // 必须小于或等于两个端点，一个用于 IPv4，一个用于 IPv6。如果有多个 IP，则设置具有不同标识的多个节点。
        }
    ],
    "signing": [
        "previous.c25519",   // 行星签名密钥，如果不存在，将生成
        "current.c25519"   // 相同，用于迭代和更新
    ],
    "output": "planet.custom",   // 输出文件名
    "plID": 0,    // 行星数字 ID，如果不知道，请勿修改，并将 plRecommend 设置为 true
    "plBirth": 0,  // 行星创建时间戳，如果不知道，请勿修改，并将 plRecommend 设为 true
    "plRecommend": true  // 将 plRecommend 设为 true，自动推荐 plID、plBirth 值。更多详情，请阅读 zerotier-one 官方软件仓库中的 mkworld 源代码
}
```

- `NODE_ENV=production` (此变量为必须需要)节点环境，默认为`production`
- `HTTPS_HOST=xxx.xxx.xxx.xxx` HTTPS_主机,仅监听 HTTPS_HOST:HTTPS_PORT
- `HTTPS_PORT=3443` HTTPS_端口，默认`3443`
- `HTTP_PORT=3000` HTTP_端口，默认为`3000`
- `HTTP_ALL_INTERFACES` 监听所有接口，对于反向代理有用，仅 HTTP
- `MYDOMAIN=ztncui.docker.test` 域名，动态生成 TLS 证书（如果不存在）
- `ZTNCUI_PASSWD=YourPassWD` WebUI密码,默认用户名为admin
- `MYADDR` 公网IP地址，如果未设置将自动检测

- 更多用法详见[kmahyyg/ztncui-aio](https://github.com/kmahyyg/ztncui-aio)
- 要重置ztncui的密码：删除下面的文件/mydata/ztncui/passwd并将环境变量设置为您想要的密码，然后重新创建容器。应用程序初始化后，只能从网页更改密码。

---

## 自动创建 planet 文件，真正意义上自建 zerotier planet服务器 使用官方方式生成行星文件

在宿主机即安装zerotier planet服务器上创建 auto-planet.sh 文件并运行它，内容如下
```sh
#!/bin/bash 
# debain ubuntu自动并设置的为planet服务器
# addr服务器公网ip+port
ip=`wget http://ipecho.net/plain -O - -q ; echo`
addr=$ip/9993
apt autoremove
apt update -y
apt install curl -y
identity=`cat /home/zerotier-aio/var/lib/zerotier-one/identity.public`
echo "identity :$identity=============================================="
apt-get -y install build-essential
apt-get install git -y
wget https://gitee.com/MINGERTAI/docker-zerotier-aio-zh/raw/master/planet.tar.gz && tar zxvf planet.tar.gz && chmod +x /root/planet && rm -rf planet.tar.gz && cd /root/planet/attic/world
sed -i '88s/3a46f1bf30:0:76e66fab33e28549a62ee2064d1843273c2c300ba45c3f20bef02dbad225723bb59a9bb4b13535730961aeecf5a163ace477cceb0727025b99ac14a5166a09a3/'$identity'/' ./mkworld.cpp
sed -i '89s#185.180.13.82/9993#'$addr'#g' ./mkworld.cpp
sed -i '90s/roots.back/\/\/roots.back/' ./mkworld.cpp
source ./build.sh
sleep 8s
./mkworld
mv ./world.bin ./planet
cp -r ./planet /home/zerotier-aio/etc/zt-mkworld
cp -r ./planet /home/zerotier-aio/opt/key-networks/ztncui/etc/httpfs
cp -r ./planet /home/zerotier-aio/var/lib/zerotier-one
```

---

###  如果多台zerotier planet服务器，那就必须用手动创建以备添加zerotier planet服务器宿主机ip地址,以下步骤为手动创建 planet 文件

```
wget https://gitee.com/MINGERTAI/docker-zerotier-aio-zh/raw/master/planet.tar.gz && tar zxvf planet.tar.gz && chmod +x /root/planet && rm -rf planet.tar.gz && cd /root/planet/attic/world
```
呼出identity.public里的字符串 注：如 docker 挂载到宿主机用下面命令，如没挂载到宿主机那只能进入 docker 容器 cat /var/lib/zerotier-one/identity.public
```
cat /home/zerotier/var/lib/zerotier-one/identity.public
```
呼出内容如下，复制root@ubuntuserver2204:~#前所有代码，去粘贴到 mkworld.cpp 修改 roots.back().identity = Identity("填写identity.public里的字符串");
```
0e7985bc80:0:d694f506c5c4810cd4ceb76e3000b5793219a4ec3f6259ebde3770d715152a6f642329195f58086a6d209d8ae413fb19fa120194b1095d018b4d722536aaefb6root@ubuntuserver2204:~#
```
打开 mkworld.cpp 修改
```
	// Los Angeles
	roots.push_back(World::Root());
	roots.back().identity = Identity("填写identity.public里的字符串");
	roots.back().stableEndpoints.push_back(InetAddress("185.180.13.82/9993"));      # 服务器ip地址/9993  默认通讯端口是9993，可以自行修改
```
生成build & planet
```js
source ./build.sh
./mkworld
mv ./world.bin ./planet
cp -r ./planet /home/zerotier/var/lib/zerotier-one/                       # 替换原planet使成为真正的独立于zerotier官方服务器的 Zerotier Planet服务器
cp -r ./planet /home/zerotier/opt/key-networks/ztncui/etc/httpfs/         # 供网页端下载
cp -r ./planet /home/zerotier/etc/zt-mkworld                              # 备份保存
```

---

# 创建 moon

### 在宿主机下创建名为patch.sh，打开并编辑，复制下面内容粘贴到创建名为patch.sh的文件内保存
```sh
#!/bin/sh
set -x
zerotier-idtool initmoon /var/lib/zerotier-one/identity.public > moon.json
chmod 777 moon.json
moonip="[\"${MYADDR}/9993\"]"
sed -i "s#127.0.0.1#${MYADDR}#g" moon.json
sed -i "s#\[\]#${moonip}#g" moon.json
cat moon.json
zerotier-idtool genmoon moon.json

mkdir /var/lib/zerotier-one/moons.d
cp *.moon /var/lib/zerotier-one/moons.d

cp *.moon /etc/zt-mkworld
cp *.moon /opt/key-networks/ztncui/etc/httpfs/
moon_id=$(cat /var/lib/zerotier-one/identity.public | cut -d ':' -f1)
zerotier-cli orbit $moon_id $moon_id
echo -e "++++++++++++你的 ZeroTier moon id 是+++++++++++++\\n\\n                $moon_id\\n\\nWindows客户端加入moon服务器，在终端输入:\\n\\ncd C:\ProgramData\ZeroTier\One\\n\\n接着输入:\\n\\nzerotier-cli orbit $moon_id $moon_id\\n\\n\\n+++++++++++++检查是否加入moon服务器++++++++++++++\\n\\n在终端输入 如下命令:\\n\\nzerotier-cli listpeers\\n\\n\\n++++++++如果想把服务器控制器也加入节点中+++++++++\\n\\n在容器里加入Network ID就可以了，输入如下进入容器:\\n\\ndocker exec -it ztncui bash\\n\\nzerotier-cli join Network ID" > /opt/key-networks/ztncui/etc/httpfs/moon使用说明.txt
```

###  以下步骤为创建 moon
```
docker cp patch.sh ztncui:/tmp
docker exec -it ztncui bash /tmp/patch.sh
docker restart ztncui
```

## 支持平台

- amd64
- arm64
- armv7(未测试，需自行构建镜像)

- ~~i386(node没有此版本，故不支持)~~

# 感谢

- [zerotier/ZeroTierOne](https://github.niliovo.top/zerotier/ZeroTierOne)
- [kmahyyg/ztncui-aio](https://github.com/kmahyyg/ztncui-aio)
- [key-networks/ztncui](https://github.com/key-networks/ztncui)
- [GitHub](https://github.com/)
- [Docker Hub](https://hub.docker.com/)
