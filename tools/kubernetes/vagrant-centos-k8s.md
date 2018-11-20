## vagrant centos 安装 kubernetes 1.12.2



### 准备

1. master：192.168.6.105【网卡enp0s3】
2. Node01: 192.168.6.106 【NAT方式上网，同时作为6.105, 6.107的网关】
3. Node02: 192.168.6.107【网卡enp0s3】



### 安装脚本

#### 安装Docker Kubadm Kubectl

```bash
#!/bin/bash

# 第1步：安装好vim wget
yum install wget -y

# 第2步：下载docker的repos.d
# 2-1: 进入repos.d目录
cd /etc/yum.repos.d
# 2-2：下载docker-ce.repo
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo


# 第3步：安装docker相关组件
yum install docker-ce kubeadm kubelet kubectl -y

# 第4步：把普通用户加入到docker组
sudo groupadd docker
sudo gpasswd -a vagrant docker
sudo systemctl start docker

# 第5步：开机启动
systemctl enable docker kubelet
```

- kubelete运行在Cluster所有节点上，负责启动Pod和容器
- kubeadm用于初始化Cluster
- Kubectl是kubernetes命令行工具。通过kubectl可以部署和管理应用，查看各种资源，创建，删除和更新各种组件。

#### kubeadm init

```bash
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/sysconfig/kubelet
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables

kubeadm init --kubernetes-version=v1.12.2 --pod-network-cidr=10.244.0.0/16 \
--service-cidr=10.96.0.0/12 --apiserver-advertise-address=192.168.6.105 \
--ignore-preflight-errors=all \
```

安装成功后会出现：

```bash
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

  kubeadm join 192.168.6.105:6443 --token c86cm2.ub3jluu1k8q4t4oa --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxx

[root@centos-master scripts]#
```

#### kubectl配置

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

​	命令自动提示，可以输入：`kubectl completion -h`获取帮助文档。

​	CentOS可以通过：

```
yum install bash-completion -y
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

​	MacOS可以通过：

```
## If running Bash 3.2 included with macOS
brew install bash-completion
## or, if running Bash 4.1+
brew install bash-completion@2
```

如果是使用zsh可以在plugins中加入kubectl。



#### Kubeadm join

Join脚本：**注意替换成正式的`--token`和d`--iscovery-token-ca-cert-hash`

```
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/sysconfig/kubelet

echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables

kubeadm join 192.168.6.105:6443 \
--token c86cm2.xxxxxxx \
--discovery-token-ca-cert-hash sha256:a6da43c37a3db04a57a0c0df79xxxxxxxd390f23ce208b7015f8 \
--ignore-preflight-errors=all
```

加入成功输出：

```
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```



### 网络插件

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

- journalctl -f -u kubelet 查看日志

- 记得关闭防火墙

  ```
  systemctl disable firewalld
  systemctl stop firewalld
  ```

----

### 安装细节说明

**kubeadmin init输出内容说明：**

1. kubeadm执行初始化前的检查工作
2. 生成token和证书
3. 生成kubeConfig文件，kubelet需要用这个文件与Master通信
4. 安装Master组件，会从Google的Registry下载组件的Docker镜像，如果下载不了可以通过导入方式导入镜像
5. 安装附加组件kube-proxy和kube-dns
6. kubernetes Master初始化成功
7. 提示如何配置kubectl
8. 提示如何安装Pod网络
9. 提示如何注册其它节点到Cluster。