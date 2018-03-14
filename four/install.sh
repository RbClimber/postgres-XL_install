#!/bin/bash

#创建用户pgxl及密码123456
#name=pgxl
#pass=123456
#echo "正在创建用户 : ${name}"
#useradd $name
#if [ $? -eq 0 ];then
#   echo "用户 ${name} 创建成功!!!"
#else
#   echo "用户 ${name} 创建失败!!!"
#fi

#echo "正在为用户 ${name} 创建密码 : $pass"
#echo $pass |passwd $name --stdin  &>/dev/null
#if [ $? -eq 0 ];then
#   echo "用户 ${name} 设置密码成功!!!"
#else
#   echo "用户 ${name} 设置密码失败!!!"
#fi

#rpm方式部署postgres-XL
cd ./four
yum -y localinstall *.rpm
chown -R pgxl:pgxl /usr/postgres-xl-9.2

pgxl_bash=/home/pgxl/.bashrc

#配置环境变量
sed -i '/PGHOME/d' $pgxl_bash
echo 'export PGHOME=/usr/postgres-xl-9.2' >> $pgxl_bash
echo 'export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH' >> $pgxl_bash
echo 'export PATH=$PGHOME/bin:$PATH' >> $pgxl_bash
