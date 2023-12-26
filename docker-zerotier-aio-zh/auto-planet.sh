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
docker restart ztncui
