## ETCD证书生成、替换老的证书

ETCD节点：

- `192.168.1.123`
- `192.168.1.124`
- `192.168.1.125`

> 由于 Etcd 和 Kubernetes 全部采用 TLS 通讯，所以先要生成 TLS 证书, 证书生成工具采用 cfssl



### 1. 安装CFSSL

- 创建目录

```bash
root@yksv001238:~# mkdir etcd_tls
root@yksv001238:~/etcd_tls# pwd
/root/etcd_tls
```

- 下载工具

  ```bash
  wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
  wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
  chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
  mv ./cfssl_linux-amd64 /usr/local/bin/cfssl
  mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
  ```


### 2. 编写配置文件

 - `etcd-root-ca-csr.json`

   ```json
   {
       "CN": "kubernetes",
       "key": {
           "algo": "rsa",
           "size": 2048
       },
       "names": [
           {
               "C": "CN",
               "L": "BeiJing",
               "ST": "BeiJing",
               "O": "k8s",
               "OU": "System"
           }
       ]
   }
   ```

 - `config.json`

   ```json
   {
   "signing": {
       "default": {
         "expiry": "87600h"
         },
       "profiles": {
         "kubernetes": {
           "usages": [
               "signing",
               "key encipherment",
               "server auth",
               "client auth"
           ],
           "expiry": "87600h"
         }
       }
   }
   }
   ```

 - `etcd-csr.json`

   ```json
   {
     "CN": "etcd",
     "hosts": [
       "127.0.0.1",
       "192.168.1.123",
       "192.168.1.124",
       "192.168.1.125"
     ],
     "key": {
       "algo": "rsa",
       "size": 2048
     },
     "names": [
       {
         "C": "CN",
         "ST": "BeiJing",
         "L": "BeiJing",
         "O": "k8s",
         "OU": "System"
       }
     ]
   }
   ```



### 3. 生成证书

- `cfssl gencert --initca=true etcd-root-ca-csr.json | cfssljson --bare etcd-root-ca`

  ```bash
  root@master01:~/etcd_tls# cfssl gencert --initca=true etcd-root-ca-csr.json | cfssljson --bare etcd-root-ca
  2019/03/08 06:11:30 [INFO] generating a new CA key and certificate from CSR
  2019/03/08 06:11:30 [INFO] generate received request
  2019/03/08 06:11:30 [INFO] received CSR
  2019/03/08 06:11:30 [INFO] generating key: rsa-2048
  2019/03/08 06:11:31 [INFO] encoded CSR
  2019/03/08 06:11:31 [INFO] signed certificate with serial number 295186018993526857824105707690382846682584297847
  root@master01:~/etcd_tls# ls
  etcd-root-ca.csr  etcd-root-ca-csr.json  etcd-root-ca-key.pem  etcd-root-ca.pem
  ```

- `cfssl gencert -ca=etcd-root-ca.pem -ca-key=etcd-root-ca-key.pem -config=config.json  -profile=kubernetes etcd-csr.json | cfssljson -bare etcd`

  ```bash
  root@master01:~/etcd_tls# cfssl gencert -ca=etcd-root-ca.pem -ca-key=etcd-root-ca-key.pem -config=config.json  -profile=kubernetes etcd-csr.json | cfssljson -bare etcd
  2019/03/08 06:16:08 [INFO] generate received request
  2019/03/08 06:16:08 [INFO] received CSR
  2019/03/08 06:16:08 [INFO] generating key: rsa-2048
  2019/03/08 06:16:09 [INFO] encoded CSR
  2019/03/08 06:16:09 [INFO] signed certificate with serial number 196558702689292864383631774898198102788746044045
  2019/03/08 06:16:09 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
  websites. For more information see the Baseline Requirements for the Issuance and Management
  of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
  specifically, section 10.2.3 ("Information Requirements").
  root@master01:~/etcd_tls# ls
  config.json  etcd.csr  etcd-csr.json  etcd-key.pem  etcd.pem  etcd-root-ca.csr  etcd-root-ca-csr.json  etcd-root-ca-key.pem  etcd-root-ca.pem
  ```

- 复制文件到/etc/etcd/ssl

  注意把etcd-root-ca.pem 重命名为ca.pem

  ```bash
  root@master01:~/etcd_tls# mv /etc/etcd/ssl/ /etc/etcd/ssl.20190308
  root@master01:~/etcd_tls# mkdir /etc/etcd/ssl
  root@master01:~/etcd_tls# cp etcd.pem etcd-key.pem /etc/etcd/ssl
  root@master01:~/etcd_tls# cp etcd-root-ca.
  etcd-root-ca.csr  etcd-root-ca.pem
  root@master01:~/etcd_tls# cp etcd-root-ca.pem /etc/etcd/ssl/ca.pem
  root@master01:/etc/etcd/ssl# openssl x509 -in etcd.pem -noout -text |grep ' Not '
              Not Before: Mar  8 13:11:00 2019 GMT
              Not After : Mar  5 13:11:00 2029 GMT
  ```

### 4. 拷贝文件到其他节点

```bash
root@master01:~/etcd_tls# scp -r /etc/etcd root@192.168.1.124:/etc/etcd/
root@master01:~/etcd_tls# scp -r /etc/etcd root@192.168.1.125:/etc/etcd/
```



### 5. 重启etcd

先全部停掉，然后再全部启动

```bash
root@master01:~/etcd_tls# systemctl stop etcd
root@master01:~/etcd_tls# systemctl start etcd
root@master01:~/etcd_tls# systemctl status etcd
```

检查etcd的健康状况：

```
root@master01:/etc/etcd/ssl# etcdctl --ca-file=/etc/etcd/ssl/ca.pem --cert-file=/etc/etcd/ssl/etcd.pem --key-file=/etc/etcd/ssl/etcd-key.pem  cluster-health
2019-03-08 06:42:07.115771 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated
2019-03-08 06:42:07.116437 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated
member 316dbd21b17d1b4f is healthy: got healthy result from https://192.168.1.123:2379
member 8a206cf1ed53b6f4 is healthy: got healthy result from https://192.168.1.124:2379
member e444265665d3bd32 is healthy: got healthy result from https://192.168.1.125:2379
cluster is healthy
```



### 6. 重启kubernetes的三个服务

```bash
docker ps | grep "kube-apiserver\|kube-control\|kube-schedu" | grep -v "pause" | awk '{print $1}' | xargs docker restart
```



