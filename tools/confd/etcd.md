## etcd+confd基本使用

### etcd基本使用

#### 启动etcd

```bash
$ which etcd
/usr/local/bin/etcd
$ etcd
....
2017-07-06 16:32:40.015403 I | embed: listening for client requests on localhost:2379
2017-07-06 16:32:40.018115 I | etcdserver: name = default
2017-07-06 16:32:40.018144 I | etcdserver: data dir = default.etcd
2017-07-06 16:32:40.018152 I | etcdserver: member dir = default.etcd/member
2017-07-06 16:32:40.018184 I | etcdserver: advertise client URLs = http://localhost:2379
.....
```

#### etcd重要参数
- `-name`: 节点名称默认是UUID
- `-data-dir`: 保存日志和快照的目录，默认当前工作目录
- `-addr`: 公布的ip地址和端口号，默认为：`127.0.0.1:2379`
- `-bind-addr`: 用于客户端连接的就监听地址，默认是`-addr`配置
- `-peers`: 集群成员都好分隔的列表，例如：`127.0.0.1:2380, 127.0.0.0.1:2381`
- `-peer-addr`: 集群服务通讯的公布的IP地址：默认`127.0.0.1:2380`
- `-peer-bind-addr`: 集群服务器通讯的件套地址，默认为`-peer-addr`配置

> 上述配置也可以设置在默认配置文件中：`/etc/etcd/etcd.conf`.

#### etcdctl基本操作
先设置和查看key的值：
```
➜ etcdctl set /study/python "this is python value"
this is python value
➜ etcdctl get /study/python                    
this is python value
```

查看etcdctl支持的命令：

```bash
➜  ~ etcdctl --help
 
COMMANDS:
     backup          backup an etcd directory
     cluster-health  check the health of the etcd cluster
     mk              make a new key with a given value
     mkdir           make a new directory
     rm              remove a key or a directory
     rmdir           removes the key if it is an empty directory or a key-value pair
     get             retrieve the value of a key
     ls              retrieve a directory
     set             set the value of a key
     setdir          create a new directory or update an existing directory TTL
     update          update an existing key with a given value
     updatedir       update an existing directory
     watch           watch a key for changes
     exec-watch      watch a key for changes and exec an executable
     member          member add, remove and list subcommands
     user            user add, grant and revoke subcommands
     role            role add, grant and revoke subcommands
     auth            overall auth controls
     help, h         Shows a list of commands or help for one command
```

### etcdctl数据库相关操作数据
#### set
设置某个键的值：`etcdctl set /study/key1 "Hello world"`
支持的选项：
1. `--ttl '0'`: 设置该键值的超时时间(秒)，不配置(默认0)则永不超时
2. `--swap-with-value value`: 若该键现在的值为value，则进行设置操作
3. `--swap-with-index '0'`: 若该键现在的索引值是指定的索引，则进行设置操作
     
#### get
获取指定键的值，`etcdctl get /study/key1`
支持的选项：
1. `--sort`: 对结果进行排序
2. `--consistent`: 将请求发给住节点，保证获取内容的一致性
     
> 当键不存在的时候，则会报错
     
```bash
➜ etcdctl set /study/key1 "Hello World"
Hello World
➜ etcdctl get /study/key1              
Hello World
➜ etcdctl get /study/key2
Error:  100: Key not found (/study/key2) [9]
```

#### update
当键存在的时候，更新值(不存在的时候会报错)，`etcdctl update /study/key1 "new value"`
支持的选项：`--t1 '0'`: 设置超时时间

```
➜ etcdctl update /study/key1 "new value"
new value
➜ etcdctl update /study/key2 "new value2"
Error:  100: Key not found (/study/key2) [10]
➜  etcd etcdctl get /study/key1           
new value
```

#### rm
删除某个键值(键不存在的时候会报错)
支持的选项：
1. `--dir`: 如果键是个空目录或者键值对则删除
2. `--recursive `: 删除目录和所有子键
3. `--with-value`: 检查现有的值是否匹配
4. `--with-index '0'`: 检查现有的 index 是否匹配

#### mk
如果给定的键不存在，则创建一个新的键值。`etcdctl mk /study/key2 'value2'`
如果建存在，则会报错：`Error:  105: Key already exists (/study/key2) [11]`
支持选项：`--ttl '0'`

```
➜ etcdctl mk /study/key3 'value3' --ttl '5' 
value3
➜ etcdctl get /study/key3                  
value3
➜ etcdctl get /study/key3                  
Error:  100: Key not found (/study/key3) [15]
```

#### mkdir
如果给定的键目录不存在，则创建一个新的键目录：支持选项`--ttl '0'`

#### setdir
创建一个键目录，无论存在语法，支持`--ttl '0'`选项

#### updatedir
更新一个已经存在的目录，支持`--ttl '0'`选项

#### rmdir
删除一个空目录，或者键值对。若目录不为空则会报错。

#### ls
列出目录（默认是跟目录）下的键或者子目录，默认不显示子目录内容。
支持选项：
1. `--sort`: 将输出结果排序
2. `--recursive`: 如果目录下有子目录，则递归输出其中的内容
3. `-p`: 对于输出的是目录，在最后添加 `/` 进行区分

```
➜  ~ etcdctl ls
/study
➜  ~ etcdctl ls --recursive -p
/study/
/study/python
/study/key1
/study/key2
/study/codelieche
```

### etcdctl非数据库相关操作
#### backup
备份etcd数据，选项：
1. `--data-dir`: etcd的数据目录
2. `--backup-dir`: 备份到指定路径

> 把/data/etcd/default.etcd的数据备份到/data/etcd/backup/default.bak.

```bash
➜  etcdctl backup --data-dir=/data/etcd/default.etcd --backup-dir=/data/etcd/backup/default.bak

➜  backup tree
.
└── default.bak
    └── member
        ├── snap
        └── wal
            └── 0000000000000000-0000000000000000.wal
```

#### 使用备份数据启动etcd

备份数据目录：`/data/etcd/backup/default.bak`

```
etcd --data-dir=/data/etcd/backup/default.bak --force-new-cluster
```

#### watch
检测一个键值的变化，一旦键值发生更新，就会输出最新的值并退出。
在一个终端执行：`etcdctl watch /study/key1` 另外一个终端set值。
支持选项：
1. `--forever`: 一直检测，知道用用户按`CTRL+C`退出
2. `--after-index '0'`: 在指定index之前一直检测
3. `--recursive`: 返回所有的键值和子键值

#### exec-watch
检测一个键值的变化，一旦键值发生更新，就执行给定命令，支持选项：
1. `--after-index '0'`: 在指定index之前一直监测
2. `--recursive`: 返回所有的键值和子键值

#### member
通过list、add、remove命令列出、添加、删除etcd实例到etcd集群中。
查看member：
```
➜  ~ etcdctl member list
8e9e05c52164694d: name=default peerURLs=http://localhost:2380 clientURLs=http://localhost:2379 isLeader=true
```
选项：
1. `--debug`: 输出curl命令，显示执行命令的时候发起的请求
2. `--no-sync`: 发出请求之前不同步集群信息
3. `--output, -o 'simple'`: 输出内容的格式 (simple为原始信息，json 为进行json格式解码，易读性好一些)
4. `--peers, -C`: 指定集群中的同伴信息，用逗号隔开
5. `--cert-file HTTPS`: 下客户端使用的 SSL 证书文件
6. `--key-file HTTPS`: 下客户端使用的 SSL 密钥文件
7. `--ca-file`: 服务端使用 HTTPS 时，使用 CA 文件进行验证
8. `--help, -h`: 显示帮助命令信息
9. `--version, -v`: 打印版本信息

### etcd.server
> 为了方便运行etcd可以自己写个shell脚本。  
文件位置：`/usr/local/bin/etcd.server`

```shell
#!/bin/sh
# 运行etcd
# echo $1 # 第一个参数

# 如果没传$1 那么$1为default
if [ $1 ]
then
  echo "使用$1数据库"
else
  $1="default"
fi

if [ $1 == "default" ]
  then
    etcd --data-dir=/data/etcd/default.etcd
elif [ $1 == "study" ]
then
  etcd --data-dir=/data/etcd/study.etcd
elif [ $1 == "project" ]
then
  etcd --data-dir=/data/etcd/project.etcd
elif [ $1 == "devops" ]
then
  etcd --data-dir=/data/etcd/devops.etcd
else
  echo "参数暂时只支持：空、default、study、project、devops"
fi
```
注意对文件加执行权限：`sudo chmod +x /usr/local/bin/etcd.server`，同时注意`/data/etcd`目录的写权限.



