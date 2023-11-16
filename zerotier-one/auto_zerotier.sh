#!/bin/bash 
# debain ubuntu自动安装 zerotier 并设置的为planet服务器
# addr服务器公网ip+port
 ip=`wget http://ipecho.net/plain -O - -q ; echo`
 addr=$ip/9993
 apt autoremove
 apt update -y
 apt install curl -y
 echo "********************************************************************************************************************"
 echo "***************deabin unbuntu自动安装zerotier 并设置的为planet服务器 放在root目录执行**********************************"
 curl -s https://install.zerotier.com/ | sudo bash
 
 identity=`cat /var/lib/zerotier-one/identity.public`
 echo "identity :$identity=============================================="
 apt-get -y install build-essential
 apt-get install git -y
 git clone https://gitee.com/MINGERTAI/ZeroTierOne.git
 cd ./ZeroTierOne/attic/world/
sed -i '/roots.push_back/d' ./mkworld.cpp
sed -i '/roots.back()/d' ./mkworld.cpp 
sed -i '85i roots.push_back(World::Root());' ./mkworld.cpp 
sed -i '86i roots.back().identity = Identity(\"'"$identity"'\");' ./mkworld.cpp 
sed -i '87i roots.back().stableEndpoints.push_back(InetAddress(\"'"$addr"'\"));' ./mkworld.cpp 
source ./build.sh
./mkworld
mv ./world.bin ./planet
\cp -r ./planet /var/lib/zerotier-one/
\cp -r ./planet /root
systemctl restart zerotier-one.service
wget https://raw.githubusercontent.com/MINGERTAI/QTV/main/zerotier-one/ztncui_0.8.7_amd64.deb
sudo dpkg -i ztncui_0.8.7_amd64.deb*
cd /opt/key-networks/ztncui/
sudo sh -c "echo HTTPS_PORT=3443 >> /opt/key-networks/ztncui/.env"
sudo sh -c "echo NODE_ENV=production >> /opt/key-networks/ztncui/.env"
secret=`cat /var/lib/zerotier-one/authtoken.secret`
sudo sh -c "echo ZT_TOKEN = $secret >> /opt/key-networks/ztncui/.env"
sudo sh -c "echo ZT_ADDR=127.0.0.1:9993 >> /opt/key-networks/ztncui/.env"
sudo sh -c "echo HTTP_ALL_INTERFACES=yes >> /opt/key-networks/ztncui/.env"
sudo chmod 400 /opt/key-networks/ztncui/.env
sudo chown ztncui.ztncui /opt/key-networks/ztncui/.env
systemctl restart ztncui
rm -rf /root/ZeroTierOne
echo "**********安装成功*********************************************************************************"
