## lsof命令基本使用

> lsof是`List open files`的简称。列出系统打开的文件。
>
> lsof可以指定用户或进程操作了哪些文件，也可查看系统中网络的使用情况，以及设备信息。



### 输出的内容说明

```bash
[root@node01 ~]# lsof | head
COMMAND     PID   TID       USER   FD      TYPE             DEVICE   SIZE/OFF       NODE NAME
systemd       1             root  cwd       DIR              253,0        236         64 /
systemd       1             root  rtd       DIR              253,0        236         64 /
systemd       1             root  txt       REG              253,0    1612152  100676919 /usr/lib/systemd/systemd
systemd       1             root  mem       REG              253,0      20112       2158 /usr/lib64/libuuid.so.1.3.0
```

每列输出的内容分别是：

- `COMMAND`: 命令名称
- `PID`: 进程ID
- `USER`: 用户名
- `FD`: File Descriptor 表示文件描述符或者文件的描述
  - `cwd`: 当前工作目录
  - `mem`: 内存映射文件
  - `mmap`: 内存映射设备
  - `txt`: 应用文本(代码和数据)
  - ......
- `TYPE`: 文件类型
  - `IPv4`: IPv4 Socket
  - `IPv6`: IPv6 socket
  - `inet`: Internet Domain Socket
  - `unix`: Unix Domain Socket
  - `BLK`: 设备文件
  - `CHR`: 字符文件
  - `DIR`: 文件夹
  - `FIFO`: FIFO文件
  - `LINK`: 符号链接文件
  - `REG`: 普通文件
  - ……..
- `DEVICE`: 文件所在的设备
- `SIZE/OFF`: 文件大小或者所在设备的偏移量
- `NODE`: node/inode的编号
- `NAME`: 文件名



### 示例

#### 1. 列出某个进程打开的文件

- 1-1： 准备python文件:`lsof_write_file.py`

  ```python
  import time
  import os
  
  with open("./lsof_write_demo.txt", "w") as f:
      i = 0
      while i < 100:
          i += 1
          now = time.strftime("%F %T")
          f.write(now + os.linesep)
          time.sleep(1)
  ```

- 1-2: 执行:`python lsof_write_file.py`

- 1-3: 执行ps查看进程ID：`ps aux | grep lsof_write_file`

- 1-4: 执行lsof -p xxx命令

  ```bash
  ➜  devops lsof -p 16638
  COMMAND     PID      USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
  python3.5 16638 codelieche  cwd    DIR    1,5      128 27887803 /Users/codelieche/tmp/study
  python3.5 16638 codelieche  txt    REG    1,5  2963156  2323218 /Users/codelieche/.pyenv/versions/3.5.5/bin/python3.5
  python3.5 16638 codelieche  txt    REG    1,5    20072  2332238 /Users/codelieche/.pyenv/versions/3.5.5/lib/python3.5/lib-dynload/_heapq.cpython-35m-darwin.so
  python3.5 16638 codelieche  txt    REG    1,5  1100896 16338195 /usr/lib/dyld
  python3.5 16638 codelieche    0u   CHR  16,18   0t2038    17983 /dev/ttys018
  python3.5 16638 codelieche    1u   CHR  16,18   0t2038    17983 /dev/ttys018
  python3.5 16638 codelieche    2u   CHR  16,18   0t2038    17983 /dev/ttys018
  python3.5 16638 codelieche    3w   REG    1,5        0 27890651 /Users/codelieche/tmp/study/lsof_write_demo.txt
  ```

#### 2. 列出某个用户打开的文件

 - `sudo lsof -u codelieche`
 - `sudo lsof -u ^codelieche`: 列出所有不是某个用户打开的文件

#### 3. 列出某个文件被哪些进程打开

- `lsof file_path`

- `lsof /dev/null`: 查看哪个程序使用了`/dev/null`

  ```bash
  ➜ lsof /Users/codelieche/tmp/study/lsof_write_demo.txt
  COMMAND     PID      USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
  python3.5 16638 codelieche    3w   REG    1,5        0 27890651 /Users/codelieche/tmp/study/lsof_write_demo.txt
  ```

#### 4. 根据目录查看

 - `sudo lsof +d /path/dir/` 列出访问某个目录的所有进程
 - `sudo lsof +D /path/dir` 列出访问了某个目录的所有进程【且递归查询】

##### 5. 列出某个目录使用的文件信息

```bash
➜ lsof -c vi
COMMAND     PID      USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
videosubs 14705 codelieche  cwd    DIR    1,5      992        2 /
。。。。。
```

​	-c 参数后面跟着命令的开通字符串，不一定是具体的程序名称。比如：`vi`是`videosubs`。

不过还是`-p 进程ID`会更直接点。



### lsof查看网络信息

> lsof另一个比较常用的功能是查看网络信息，其它网络工具有`tcpdump`, `netstat`等。

#### 1. 列出所有的网络连接信息

- `lsof -i`: 列出所有
- `lsof -i TCP`: 只显示TCP的连接
- `lsof -i UDP`: 只显示UDP连接

```bash
➜ lsof -i TCP | head
COMMAND     PID      USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
identitys   338 codelieche   29u  IPv6 0x3575d7ea0e2f0fc9      0t0  TCP alexzhoudemacbook-pro.local:1024->[fe80:14::f364:4848:32ca:b8f0]:1024 (CLOSED)
rapportd    346 codelieche    3u  IPv4 0x3575d7ea1c85dc89      0t0  TCP *:64921 (LISTEN)
rapportd    346 codelieche    4u  IPv6 0x3575d7ea10512449      0t0  TCP *:64921 (LISTEN)
assistant   412 codelieche   18u  IPv6 0x3575d7ea151e8249      0t0  TCP [fe80:8::aede:48ff:fe00:1122]:59280->[fe80:8::aede:48ff:fe33:4455]:49251 (ESTABLISHED)
corespeec   434 codelieche    4u  IPv6 0x3575d7ea10511e89      0t0  TCP [fe80:8::aede:48ff:fe00:1122]:64928->[fe80:8::aede:48ff:fe33:4455]:49241 (ESTABLISHED)
```

#### 2. 查看某个端口的网络连接情况

> 查看端口被哪些程序占用了的时候很方便。

```bash
➜  devops lsof -i :80
COMMAND     PID      USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
QQ         1769 codelieche   22u  IPv4 0x3575d7ea1c989289      0t0  TCP 192.168.1.101:64868->126.121.36.59.broad.dg.gd.dynamic.163data.com.cn:http (ESTABLISHED)
QQ         1769 codelieche   45u  IPv4 0x3575d7ea17fffc89      0t0  TCP 192.168.1.101:65209->183.57.48.75:http (ESTABLISHED)
QQ         1769 codelieche   60u  IPv4 0x3575d7ea1c978f89      0t0  TCP 192.168.1.101:49654->183.61.51.26:http (ESTABLISHED)
QQ         1769 codelieche   61u  IPv4 0x3575d7ea1c978f89      0t0  TCP 192.168.1.101:49654->183.61.51.26:http (ESTABLISHED)
com.apple  8276 codelieche    5u  IPv4 0x3575d7ea19545c89      0t0  TCP 192.168.1.101:65043->14.215.138.21:http (ESTABLISHED)
```

#### 3. 查看某个主机的网络情况

```bash
➜  devops lsof -i @10.90.1.123
COMMAND   PID      USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
com.docke 525 codelieche   22u  IPv4 0x3575d7ea1c6c5609      0t0  TCP 192.168.1.101:opsession-prxy->10.90.1.123:42408 (ESTABLISHED)
```

- 端口和主机可以放在一起使用，表示连接到主机指定端口的网络情况

```bash
➜  devops lsof -i @192.168.1.123:80
COMMAND     PID      USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
Google    95652 codelieche   62u  IPv4 0x3575d7ea12441289      0t0  TCP 192.168.1.101:50070->192.168.1.123:http (ESTABLISHED)
Google    95652 codelieche   64u  IPv4 0x3575d7ea1b529f89      0t0  TCP 192.168.1.101:50071->192.168.1.123:http (ESTABLISHED)
Google    95652 codelieche   72u  IPv4 0x3575d7ea0e582c89      0t0  TCP 192.168.1.101:50072->192.168.1.123:http (ESTABLISHED)
```

#### 4. 查看当前主机监听的端口

 - `netstat -an | grep LISTEN`
 - `sudo lsof -i -s TCP:LISTEN`

> `-s 协议:状态` -s参数跟着两个字段，`协议和状态`，中间用冒号隔开。  
>
> 另外比如：`TCP:TIME_WAIT`，`TCP:ESTABLISHED`



#### 5. 逻辑and, or

多个参数联合起来用`-a`, 默认是OR逻辑。

```bash
sudo lsof -a -p 1234 -i -s TCP:ESTABLISHED
```

> 进程ID是1234，而且TCP连接是ESTABLISHED的状态。



----

```bash
➜  study lsof -h
lsof 4.89
 latest revision: ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/
 latest FAQ: ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/FAQ
 latest man page: ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/lsof_man
 usage: [-?abhlnNoOPRtUvV] [+|-c c] [+|-d s] [+D D] [+|-f[cgG]]
 [-F [f]] [-g [s]] [-i [i]] [+|-L [l]] [+|-M] [-o [o]] [-p s]
 [+|-r [t]] [-s [p:s]] [-S [t]] [-T [t]] [-u s] [+|-w] [-x [fl]] [--] [names]
Defaults in parentheses; comma-separated set (s) items; dash-separated ranges.
  -?|-h list help          -a AND selections (OR)     -b avoid kernel blocks
  -c c  cmd c ^c /c/[bix]  +c w  COMMAND width (9)    +d s  dir s files
  -d s  select by FD set   +D D  dir D tree *SLOW?*   -i select IPv[46] files
  -l list UID numbers      -n no host names           -N select NFS files
  -o list file offset      -O no overhead *RISKY*     -P no port names
  -R list paRent PID       -s list file size          -t terse listing
  -T disable TCP/TPI info  -U select Unix socket      -v list version info
  -V verbose search        +|-w  Warnings (+)         -- end option scan
  +f|-f  +filesystem or -file names     +|-f[cgG] Ct flaGs
  -F [f] select fields; -F? for help
  +|-L [l] list (+) suppress (-) link counts < l (0 = all; default = 0)
  +|-M   portMap registration (-)       -o o   o 0t offset digits (8)
  -p s   exclude(^)|select PIDs         -S [t] t second stat timeout (15)
  -T fqs TCP/TPI Fl,Q,St (s) info
  -g [s] exclude(^)|select and print process group IDs
  -i i   select by IPv[46] address: [46][proto][@host|addr][:svc_list|port_list]
  +|-r [t[m<fmt>]] repeat every t seconds (15);  + until no files, - forever.
       An optional suffix to t is m<fmt>; m must separate t from <fmt> and
      <fmt> is an strftime(3) format for the marker line.
  -s p:s  exclude(^)|select protocol (p = TCP|UDP) states by name(s).
  -u s   exclude(^)|select login|UID set s
  -x [fl] cross over +d|+D File systems or symbolic Links
  names  select named files or files on named file systems
Anyone can list all files; /dev warnings disabled; kernel ID check disabled.
```



