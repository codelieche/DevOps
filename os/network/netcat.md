## Netcat的基本使用

> **netcat**是网络工具中的瑞士军刀，它能通过TCP和UDP在网络中读写数据。

### 安装

- MacOS安装：`brew install netcat`

- CentOS安装：

  ```bash
  wget http://sourceforge.net/projects/netcat/files/netcat/0.7.1/netcat-0.7.1.tar.gz
  tar -zxvf netcat-0.7.1.tar.gz
  mv netcat-0.7.1 netcat
  mv ./netcat /usr/local/netcat
  cd /usr/local/netcat/
  ./configure
  make && make install
  ```

  1. 查看命令：

  ```bash
  [root@localhost netcat]# which nc
  /usr/local/bin/nc
  ```

  2. 查看帮助：

  ```bash
  [root@localhost netcat]# nc -h
  GNU netcat 0.7.1, a rewrite of the famous networking tool.
  Basic usages:
  connect to somewhere:  nc [options] hostname port [port] ...
  listen for inbound:    nc -l -p port [options] [hostname] [port] ...
  tunnel to somewhere:   nc -L hostname:port -p port [options]
  
  Mandatory arguments to long options are mandatory for short options too.
  Options:
    -c, --close                close connection on EOF from stdin
    -e, --exec=PROGRAM         program to exec after connect
    -g, --gateway=LIST         source-routing hop point[s], up to 8
    -G, --pointer=NUM          source-routing pointer: 4, 8, 12, ...
    -h, --help                 display this help and exit
    -i, --interval=SECS        delay interval for lines sent, ports scanned
    -l, --listen               listen mode, for inbound connects
    -L, --tunnel=ADDRESS:PORT  forward local port to remote address
    -n, --dont-resolve         numeric-only IP addresses, no DNS
    -o, --output=FILE          output hexdump traffic to FILE (implies -x)
    -p, --local-port=NUM       local port number
    -r, --randomize            randomize local and remote ports
    -s, --source=ADDRESS       local source address (ip or hostname)
    -t, --tcp                  TCP mode (default)
    -T, --telnet               answer using TELNET negotiation
    -u, --udp                  UDP mode
    -v, --verbose              verbose (use twice to be more verbose)
    -V, --version              output version information and exit
    -x, --hexdump              hexdump incoming and outgoing traffic
    -w, --wait=SECS            timeout for connects and final net reads
    -z, --zero                 zero-I/O mode (used for scanning)
  
  Remote port number can also be specified as range.  Example: '1-1024'
  ```

---

### 基本使用



#### 1. 端口扫描

> 扫描本机21-8089的所有端口，默认是TCP，-u参数调整为UDP。

```bash
[root@localhost netcat]# nc -z -v -n 127.0.0.1 21-8089
127.0.0.1 22 (ssh) open
127.0.0.1 25 (smtp) open
127.0.0.1 80 (http) open
127.0.0.1 2222 (EtherNet/IP-1) open
127.0.0.1 5000 (commplex-main) open
127.0.0.1 6379 open
127.0.0.1 8080 (webcache) open
127.0.0.1 8081 (tproxy) open
```

参数说明

- `-z`:  告诉netcat使用0 IO, 连接成功后立即关闭，不进行数据的交换
- `-v`: 输出详细信息，冗余的信息
- `-n`: 不要使用DNS反向查询IP地址的域名

发现了有端口开放，那么可以使用nc去连接：`nc 127.0.0.1 22`



#### 2. 启动个传输消息的服务

- 2-1: 启动服务端

参数：`-l, --listen`:  listen mode, for inbound connects

> 启动个监听在8989端口的服务器，所有的标准输出和输入会 输出到该端口。

```bash
# nc -l 8989
```

- 2-2: 启动个客户端

```bash
# nc 127.0.0.1 8989
```

