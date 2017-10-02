## iptables基本使用

> iptables命令是Linux上常用的防火墙软件，是netfilter项目的一部分。可以直接配置，也可以通过许多前端和图形界面配置。  
Netfilter是Linux操作系统核心层内部的一个数据包处理模块。  
Hook Point：数据包在Netfilter中的挂载点。  
iptables规则组成：四张表 + 五条链(Hook point) + 规则。

### 四张表
- `filter表`: 一般的过滤功能
- `nat表`: 用户nat功能（端口映射，地址映射等）
- `mangle表`: 用于对特定数据包的修改
- `raw表`: 有限级高，设置raw时一般是为了不再让iptables做数据包的链接跟踪处理，提高性能。

其中常用的是：filter和nat表。

### 五条链
- `PREROUTING`: 数据包进入路由表前
- `INPUT`: 通过路由表后目的地为本机
- `FORWARDING`: 通过路由表后，目的地不为本机
- `OUTPUT`: 由本机产生，向外转发
- `POSTROUTING`: 发送到网卡接口之前。

### 规则
规则组成部分：

- 数据包访问控制：`ACCEPT`、`DROP`、`REJECT`
- 数据包改写：`SNAT`、`DNAT`
- 信息记录：`LOG`

> iptables规则组成:  
组成部分：四张表 + 五条链(Hook point) + 规则

iptables: `table` `command` `chain` `Parameter & Xmatch` `target`

#### table
指定要操作的表： `-t filter / nat`

#### command
- `-A`: 追加规则到规则链中(尾部添加)
- `-D`: 从规则链中删除规则
- `-I`: 想规则链中添加规则(首部添加)
- `-R`：替换规则链中的条目
- `-L`: 显示规则链中已有的条目
- `-F`: 清楚规则链中已有的条目
- `-Z`: 清空规则链中的数据包计算器和字节计算器
- `-N`: 创建新的用户自定义规则链

#### chain
- `PREROUTING`:
- `INPUT`:
- `FORWARD`:
- `OUTPUT`:
- `POSTROUTING`

#### Parameter & Xmatch
- `-p`: 指定要匹配的数据包协议类型，eg: tcp
- `-s`: 指定要匹配的数据包源ip地址
- `-d`: 指定目的地址
- `--sport`: 来源端口
- `--dport`: 指定目的端口
- `--dports`: 目的地端口多个, eg: 5000:8000
- `-m`: 拓展模块，`-m tcp`, `-m state`, `-m multiport`

#### target
- `-j`: 目标：指定要跳转的目的
	1. `ACCEPT`: 将封包放行
	2. `DROP`: 丢弃封包不予处理
	3. `REJECT`: 拦阻该封包
	4. `DNAT`: 改写封包目的地
	5. `SNAT`:  改写封包源ip为某特定ip或范围
	6. `LOG`: 将封包相关讯息记录在/var/log中

### 配置规则的基本思路
- ACCPET规则放在前面，DENY规则放在后面
- ACCEPT
	1. 允许本地访问
	2. 允许已监听状态数据包通过
	3. 允许规则中允许的数据包通过
	4. 注意开发ssh远程管理端口

- DENY
	1. 拒绝未被允许的数据包

### 示例

> 对所有的地址开发本机的80端口。

```
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
```

> 允许某个ip通过ssh连接

```
iptables -I INPUT -s 192.168.1.123 -p tcp -m tcp --dport 22 -j ACCEPT
```

> 不允许其他电脑ssh连接本机，这条要追加到尾部。

```
iptables -A INPUT -p tcp --dport 22 -j REJECT
```