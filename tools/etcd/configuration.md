## etcd配置参数

### 参考文档

- [Configuration flags](https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/configuration.md)



> etcd可通过命令行标记和环境变量来配置，命令行上设置的选项优先于环境变量。
>
> `--my-flag`的标记，设置参数格式是：`ETCD_MY_FLAG`, 适用于所有。



关于端口号：

- `2379`用于客户端连接
- `2380`用户伙伴(节点)通信

在linux启动etcd，推荐使用systemd，编写：`/etc/systemd/system/etcd.service`



### Member flags

通过`etcd -h`可以查看到各参数。

#### --name

> --name 'default'
>
> ​		human-readable name for this member.

 - 成员的可读的名字【默认是default】

 - 环境变量：`ETCD_NAME`

   这个值作为这个节点自己的入口中被引用，在`--initial-cluster`标记。  

   每个成员必须是唯一的名字，eg：node1, node2, n0de3

#### --data-dir

> ​	--data-dir '${name}.etcd'
>
> ​		path to the data directory.

 - 数据目录的路径
 - 默认是:"${name}.tecd",  比如：default.etcd
 - 环境变量：`ETCD_DATA_DIR`

#### --val-dir

> --wal-dir ''
>
> ​		path to the dedicated wal directory.

- 到专用的wal目录的路径
- 默认是：”“
- 环境变量：`ETCD_WAL_DIR`

#### --snapshot-count

> ​	--snapshot-count '100000'
>
> ​		number of committed transactions to trigger a snapshot to disk.

- 触发快照到磁盘的已提交事务的数量
- 默认是：100000
- 环境变量：`ETCD_SNAPSHOT_COUNT`

#### --heartbeat-interval

> --heartbeat-interval '100'
>
> ​		time (in milliseconds) of a heartbeat interval.

- 心跳间隔时间(单位 毫秒)
- 默认：100
- 环境变量：`ETCD_HEARTBEAT_INTERVAL`

#### --election-timeout

> --election-timeout '1000'
>
> ​		time (in milliseconds) for an election to timeout. See tuning documentation

- 选举的超时时间(单位:毫秒)
- 默认：1000
- 环境变量: `ETCD_ELECTION_TIMEOUT`

#### --listen-client-urls

> ​	--listen-client-urls 'http://localhost:2379'
>
> ​		list of URLs to listen on for client traffic.

用于监听客户端通讯的URL列表。这个标记告诉etcd在特定的scheme://IP:port组合上从客户端接收进来的请求。  

scheme可以是http或者https。  

etcd将从任何列出来的地址和端口上应答请求。

- 默认：`http://localhost:2380`
- 环境变量：`ETCD_LISTEN_CLIENT_URLS`

#### --max-snapshots

> ​	--max-snapshots '5'
>
> ​		maximum number of snapshot files to retain (0 is unlimited).

- 保持快照文件的最大数量(0表示不限制)
- 默认：5
- 环境变量：`ETCD_MAX_SNAPSHOTS`

#### --max-wals

> --max-wals '5'
>
> ​		maximum number of wal files to retain (0 is unlimited).

- 保持wal文件的最大数量(0表示不限制)
- 默认：5
- 环境变量：`ETCD_MAX_WALS`

#### --cors

> --cors ''
>
> ​		comma-separated whitelist of origins for CORS (cross-origin resource sharing).

- 逗号分隔的origin白名单，用于CORS
- 默认：none
- 环境变量：`ETCD_CORS`



### Clustering flags(集群标记)

- `--initial`前缀的标记用于启动新成员，然后当重新启动一个已有的成员时被忽略
- `--discovery`前缀标记在使用发现服务时需要的设置

#### --initial-advertise-peer-urls

> --initial-advertise-peer-urls 'http://localhost:2380'
>
> ​		list of this member's peer URLs to advertise to the rest of the cluster.

列出这个成员的URL以便通告给集群的其它成员。这些URL可以包含域名。

- 默认：`http://localhost:2380`
- 环境变量：`ETCD_INITIAL_ADVERTISE_PEER_URLS`
- 示例：`http://etcd.codelieche.com:2380, http://192.168.1.123:2380`

#### --initial-cluster

> --initial-cluster 'default=http://localhost:2380'
>
> ​		initial cluster configuration for bootstrapping.

启动初始化集群的配置。

- 默认：`default=http://localhost:2380`
- 环境变量：`ETCD_INITIAL_CLUSTER`
- =左边的名字是和`—name`标记的值

#### --initial-cluster-state

> ​	--initial-cluster-state 'new'
>
> ​		initial cluster state ('new' or 'existing').

初始化集群状态(new or existing)。在初始化静态(initial static)或者DNS启动(DNS bootstrapping)期间为所有成员设置为`new`。  

如果这个选项被设置为`existing`，etcd将试图加入已有的集群。  

如果设置为错误的值，etcd将尝试启动但安全失败。

- 默认：`new`
- 环境变量: `ETCD_INITIAL_CLUSTER_STATE`

#### --initial-cluster-token

> ​	--initial-cluster-token 'etcd-cluster'
>
> ​		initial cluster token for the etcd cluster during bootstrap.
>
> ​		Specifying this can protect you from unintended cross-cluster interaction when running multiple clusters.

在启动期间用于etcd集群的初始化集群标记

- 默认：`etcd-cluster`
- 环境变量：`ETCD_INITIAL_CLUSTER_TOKEN`

#### --advertise-client-urls

> --advertise-client-urls 'http://localhost:2379'
>
> ​		list of this member's client URLs to advertise to the public.
>
> ​		The client URLs advertised should be accessible to machines that talk to etcd cluster. etcd client libraries parse these URLs to connect to the cluster.

列出这个成员的客户端URL，通告为集群的其它成员。这些URL可以包含域名。

- 默认：`http://localhost:2379`

- 环境变量：`ETCD_ADVERTISE_CLIENT_URLS`

- 例子：`http://example.com:2379, http://192.168.1.123:2379`

  > 小心，如果来自集群成员的通告URL，比如`http://localhost:2379`正在使用etcd的proxy特性。  
  >
  > 这将导致循环，因而代理将转发请求给它自己直到它的资源最终耗尽。

#### --discovery

> --discovery ''
>
> ​		discovery URL used to bootstrap the cluster.

用于启动集群的发现URL。

- 默认为：""
- 环境变量：`ETCD_DISCOVERY`



### Security flags(安全标记)

> 安全标记用于搭建安全的etcd集群。

#### --ca-file【弃用】

> --ca-file '' [DEPRECATED]
>
> ​		path to the client server TLS CA file. '-ca-file ca.crt' could be replaced by '-trusted-ca-file ca.crt -client-cert-auth' and etcd will perform the same.

客户端服务器TLS证书文件的路径。`--ca-file ca.crt`可以被`--trusted-ca-file ca.crt --client-cert-auth`代替。

- 默认：''
- 环境变量: `ETCD_CA_FILE`

#### --cert-file

> --cert-file ''
>
> ​		path to the client server TLS cert file.

客户端服务器TLS证书文件的路径。

- 默认：none
- 环境变量：`ETCD_CERT_FILE`

#### --key-fle

> ​	--key-file ''
>
> ​		path to the client server TLS key file.

客户端服务器TLS key文件的路径。

#### --client-cert-auth

> --client-cert-auth 'false'
>
> ​		enable client cert authentication.

开启客户端证书认证。默认false

#### --truseted-ca-file

> ​	--trusted-ca-file ''
>
> ​		path to the client server TLS trusted CA cert file.

客户端服务器TLS信任证书文件的路径。

#### --auto-tls

> --auto-tls 'false'
>
> ​		client TLS using generated certificates.

使用自动生成的证书的客户端TLS。



----



```bash
➜  etc_etcd_ssl etcd -h
usage: etcd [flags]
       start an etcd server

       etcd --version
       show the version of etcd

       etcd -h | --help
       show the help information about etcd

       etcd --config-file
       path to the server configuration file

       etcd gateway
       run the stateless pass-through etcd TCP connection forwarding proxy

       etcd grpc-proxy
       run the stateless etcd v3 gRPC L7 reverse proxy
	

member flags:

	--name 'default'
		human-readable name for this member.
	--data-dir '${name}.etcd'
		path to the data directory.
	--wal-dir ''
		path to the dedicated wal directory.
	--snapshot-count '100000'
		number of committed transactions to trigger a snapshot to disk.
	--heartbeat-interval '100'
		time (in milliseconds) of a heartbeat interval.
	--election-timeout '1000'
		time (in milliseconds) for an election to timeout. See tuning documentation for details.
	--initial-election-tick-advance 'true'
		whether to fast-forward initial election ticks on boot for faster election.
	--listen-peer-urls 'http://localhost:2380'
		list of URLs to listen on for peer traffic.
	--listen-client-urls 'http://localhost:2379'
		list of URLs to listen on for client traffic.
	--max-snapshots '5'
		maximum number of snapshot files to retain (0 is unlimited).
	--max-wals '5'
		maximum number of wal files to retain (0 is unlimited).
	--cors ''
		comma-separated whitelist of origins for CORS (cross-origin resource sharing).
	--quota-backend-bytes '0'
		raise alarms when backend size exceeds the given quota (0 defaults to low space quota).
	--max-txn-ops '128'
		maximum number of operations permitted in a transaction.
	--max-request-bytes '1572864'
		maximum client request size in bytes the server will accept.
	--grpc-keepalive-min-time '5s'
		minimum duration interval that a client should wait before pinging server.
	--grpc-keepalive-interval '2h'
		frequency duration of server-to-client ping to check if a connection is alive (0 to disable).
	--grpc-keepalive-timeout '20s'
		additional duration of wait before closing a non-responsive connection (0 to disable).

clustering flags:

	--initial-advertise-peer-urls 'http://localhost:2380'
		list of this member's peer URLs to advertise to the rest of the cluster.
	--initial-cluster 'default=http://localhost:2380'
		initial cluster configuration for bootstrapping.
	--initial-cluster-state 'new'
		initial cluster state ('new' or 'existing').
	--initial-cluster-token 'etcd-cluster'
		initial cluster token for the etcd cluster during bootstrap.
		Specifying this can protect you from unintended cross-cluster interaction when running multiple clusters.
	--advertise-client-urls 'http://localhost:2379'
		list of this member's client URLs to advertise to the public.
		The client URLs advertised should be accessible to machines that talk to etcd cluster. etcd client libraries parse these URLs to connect to the cluster.
	--discovery ''
		discovery URL used to bootstrap the cluster.
	--discovery-fallback 'proxy'
		expected behavior ('exit' or 'proxy') when discovery services fails.
		"proxy" supports v2 API only.
	--discovery-proxy ''
		HTTP proxy to use for traffic to discovery service.
	--discovery-srv ''
		dns srv domain used to bootstrap the cluster.
	--strict-reconfig-check 'true'
		reject reconfiguration requests that would cause quorum loss.
	--auto-compaction-retention '0'
		auto compaction retention length. 0 means disable auto compaction.
	--auto-compaction-mode 'periodic'
		interpret 'auto-compaction-retention' one of: periodic|revision. 'periodic' for duration based retention, defaulting to hours if no time unit is provided (e.g. '5m'). 'revision' for revision number based retention.
	--enable-v2 'true'
		Accept etcd V2 client requests.

proxy flags:
	"proxy" supports v2 API only.

	--proxy 'off'
		proxy mode setting ('off', 'readonly' or 'on').
	--proxy-failure-wait 5000
		time (in milliseconds) an endpoint will be held in a failed state.
	--proxy-refresh-interval 30000
		time (in milliseconds) of the endpoints refresh interval.
	--proxy-dial-timeout 1000
		time (in milliseconds) for a dial to timeout.
	--proxy-write-timeout 5000
		time (in milliseconds) for a write to timeout.
	--proxy-read-timeout 0
		time (in milliseconds) for a read to timeout.


security flags:

	--ca-file '' [DEPRECATED]
		path to the client server TLS CA file. '-ca-file ca.crt' could be replaced by '-trusted-ca-file ca.crt -client-cert-auth' and etcd will perform the same.
	--cert-file ''
		path to the client server TLS cert file.
	--key-file ''
		path to the client server TLS key file.
	--client-cert-auth 'false'
		enable client cert authentication.
	--client-crl-file ''
		path to the client certificate revocation list file.
	--trusted-ca-file ''
		path to the client server TLS trusted CA cert file.
	--auto-tls 'false'
		client TLS using generated certificates.
	--peer-ca-file '' [DEPRECATED]
		path to the peer server TLS CA file. '-peer-ca-file ca.crt' could be replaced by '-peer-trusted-ca-file ca.crt -peer-client-cert-auth' and etcd will perform the same.
	--peer-cert-file ''
		path to the peer server TLS cert file.
	--peer-key-file ''
		path to the peer server TLS key file.
	--peer-client-cert-auth 'false'
		enable peer client cert authentication.
	--peer-trusted-ca-file ''
		path to the peer server TLS trusted CA file.
	--peer-cert-allowed-cn ''
		Required CN for client certs connecting to the peer endpoint.
	--peer-auto-tls 'false'
		peer TLS using self-generated certificates if --peer-key-file and --peer-cert-file are not provided.
	--peer-crl-file ''
		path to the peer certificate revocation list file.
	--cipher-suites ''
		comma-separated list of supported TLS cipher suites between client/server and peers (empty will be auto-populated by Go).

logging flags

	--debug 'false'
		enable debug-level logging for etcd.
	--log-package-levels ''
		specify a particular log level for each etcd package (eg: 'etcdmain=CRITICAL,etcdserver=DEBUG').
	--log-output 'default'
		specify 'stdout' or 'stderr' to skip journald logging even when running under systemd.

unsafe flags:

Please be CAUTIOUS when using unsafe flags because it will break the guarantees
given by the consensus protocol.

	--force-new-cluster 'false'
		force to create a new one-member cluster.

profiling flags:
	--enable-pprof 'false'
		Enable runtime profiling data via HTTP server. Address is at client URL + "/debug/pprof/"
	--metrics 'basic'
		Set level of detail for exported metrics, specify 'extensive' to include histogram metrics.
	--listen-metrics-urls ''
		List of URLs to listen on for metrics.

auth flags:
	--auth-token 'simple'
		Specify a v3 authentication token type and its options ('simple' or 'jwt').

experimental flags:
	--experimental-initial-corrupt-check 'false'
		enable to check data corruption before serving any client/peer traffic.
	--experimental-corrupt-check-time '0s'
		duration of time between cluster corruption check passes.
	--experimental-enable-v2v3 ''
		serve v2 requests through the v3 backend under a given prefix.
```

