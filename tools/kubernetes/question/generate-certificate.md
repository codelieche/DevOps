## 生成kubernetes相关证书



### 安装cfssl

```bash
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
mv ./cfssl_linux-amd64 /usr/local/bin/cfssl
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
```

### 生成根证书

- 文件：`ca/ca-config.json`

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

- 文件：`ca/ca-csr.json`

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
        "ST": "Beijing",
        "L": "BeiJing",
        "O": "k8s",
        "OU": "System"
      }
    ]
  }
  ```

- 执行命令：`cfssl gencert -initca ca-csr.json | cfssljson --bare ca`

  **查看文件：**

  ```bash
  [root@master01 ca]# tree
  .
  ├── ca-config.json
  └── ca-csr.json
  ```

  **执行命令：**

  ```bash
  ca-config.json  ca-csr.json
  [root@master01 ca]# cfssl gencert -initca ca-csr.json | cfssljson --bare ca
  2019/04/16 04:27:45 [INFO] generating a new CA key and certificate from CSR
  2019/04/16 04:27:45 [INFO] generate received request
  2019/04/16 04:27:45 [INFO] received CSR
  2019/04/16 04:27:45 [INFO] generating key: rsa-2048
  2019/04/16 04:27:45 [INFO] encoded CSR
  2019/04/16 04:27:45 [INFO] signed certificate with serial number 326534120759068953557350002467367998900610917209
  ```

  **执行命令后查看文件：**

  ```bash
  [root@master01 ca]# tree
  .
  ├── ca-config.json
  ├── ca.csr
  ├── ca-csr.json
  ├── ca-key.pem  # 秘钥(RSA PRIVATE KEY)
  └── ca.pem      # 证书(CERTIFICATE)
  ```

### 生成etcd相关的证书

>  先从ca目录，进入etcd的目录：`cd ../ && mkdir etcd`

 - 文件：`etcd/etcd-csr.json`

   ```json
   {
     "CN": "etcd",
     "hosts": [
       "127.0.0.1",
       "192.168.1.123",
       "192.168.1.124",
       "192.168.1.125",
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

- 执行命令生成etcd证书

  **进入etcd的目录：** `cd ./etcd`

  **执行命令：**

  ```bash
  cfssl gencert -ca=../ca/ca.pem -ca-key=../ca/ca-key.pem -config=../ca/ca-config.json -profile=kubernetes etcd-csr.json | cfssljson --bare etcd
  ```

  **查看文件：**

  ```bash
  [root@master01 etcd]# tree
  .
  ├── etcd.csr
  ├── etcd-csr.json
  ├── etcd-key.pem
  └── etcd.pem
  ```

### kubernetes api-server证书

> 进入上级目录，并创建kubernetes目录：`cd ../ && mkdir kubernetes`

- 文件：`kubernetes/kubernetes-csr.json`

  ```bash
  {
    "CN": "kubernetes",
    "hosts": [
      "127.0.0.1",
      "192.168.1.123",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local"
    ],
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "Beijing",
        "L": "XS",
        "O": "k8s",
        "OU": "System"
      }
    ]
  }
  
  ```

- 执行命令

  **进入目录**：`cd ./kubernetes`

  **生成证书：**

  ```bash
  cfssl gencert -ca=../ca/ca.pem -ca-key=../ca/ca-key.pem -config=../ca/ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson --bare kubernetes
  ```

  **查看证书文件：**

  ```bash
  [root@master01 kubernetes]# tree
  .
  ├── kubernetes.csr
  ├── kubernetes-csr.json
  ├── kubernetes-key.pem
  └── kubernetes.pem
  ```

### kubectl证书

> 进入上级目录：`cd ../ && mkdir admin`

- 文件：`./admin/admin-csr.json`

  ```json
  {
    "CN": "admin",
    "hosts": [],
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "Beijing",
        "L": "XS",
        "O": "system:masters",
        "OU": "System"
      }
    ]
  }
  ```

- 执行命令

  **进入目录**：`cd ./admin`

  **生成证书：**

  ```bash
  cfssl gencert -ca=../ca/ca.pem -ca-key=../ca/ca-key.pem -config=../ca/ca-config.json -profile=kubernetes admin-csr.json | cfssljson --bare admin
  ```

  **查看证书文件：**

  ```bash
  [root@master01 admin]# tree
  .
  ├── admin.csr
  ├── admin-csr.json
  ├── admin-key.pem
  └── admin.pem
  ```
