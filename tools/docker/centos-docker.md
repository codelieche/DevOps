## Centos中安装Docker

### 网卡设置

#### 网卡1：enp0s3【仅主机(Host-Only)网络】

- 网卡设置：`/etc/sysconfig/network-scripts/ifcfg-enp0s3`
```bash
TYPE=Ethernet      # 设备类型，如：Ethernet、Bridge
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none      # static(静态IP);dhcp(通过DHCP协议获取IP);bootip(通过bootp协议获取IP)
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3           # 网络设备名称
UUID=40ae7279-ef8a-4c93-a469-1234567 # 设备唯一标识
DEVICE=enp0s3         # 配置文件应用到的设备名
# ONBOOT=no
IPV6_PRIVACY=no

ONBOOT=yes             # yes[默认]:系统启动时激活此设备，no为启动不激活
IPADDR=192.168.6.118   # 网络地址
NETMASK=255.255.255.0  # 网络掩码
# GATEWAY=192.168.6.1  # 设置默认网关
DNS1=8.8.8.8
```
#### 网卡2：en0sp8【网络地址转换】
- 网卡设置：`/etc/sysconfig/network-scripts/ifcfg-enp0s8`
```bash
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s8
UUID=d08b9922-c206-4678-9ca6-0b1d4cd4d224
DEVICE=enp0s8
ONBOOT=yes
```
**注意：**把ONBOOT设置为`yes`。
- 重启网卡：`/etc/init.d/network restart`

---

### 安装Docker
- 安装常用工具：`yum install -y vim tree net-tools telnet tcpdump wget`

- 安装Docker脚本：`install-docker.sh`
```bash
#!/bin/bash

# 第1步：安装好vim wget
yum install wget -y

# 第2步：下载docker的repos.d
# 2-1: 进入repos.d目录
cd /etc/yum.repos.d
# 2-2：下载docker-ce.repo
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo


# 第3步：安装docker相关组件
yum install docker-ce -y

# 第4步：把普通用户加入到docker组
sudo groupadd docker
sudo gpasswd -a codelieche docker
sudo systemctl start docker

# 第5步：开机启动
systemctl enable docker
```

- 安装：`bash install-docker.sh` 直接以root用户执行
- 查看状态：`systemctl status docker`
- 查看Docker信息：`docker info`

