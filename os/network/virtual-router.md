## 实战：虚拟机路由器功能

> 我用一台虚拟机A能访问外网。
>
> 虚拟机B，不能访问外网，想把A机器作为B的路由器上外网。



### 机器信息

- 机器A：`192.168.6.106`  VirtualBox的虚拟机，操作系统CentOS
- 机器B：`192.168.6.107` VirtualBox的虚拟机，操作系统CentOS

**1-1. 查看机器A的网卡信息：**

机器A有两个网卡

- `enp0s3`: 是仅主机(Host-Only)网络模式的网卡 vboxnet0
- `enp0s8`: 是网络地址转换(NAT)模式的网卡

```
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8a:8a:b0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.6.106/24 brd 192.168.6.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::3515:f619:8389:a606/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:b7:86:40 brd ff:ff:ff:ff:ff:ff
    inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
       valid_lft 86394sec preferred_lft 86394sec
    inet6 fe80::ffcc:71b:799:61f9/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

**1-2. 查看机器A的路由信息**

```
[root@localhost ~]# ip route
default via 10.0.3.2 dev enp0s8 proto dhcp metric 101
10.0.3.0/24 dev enp0s8 proto kernel scope link src 10.0.3.15 metric 101
192.168.6.0/24 dev enp0s3 proto kernel scope link src 192.168.6.106 metric 100
```

**1-3. 网卡enp0s3的配置**

```
[root@localhost ~]# cat /etc/sysconfig/network-scripts/ifcfg-enp0s3
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
UUID=20ae1234-ef8a-4c34-a469-123a3fd08a7f
DEVICE=enp0s3
# ONBOOT=no
IPV6_PRIVACY=no

ONBOOT=yes
IPADDR=192.168.6.106
NETMASK=255.255.255.0
# GATEWAY=192.168.6.1
DNS1=192.168.1.123
```

### 

**2-1. 查看机器B的网卡信息 **

> 机器B有一个网卡：`enp0s3`: 是仅主机(Host-Only)网络模式的网卡 vboxnet0

```
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:94:6e:45 brd ff:ff:ff:ff:ff:ff
    inet 192.168.6.107/24 brd 192.168.6.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::b6a8:a63:93c:a4a6/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

**2-2. 查看机器B的路由信息**

```
[root@localhost ~]# ip route
default via 192.168.6.106 dev enp0s3 proto static metric 100
192.168.6.0/24 dev enp0s3 proto kernel scope link src 192.168.6.107 metric 100
```

**2-3. 网卡enp0s3的配置**

```
[root@localhost ~]# cat /etc/sysconfig/network-scripts/ifcfg-enp0s3
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
UUID=40ae7279-ef8a-4c93-a469-467a3fd08a7f
DEVICE=enp0s3
# ONBOOT=no
IPV6_PRIVACY=no

ONBOOT=yes
IPADDR=192.168.6.106
NETMASK=255.255.255.0
# GATEWAY=192.168.6.1
DNS1=192.168.1.123
```

### 把机器A开启路由转发功能

**1. 开启网卡的IP转发功能**

```
echo 1 > /proc/sys/net/ipv4/ip_forward
```

或者：编辑：`/etc/sysctl.conf`加入一行：`net.ipv4.ip_forward=1`，然后`sysctl -p`命令使配置生效。

**2. iptalbes添加规则**

> 可以先清空原有的规则：`iptables -F`

- 2-1: 出口NAT：源地址转换（SNAT）

  > 更改所有来自IP地址`192.168.6.0/24`的数据包源地址为`192.168.6.106` 然后从enp0s8出去

```
iptables -t nat -A POSTROUTING -s 192.168.6.107/24 -o enp0s8 -j SNAT --to 192.168.6.106
```

- 2-2：包回来的时候NAT：目标地址转换（DNAT）

  > 回来的包，目标地址是`192.168.6.0/24`的数据包，把目标地址转换为`192.168.6.106`

```bash
iptables -t nat -A PREROUTING -d 192.168.6.0/24 -i enp0s8 -j DNAT --to 192.168.6.106
```

​	查看/停止防火墙：`systemctl status/stop firewalld.service`

- 2-3: 自动保存于加载iptalbes配置

  ```bash
  # 也可以写入shell脚本中
  iptables -F
  iptables -t nat -A POSTROUTING -s 192.168.6.0/24 -o enp0s8 -j SNAT --to 192.168.6.106
  iptables -t nat -A PREROUTING -d 192.168.6.0/24 -i enp0s8 -j DNAT --to 192.168.6.106
  # 然后把脚本路径 加入/etc/rc.d/rc.loacl (注意需执行权限)
  ```

  使用`iptables-save`和`iptables-restore`

  ```
  # 保存规则
  iptables-save > /etc/sysconfig/iptables
  # 加载规则
  iptables-restore < /etc/sysconfig/iptables
  ```

  如果加入rc.load，记得执行：`chmod +x /etc/rc.d/rc.local`

  修改iptalbes的配置：

  修改文件`vi /etc/sysconfig/iptables-config`修改 `IPTABLES_SAVE_ON_STOP="yes"`

### iptalbes参数

- `-t table  ` : 指定要操作的表，默认是`filter`
- `-A -append`: 在所选择的链未添加一条或更多规则
- `-D -delete`: 从所选的链表中删除一条或多条规则
- `-L -list`: 显示所选链的所有规则
- `-F -flush`: 清空所选链
- `-s -source`: 指定源地址，可以是主机名，网络名和详细的IP地址
- `-d -destination`: 指定目标地址
- `-p -protocal`: 规则或包检查的协议。指定协议为TCP、UDP、icmp中的一个或者全部，也可以是数值，代表协议中的某一个
- `-j -jump target`: 目标跳转，指定规则的目标
- `-i -in-interface [name]`: 进入的网络接口名称
- `-o -out-interface [name]`: 输出接口名称

