#!/bin/bash 
# debain ubuntu自动安装 zerotier 并设置的为planet服务器
# addr服务器公网ip+port
ip=`wget http://ipecho.net/plain -O - -q ; echo`
addr=$ip/9993
apt autoremove
apt update -y
apt install curl -y
echo "********************************************************************************************************************"
echo "*                                                                                                                  *"
echo "*                deabin unbuntu自动安装zerotier并设置的为planet服务器 放在root目录执行                                *"
echo "*                                                                                                                  *"
echo "********************************************************************************************************************"
curl -s https://install.zerotier.com/ | sudo bash
 
identity=`cat /var/lib/zerotier-one/identity.public`
echo "identity :$identity=============================================="
apt-get -y install build-essential
apt-get install git -y
wget https://gitee.com/MINGERTAI/docker-zerotier-aio-zh/raw/master/planet.tar.gz && tar zxvf planet.tar.gz && chmod +x /root/planet && rm -rf planet.tar.gz && cd /root/planet/attic/world
#sed -i "/roots.push_back/d" ./mkworld.cpp
#sed -i "/roots.back()/d" ./mkworld.cpp 
#sed -i "85i roots.push_back(World::Root());" ./mkworld.cpp 
#sed -i "86i roots.back().identity = Identity(\"'"$identity"'\");" ./mkworld.cpp 
#sed -i "87i roots.back().stableEndpoints.push_back(InetAddress(\"'"$addr"'\"));" ./mkworld.cpp
sed -i '88s/3a46f1bf30:0:76e66fab33e28549a62ee2064d1843273c2c300ba45c3f20bef02dbad225723bb59a9bb4b13535730961aeecf5a163ace477cceb0727025b99ac14a5166a09a3/'$identity'/' ./mkworld.cpp
sed -i '89s/185.180.13.82/'$addr'/' ./mkworld.cpp
sed -i '90s/roots.back/\/\/roots.back/' ./mkworld.cpp
source ./build.sh
sleep 8s
./mkworld
mv ./world.bin ./planet
cp -rf ./planet /var/lib/zerotier-one/
cp -rf ./planet /root
systemctl restart zerotier-one.service
cd && wget https://github.com/MINGERTAI/QTV/raw/main/zerotier-one/ztncui_0.8.7_amd64.deb
sudo dpkg -i ztncui_0.8.7_amd64.deb
cd && cd /opt/key-networks/ztncui/
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
rm -rf /root/.config
rm -rf /root/.bash_history
rm -rf /root/.wget-hsts
rm -rf /root/auto_zerotier.sh
rm -rf /root/ztncui_0.8.7_amd64.deb
echo "**********安装成功*********************************************************************************"
