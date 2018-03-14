#!/bin/bash

#pdsh模块dshgroup的配置
mkdir -p ~/.dsh/group
> ~/.dsh/group/pg
> four/hosts
yes|cp four/pgxc_ctl.conf.bak four/pgxc_ctl.conf

#前期准备工作
read -p "请输入gtm服务器IP地址:" pgnode1
#将ip加入pdsh分组pg
echo $pgnode1 >> ~/.dsh/group/pg
#ip加入数组pg
pg_[1]=$pgnode1
#将ip地址加入hosts文件
echo "$pgnode1 pgnode1" >> four/hosts

read -p "请输入gtmSlave,coord1,datanode1所在服务器IP地址：" pgnode2 
#ip加入数组pg
pg_[2]=$pgnode2
#将ip加入pdsh分组pg
echo $pgnode2 >> ~/.dsh/group/pg
echo "$pgnode2 pgnode2" >> four/hosts

read -p "请输入coord2,datanode2所在服务器IP地址：" pgnode3 
#将ip加入pdsh分组pg
echo $pgnode3 >> ~/.dsh/group/pg
#ip加入数组pg
pg_[3]=$pgnode3
echo "$pgnode3 pgnode3" >> four/hosts

#修改postgres-XL配置文件
read -p "请输入可以链接数据库的网段:" segment
sed -i "s/segment/$segment/g" four/pgxc_ctl.conf
read -p "请输入可以链接数据库的网段的掩码位:" seport
sed -i "s/seport/$seport/g" four/pgxc_ctl.conf

#关闭防火墙，关闭SELINUX，调整时区
pdsh -R ssh -g pg "systemctl stop firewalld.service;
systemctl disable firewalld.service;
sed -i 's/enforcing/disabled/' /etc/selinux/config;
sed -i 's/permissive/disabled/' /etc/selinux/config;
yes|cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime"

#ssh信任设置

#创建密钥文件夹
#su pgxl -c 'mkdir ~/.ssh'
#su pgxl -c 'chmod 700 ~/.ssh'

#免交互创建密钥对
#命令说明：
#ssh-keygen:生成密钥对命令
#-t：指定密钥对的密码加密类型（rsa，dsa两种）
#-f：指定密钥对文件的生成路径包含文件名
#-P（大写）：指定密钥对的密码
#su pgxl -c 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ""'

#建立ssh信任
#su pgxl -c 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
#su pgxl -c 'chmod 600 ~/.ssh/authorized_keys'
#su pgxl -c 'scp -p ~/.ssh/authorized_keys pgxl@node2:~/.ssh/'

#拷贝文件
for i in 1 2 3 
do
	scp -r four/ ${pg_[i]}:.
done

#修改hosts文件
pdsh -R ssh -g pg 'cat four/hosts >> /etc/hosts && source /etc/hosts'

#安装expect工具
pdsh -w ssh:$pgnode1 "yum -y install expect"

#与域名建立ssh信任
pdsh -w ssh:$pgnode1 "cp four/expect.sh /home/pgxl/"
pdsh -w ssh:$pgnode1 "su - pgxl -c 'bash expect.sh'"

#执行脚本，部署服务
pdsh -R ssh -g pg 'bash four/install.sh &'
pdsh -w ssh:$pgnode1 "su pgxl -c 'source ~/.bashrc && pgxc_ctl prepare'"

rootconf=four/pgxc_ctl.conf
pgxlconf=/home/pgxl/pgxc_ctl/pgxc_ctl.conf
pdsh -w ssh:$pgnode1 "cat $rootconf > $pgxlconf"

#启动集群
pdsh -w ssh:$pgnode1 "su pgxl -c 'source ~/.bashrc && pgxc_ctl init all'"
#启动gtm_proxy
pdsh -w ssh:$pgnode2 "cp four/gtm_proxy.sh /home/pgxl/"
pdsh -w ssh:$pgnode3 "cp four/gtm_proxy.sh /home/pgxl/"
timeout 1 pdsh -w ssh:$pgnode2 "su - pgxl -c 'bash gtm_proxy.sh'"
timeout 1 pdsh -w ssh:$pgnode3 "su - pgxl -c 'bash gtm_proxy.sh'"

#插入节点信息
pdsh -w ssh:$pgnode2 "cp four/database.sh /home/pgxl/"
pdsh -w ssh:$pgnode2 "su - pgxl -c 'bash database.sh'"

#查看集群状态
pdsh -w ssh:$pgnode1 "su pgxl -c 'source ~/.bashrc  && pgxc_ctl start all'"
pdsh -w ssh:$pgnode1 "su pgxl -c 'source ~/.bashrc  && pgxc_ctl monitor all'"
