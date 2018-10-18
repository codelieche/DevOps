## Vagrant Centos Kubernetes

通过vagrant ssh master/node01/node02进入虚拟机

### 基础准备
- `yum install wget vim`
- 安装网络工具：`yum install -y net-tools telnet`

### 配置仓库
1. 进入repos目录：`cd /etc/yum.repos.d`
2. 下载repo文件：`wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo`
3. 添加kubernetes.repo文件：`vim kubernetes.repo`

**kubernetes.repo文件内容：**
```
[kubernetes]
name=kubernetes Repo
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
enable=1
```
4. 查看仓库：`yum repolist`

5. 安装服务：`yum install docker-ce kubeadm kubelet kubectl`

6. 把普通用户加入docker组

   ```
   sudo groupadd docker
   sudo gpasswd -a vagrant docker
   sudo systemctl start docker
   ```


### 安装基础服务
1. 给Docker拉取镜像加入Proxy：`vim /usr/lib/systemd/system/docker.service`

```
[Service]
Type=notify

# Add Environment
# Environment="HTTPS_PROXY=http://xxx:10080"
Environment="NO_PROXY=127.0.0.0/8,10.10.0.0/16"

LimitNOFILE=infinity
LimitNPROC=infinity
```
如果拉取镜像想设置代理，可以在Environment中配置，网络问题如果镜像拉取不了，可以通过导入方式。


在Service中加入了`Environment`

2. 执行reload：`systemctl daemon-reload`
3. 重启或者启动Docker：`systemctl restart docker`
4. 查看Docker服务信息：`docker info`
5. 记得关闭iptables和firewall的服务，vagrant安装的centos没开启这两个服务
    1. `service iptables stop`
    2. `service firewalld stop`

6. 确保这两个文件的值是`1`:
    1. `/proc/sys/net/bridge/bridge-nf-call-iptables`
    2. `/proc/sys/net/bridge/bridge-nf-call-ip6tables`
    3. 修改这两个文件的值为1: `echo 1 > /proc/sys/net/bridge/上面2个文件`

7. 设置`Docker`和`kubelet`开机启动：`systemctl enable docker kubelet`

```
[root@node02 yum.repos.d]# systemctl enable docker kubelet
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /etc/systemd/system/kubelet.service.
```

#### 修改kubelet的额外参数
> 由于启用了Swap，启动k8s会报错，需要添加额外的参数。

- `cat /etc/sysconfig/kubelet`
- 设置`KUBELET_EXTRA_ARGS="--fail-swap-on=false"`


### Kubeadm 初始化
> 通过`# kubeadm init --help`查看参数

#### 参数说明
1. `--apiserver-addretise-address`：默认`0.0.0.0`监听的api server的地址
2. `--apiserver-bind-port`: 默认6443,服务监听的端口
3. `--cert-dir`: 证书的根目录，默认：`/etc/kubernetes/pki`
4. `--config`: kubeadm自己的配置文件
5. `--ignore-preflight-errors`: 预检查的时候忽略某些参数，比如Swap等
6. `--kubernetes-version`: 选择的kubernetes版本，eg: `v1.11.1`
7. `--pod-net-work-cidr`: Pod的网络: 10.244.1.0
8. `--service-cidr`: Service的网络地址：默认`10.96.0.0/12`
9. `--service-dns-domain`: 服务的域名前缀，默认：`cluster.local`

#### 执行init
- 注意：apiserver-advertise-address不要使用默认的，而是需要使用master的IP

```
kubeadm init --kubernetes-version=v1.11.1 --pod-network-cidr=10.244.0.0/16 \
--service-cidr=10.96.0.0/12 --apiserver-advertise-address=192.168.6.91 \
--ignore-preflight-errors=Swap
```

提示：可以事先拉取好镜像
```
....
[preflight/images] Pulling images required for setting up a Kubernetes cluster
[preflight/images] This might take a minute or two, depending on the speed of your internet connection
[preflight/images] You can also perform this action in beforehand using 'kubeadm config images pull'
...
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 192.168.6.91:6443 --token a4pzwp.xxxxx --discovery-token-ca-cert-hash sha256:a04bxxxxxxxx.....
```

  ### 给kubectl添加配置
  > 在`kubeadmin init`安装完成的结果中有相关的提示

  - 创建.kube目录：`mkdir -p $HOME/.kube`
  - 复制config文件：`cp -i /etc/kubernetes/admin.conf $HOME/.kube/config`
  - 修改config的权限：`chown $(id -u):$(id -g) $HOME/.kube/config`
  - 查看结果：`kubectl cluster-info`
  - 把root的配置也复制给vagrant用户：`cp -rf /root/.kube/ /home/vagrant/`

大功告成！！！

---

#### 加入Node节点
- 需要设置：/proc/sys/net/bridge/bridge-nf-call-iptables为1
- 需要设置swap：去编辑vim /etc/sysconfig/kubelet文件。
- 准备好Docker、Kubelet、Kubeadm，而且需要启动好Docker

> 根据kubeadmin的命令提示报错：

```
[ERROR Swap]: running with swap on is not supported. Please disable swap
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
```
需要忽略Swap

```
kubeadm join 192.168.6.91:6443 --token a4pzwp.xxxxxx --discovery-token-ca-cert-hash sha256:xxxxxx --ignore-preflight-errors=Swap
```

再次执行提示网络不通：
```
[discovery] Failed to request cluster info, will try again: [Get https://10.0.2.15:6443/api/v1/namespaces/kube-public/configmaps/cluster-info: dial tcp 10.0.2.15:6443: connect: connection refused]
```

用telnet测试是否能联通6443:【坑】所以init的时候要设置:`--apiserver-advertise-address=192.168.6.91`

```
[vagrant@node01 ~]$ telnet 10.0.2.15 6443
Trying 10.0.2.15...
telnet: connect to address 10.0.2.15: Connection refused
[vagrant@node01 ~]$ telnet 192.168.6.91 6443
Trying 192.168.6.91...
Connected to 192.168.6.91.
Escape character is '^]'.
```
改用以下命令：

```
kubeadm join 192.168.6.91:6443 --token a4pzwp.xxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxx --ignore-preflight-errors=Swap
```
执行成功：查看node节点

```bash
[vagrant@master ~]$ kubectl get nodes
NAME      STATUS     ROLES     AGE       VERSION
master    NotReady   master    14m       v1.11.2
node01    NotReady   <none>    13m       v1.11.2
node02    NotReady   <none>    8s        v1.11.2
```
---

