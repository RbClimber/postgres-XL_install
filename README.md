本脚本使用于3台服务器集群部署postgres-Xl使用。

使用此脚本之前，需安装pdsh工具；每台服务器配置好yum源，创建用户pgxl;
gtm服务所在服务器需与其他服务所在服务器配置SSH信任(pgxl用户)（配置
方法在文档尾部）。

此脚本的服务部署情况，gtm单独部署在一台服务器，gtmSlave、gtm_pxy1、coord1、
datanode1部署在同一台服务器，gtm_pxy2、coord2、datanode2部署在同一台服务器。

执行脚本示例：
[root@localhost ~]# bash pg_install.sh
请输入gtm服务器IP地址:10.10.10.10
请输入gtmSlave,gtm_pxy1,coord1,datanode1所在服务器IP地址：10.10.10.11
请输入gtm_pxy2,coord2,datanode2所在服务器IP地址：10.10.10.12
请输入可以链接数据库的网段:10.10.0.0
请输入可以链接数据库的网段的掩码位:16


注:
ssh信任设置

#创建密钥文件夹                                                                 
mkdir ~/.ssh
chmod 700 ~/.ssh

#免交互创建密钥对
#命令说明：
#ssh-keygen:生成密钥对命令
#-t：指定密钥对的密码加密类型（rsa，dsa两种）
#-f：指定密钥对文件的生成路径包含文件名
#-P（大写）：指定密钥对的密码
ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ""

#建立ssh信任
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
scp ~/.ssh/authorized_keys pgxl@pgnode*:~/.ssh/

脚本运行中，此提示无影响
spawn_id: spawn id exp7 not open
while executing
"interact"
