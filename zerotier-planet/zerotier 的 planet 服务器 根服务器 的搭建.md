（1）. 首先更新系统
```
apt update
```
（2）. 安装必要的编译组件
```
apt install wget gcc gcc-c++ git -y
```
（3）. 安装官方客户端
```
curl -s https://install.zerotier.com/ | sudo bash
```
（3-1）. 记录 identity.public 和 authtoken.secret 文件里的字符串，以后有用。注意每台设备不同，字符串也不同，别抄我的

identity.public 里的是：
```
2dcdb49f24:0:2e39cb1b36c96bea35a4ae506e15bad97019c48880e66fe9310453977dd9ce7981987bdb94e1e8eb4cd14d09d27aeeaf1c9658bb98b1bc7107a7e3d427d5bdc2
```
authtoken.secret 里的是：
```
w8cl25tzb38dvwffenucrbug
```
（4）. 下载并编译配置文件
```
git clone https://github.com/zerotier/ZeroTierOne.git
cd ./ZeroTierOne/attic/world/

修改 mkworld.cpp 内容
sed -i '/roots.push_back/d' ./mkworld.cpp                                                                      # 删除mkworld.cpp文件内的所有roots.push_back源代码
sed -i '/roots.back()/d' ./mkworld.cpp                                                                         # 删除mkworld.cpp文件内的所有roots.back()源代码
sed -i '85i roots.push_back(World::Root());' ./mkworld.cpp                                                     # 重新添加roots.push_back(World::Root())mkworld.cpp
sed -i '86i roots.back().identity = Identity(\"'"填写identity.public里的字符串"'\");' ./mkworld.cpp             # 重新添加
sed -i '87i roots.back().stableEndpoints.push_back(InetAddress(\"'"服务器ip地址/通讯端口"'\"));' ./mkworld.cpp   #默认通讯端口是9993，可以自行修改

注：如使用FinalShell ssh工具 用ssh工具直接编辑修改 1.删除 // Miami // Tokyo // Amsterdam 下的所有内容
2.修改 // Los Angeles 下内容
	// Los Angeles
	roots.push_back(World::Root());
	roots.back().identity = Identity("3a46f1bf30:0:76e66fab33e28549a62ee2064d1843273c2c300ba45c3f20bef02dbad225723bb59a9bb4b13535730961aeecf5a163ace477cceb0727025b99ac14a5166a09a3");
	roots.back().stableEndpoints.push_back(InetAddress("185.180.13.82/9993"));      # 服务器ip地址/9993  默认通讯端口是9993，可以自行修改

生成build & planet
source ./build.sh
./mkworld
mv ./world.bin ./planet
\cp -r ./planet /var/lib/zerotier-one/
\cp -r ./planet /root﻿​
```
（4-1）. 重启官方客户端
```
systemctl restart zerotier-one.service
```
（5）. 安装 moon 服务器

（5-1）生成moon配置文件
```
cd /var/lib/zerotier-one
zerotier-idtool initmoon identity.public > moon.json
chmod 777 moon.json
```
（5-2）打开moon.json 修改stableEndpoints, 注意格式和实际公网ip"stableEndpoints": ["公网ip 4/9993"]
```
{
 "id": "b72b5e9e1a",
 "objtype": "world",
 "roots": [
  {
   "identity": "b72b5e9e1a:0:a892e51d2ef94ef941e4c499af01fbc2903f7ad2fd53e9370f9ac6260c2f5d2484fd90756bec0c410675a81b7cf61d2bb885783bd6a8c28bce83bcab5f03fe14",
   "stableEndpoints": ["127.0.0.1/9993"]
  }
 ],
 "signingKey": "45f0613e569a0549c74293c39b30495b594a003534290e8ade9ef82877aa7505d7a73eeabfc22c97c404e4caaf9f3c9eed2b134d696935c966e28f523364f15f",
 "signingKey_SECRET": "cc6afd67e7b7f84a92e2c8d3c2e7212c71e2ad0a4f5b3c03bf60ab1cd3b99281b57d9a2958d2bd8fc2bc77fdf2a1160099c2c61d3d9acc8cb311673ee120b4a6",
 "updatesMustBeSignedBy": "45f0613e569a0549c74293c39b30495b594a003534290e8ade9ef82877aa7505d7a73eeabfc22c97c404e4caaf9f3c9eed2b134d696935c966e28f523364f15f",
 "worldType": "moon"
}
```
（5-3）生成moon文件
```
zerotier-idtool genmoon moon.json
mkdir moons.d
cp *.moon moons.d/
```
（5-4）将moon id写入root/moon使用说明.txt
```
moon_id=$(cat /var/lib/zerotier-one/identity.public | cut -d ':' -f1)
```
```
echo -e "++++++++++++你的 ZeroTier moon id 是+++++++++++++\\n\\n                $moon_id\\n\\nWindows客户端加入moon服务器，在终端输入:\\n\\ncd C:\ProgramData\ZeroTier\One\\n\\n接着输入:\\n\\nzerotier-cli orbit $moon_id $moon_id\\n\\n\\n+++++++++++++检查是否加入moon服务器++++++++++++++\\n\\n在终端输入 如下命令:\\n\\nzerotier-cli listpeers\\n\\n\\n++++++++如果想把服务器控制器也加入节点中+++++++++\\n\\n在容器里加入Network ID就可以了，输入如下进入容器:\\n\\ndocker exec -it ztncui bash\\n\\nzerotier-cli join Network ID" > moon使用说明.txt
```

（6）. 安装 planet 服务器的管理系统 ztncui 

ubuntu 使用下面代码
```
wget https://gitee.com/MINGERTAI/ztncui/releases/download/ztncui_0.8.7/ztncui_0.8.7_amd64.deb
sudo dpkg -i ztncui_0.8.7_amd64.deb
```
centos 使用下面代码
```
wget https://gitee.com/opopop880/ztncui/attach_files/932633/download/ztncui-0.8.6-1.x86_64.rpm
rpm -ivh ztncui-0.8.6-1.x86_64.rpm
```
（6-1）. 生成接口文件
```
cd /opt/key-networks/ztncui/
 
echo "HTTPS_PORT = 3443" >>./.env  #3443是ztncui默认的web面板端口，可以自行修改
echo "ZT_TOKEN = authtoken.secret文件里的字符串" >>./.env  #这里的字符串是authtoken.secret文件里的字符串
echo "ZT_ADDR=127.0.0.1:9993" >>./.env  #这里是面板与本地客户端的通讯端口，保持默认9993就行，千万别修改，修改了本地ztncui和ZeroTier-One通讯就会错误
echo "NODE_ENV = production" >>./.env
echo "HTTP_ALL_INTERFACES=yes" >>./.env﻿​

注：如使用FinalShell ssh工具 用ssh工具直接编辑/opt/key-networks/ztncui/.env文件，如没有创建它

```
HTTPS_PORT = 4000                           #4000是ztncui默认的web面板端口，可以自行修改
ZT_TOKEN = 0pjfz0tjgquobssck0qzobzc         #这里的字符串是authtoken.secret文件里的字符串
ZT_ADDR=127.0.0.1:9993                      #这里是面板与本地客户端的通讯端口，保持默认9993就行，千万别修改，修改了本地ztncui和ZeroTier-One通讯就会错误
NODE_ENV = production
HTTP_ALL_INTERFACES=yes
```
（6-2）. 启动 ztncui 管理面板
```
systemctl restart ztncui
```
（7）. 现在可以使用：https://服务器 ip:4000 登录了，默认账号和密码是：admin/password

备注：如果使用http://服务器 ip:3000【注意这里的证书是不可信的，所以要点浏览器页面上的高级 -- 继续前往服务器 ip（不安全）】第一次登录需要改密码，改完密码后在页面上点注销，然后用新密码登录。

登录以后点：add a network 建立一个虚拟网路，network name: 名称随便写，最后按 create a network 按钮保存

（7）. 记住 there are no members on this network - users are invited to join 后面的网络 id，后续方便虚拟局域网的其他电脑加入

（8）. 下载 / root 目录下生成的 “planet” 文件，来替换需要组网客户端里的 “planet” 文件

（9）. 其他需要加入虚拟局域网的电脑正常安装客户端，各系统的客户端下载地址：https://www.zerotier.com/download/

（10）. 使用刚才下载的 “planet” 文件替换其他电脑 “ZeroTier-One” 安装目录下的 “planet” 文件，并重启系统

（11）. 在设备上执行 “zerotier-cli join 你的 planet 服务器网络 ID” 加入刚组建虚拟局域网
```
zerotier-cli join xxxxxxxxxx
```
如果一切正常的话，会显示：200 join OK 的提示

（12）在其他设备上执行 zerotier-cli listpeers 命令可以看到你架设成功的 planet 服务器，注意这里的 planet 服务器是不显示 ip 的。具体见下图
