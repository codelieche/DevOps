## 网络工具

### ping

- 基本命令：`ping [选项] ip或者域名`
- 选项：
  - `-c`: 次数：指定ping包的次数

```
[centos@master ~]$ ping codelieche.com -c 2
PING codelieche.com (192.168.1.123) 56(84) bytes of data.
64 bytes from 192.168.1.123 (192.168.1.123): icmp_seq=1 ttl=63 time=32.7 ms
64 bytes from 192.168.1.123 (192.168.1.123): icmp_seq=2 ttl=63 time=32.4 ms

--- codelieche.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 32.465/32.618/32.771/0.153 ms
```



### telnet 

- 基本命令：`[IP或者域名]  [端口:默认23]`

> 远程管理与端口探测命令

```
➜  DevOps git:(master) ✗ telnet codelieche.com 80
Trying 192.168.1.123...
Connected to codelieche.com.
Escape character is '^]'.
^CConnection closed by foreign host.
```



### traceroute

> 路由跟踪命令

- 基本命令：`traceroute [选项] IP或者域名`

- 选项：

  - `-n`: 使用IP，不使用域名，速度会更快些

  ```bash
  ➜  DevOps git:(master) ✗ traceroute -n codelieche.com
  traceroute to codelieche.com (xxx.xxx.xxx.xxx), 64 hops max, 52 byte packets
   1  192.168.6.254  3.760 ms  13.458 ms  3.720 ms
   2  192.168.255.254  3.281 ms  3.972 ms  3.871 ms
   3  xx.xx.xx.xx  2.313 ms  1.975 ms
  ```



### tcpdump

> 抓包工具

- 基本使用：`tcpdump [选项]` 
- 示例：`tcpdump -i eth0  -nnX port 80`
- 选项：
  - `-i`: 指定哪个网卡
  - `port`: 指定监听的端口号
  - `-nn`: 将数据包中的域名与服务转为IP和端口
  - `-X`: 以16进制和ASCII码显示数据包内容

```bash
➜  DevOps git:(master) ✗ tcpdump -i lo0 port 8080
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo0, link-type NULL (BSD loopback), capture size 262144 bytes
19:42:57.670010 IP6 localhost.55918 > localhost.http-alt: Flags [P.], seq 1940613249:1940613772, ack 4222746902, win 6369, options [nop,nop,TS val 275151141 ecr 275141222], length 523: HTTP: GET / HTTP/1.1
```



### netstat

> 查询网络状态

- 选项
  - `-t`: 列出TCP协议端口
  - `-d`: 列出UDP协议端口
  - `-n`: 不使用域名与服务器名，而使用IP地址和端口号
  - `-l`: 仅列出在监听状态的网络服务
  - `-a`: 列出所有的网络连接
  - `-r`: 列出路由列表，功能和route命令一致

### wget

> 下载文件

- 基本使用：`wget 要下载的文件url`



### scp

> 下载或者上传文件

- 选项：
  - `-r`: 遍历目录

- 下载文件到本地：`scp [-r] user@ip:文件路径 本地路径`
- 上传文件到服务器：`scp [-r] 本地路径 user@ip:上传的路径`



### nslookup

> 进行域名与IP地址解析

```bash
➜  DevOps git:(master) ✗ nslookup codelieche.com
Server:		192.168.9.126
Address:	192.168.9.126#53

Non-authoritative answer:
Name:	codelieche.com
Address: 192.168.1.123
```

### route

> 查看路由

- 基本使用：`route -n`
- 临时设置网关：`route add default gw 192.168.6.1`

