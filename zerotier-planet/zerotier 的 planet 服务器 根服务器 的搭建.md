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
