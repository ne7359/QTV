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

cp *.moon planet  /opt/key-networks/ztncui/etc/myfs
moon_id=$(cat /var/lib/zerotier-one/identity.public | cut -d ':' -f1)
echo -e "Your ZeroTier moon id is \033[0;31m$moon_id\033[0m, you could orbit moon using \033[0;31m\"zerotier-cli orbit $moon_id $moon_id\"\033[0m"
echo -e "++++++++++++你的 ZeroTier moon id 是+++++++++++++\\n\\n                $moon_id\\n\\nWindows客户端加入moon服务器，在终端输入:\\n\\ncd C:\ProgramData\ZeroTier\One\\n\\n接着输入:\\n\\nzerotier-cli orbit $moon_id $moon_id\\n\\n\\n+++++++++++++检查是否加入moon服务器++++++++++++++\\n\\n在终端输入 如下命令:\\n\\nzerotier-cli listpeers\\n\\n\\n++++++++如果想把服务器控制器也加入节点中+++++++++\\n\\n在容器里加入Network ID就可以了，输入如下进入容器:\\n\\ndocker exec -it ztncui bash\\n\\nzerotier-cli join Network ID" > /opt/key-networks/ztncui/etc/myfs/moon使用说明.txt
