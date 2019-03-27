## 集群指南

- [Clustering Guide](https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md)





| 名称   | IP地址        |       主机        |
| ------ | ------------- | :---------------: |
| node01 | 192.168.1.121 | node1.example.com |
| node02 | 192.168.1.122 | node2.example.com |
| node03 | 192.168.1.123 | node3.example.com |



- `/etc/systemd/system/etcd.service`

```
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/local/bin/etcd \
  --name=node03 \
  --cert-file=/etc/etcd/ssl/etcd.pem \
  --key-file=/etc/etcd/ssl/etcd-key.pem \
  --peer-cert-file=/etc/etcd/ssl/etcd.pem \
  --peer-key-file=/etc/etcd/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ssl/ca.pem \
  --initial-advertise-peer-urls=https://192.168.1.123:2380 \
  --listen-peer-urls=https://192.168.1.123:2380 \
  --listen-client-urls=https://192.168.1.123:2379,http://127.0.0.1:2379 \
  --advertise-client-urls=https://192.168.1.123:2379 \
  --initial-cluster-token=etcd-cluster-0 \
  --initial-cluster=node01=https://192.168.1.121:2380,node01=https://192.168.1.122:2380,node03=https://192.168.1.123:2380 \
  --initial-cluster-state=new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

