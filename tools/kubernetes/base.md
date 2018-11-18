## Kubernetes架构

### Master节点

> Master是kubernetes Cluster的大脑，运行着Daemon服务包括kube-apiserver、kube-scheduler、kube-controller-manager、etcd和Pod网络。

- API Server（kube-apiserver）

  > API Server提供http/https的RESTful API，即kubernetes API。  
  >
  > API Server是kubernetes Cluster的前端接口，各种客户端以及kubernetes其它组件可以通过它管理Cluster的各种资源

- Schedule（kube-scheduler)

  > Schedule负责决定将Pod放在哪个Node上运行。Schedule在调度时会充分考虑Cluster的拓扑结构，当前各节点的负责，以及应用对高可用、性能、数据亲和性的需求。

- Controller Manager（kube-controller-manager）

  > Controller Manager负责管理Cluster各种资源，保证资源处于预期的状态。  
  >
  > Controller Manager由多种controller组成，包括：replication controller、endpoints controller、namespace controller、serviceaccounts controller等。

  不同的controller管理不同的资源。比如：replication controller管理Deployment、StatefulSet、DaemonSet的生命周期，namespace controller管理Namespace资源。

- etcd

  > etcd负责保存kubernetes cluster的配置信息和各种资源的状态信息。  
  >
  > 当数据发生变化时，etcd会快速得通知kubernetes相关组件。

- Pod网络

  > Pod要能够相互通信，kubernetes Cluster必须部署Pod网络，比如采用flannel网络方案。

### Node节点

> Node是Pod运行的地方，kubernetes支持Docker、rkt等容器Runtime。  
>
> Node上运行的Kubernetes组件有Kubelet、kube-proxy和Pod网络。

- kubelet

  > kubelet是Node的agent，它是唯一没有以容器形式运行的kubernetes组件。在CentOs中可以通过`systemctl status kubelet`查看服务运行状态。

  当Master的Scheduler确定在某个Node上运行Pod后，会将Pod的具体配置信息（image、vollume等）发送给节点的kubelet，kubelet根据这些信息创建和运行容器，并向Master报告运行状态。

- kube-proxy

  > service在逻辑上代表了后端的多个Pod，外界通过service访问Pod。  
  >
  > Service接收到请求是如何转发到Pod的呢？这就是kube-proxy要完成的工作。

  每个Node都会运行kube-proxy服务，它负责将访问的TCP/UDP数据流转发到后端的容器。如果有多个副本，kube-proxy会实现负载均衡。

- Pod网络

  > Pod要能够相互通信，kubernetes Cluster必须部署网络，比如flannel。



---

## 基本概念

### Cluster

> Cluster是计算、存储和网络资源的集合，Kubernetes利用这些资源运行各种基于容器的应用。

查看集群信息：`kubectl cluster-info`

### Master

> Master是Cluster的大脑，它主要职责是调度，即决定将应用放在那台机器上运行。  
>
> 生产环境一般是多个Master，比如3台。

### Node

> Node的职责是运行容器应用。Node由Master管理，Node负责监控并汇报容器的状态，同时根据Master的要求管理容器的生命周期（创建、销毁容器等）。

通过`kubectl get nodes`可以查看集群的Node信息。`kubectl get nodes -o wide`可以查看更多信息。

### Pod

> Pod是kubernetes的最小工作单元。每个Pod包含一个或者多个容器。Pod中的容器会作为一个整体被Master调度到一个Node上运行。

比如：web服务和收集日志的filebeat两个容器放一个Pod，Mysql和prometheus的MySQL Exporter两个容器放一个Pod里面。

**Kubernetes引入Pod的目的：**

1. 方便管理

   > 有些容器天生就是紧密联系的，一起工作。Pod提供了比容器更高层次的抽象，将他们封装到一个部署单元中。

   Kubernetes以Pod为最小单元进行调度、扩展、共享资源、管理生命周期。

2. 通信和资源共享

   > Pod中的所有容器使用同一个网络namespace，即相同的IP地址和Port空间。  
   >
   > 它们可以直接通过localhost/127.0.0.1通信。  
   >
   > 同样的，这些容器可以共享存储，当kubernetes挂载volume到Pod，本质上是将volume挂载到Pod中的每个容器。

### Controller

> Kubernetes通常不会直接创建Pod，而是通过Controller来管理Pod的，Controller中定义了Pod的部署特性，比如有几个副本、在什么样的Node上运行等。

Kubernetes提供了多种Controller：`Deployment`、`ReplicaSet`、`DaemonSet`、`StatefuleSet`、`Job`等。

**Deployment**

> Deployment是最常用的Controller，Deployment可以管理Pod的多个副本，并确保Pod按照期望的状态运行（在什么样的Node上，运行多少个）。

**ReplicaSet**

> ReplicaSet实现了Pod的多副本管理。使用Deployment时会自动创建ReplicaSet。  
>
> 也就是说Deployment是通过ReplicaSet来管理Pod的多个副本的，我们通常不需要直接使用ReplicaSet。

通过`kubectl get deployment/replicaset`可以查看相关信息。

```bash
[root@centos-master ~]# kubectl get deployment
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-deploy   3         3         3            3           2d21h
[root@centos-master ~]# kubectl get replicaset
NAME                     DESIRED   CURRENT   READY   AGE
nginx-deploy-86bf78c77   3         3         3       2d21h
```

**DaemonSet**

> DaemonSet是用于每个Node最多只运行一个Pod副本的场景。

```
[root@centos-master ~]# kubectl get daemonset -n kube-system
```

**StatefulSet**

> StatefulSet能保证Pod的每个副本在整个生命周期中名称是不变的，而其他Controller不提供整个功能。

**Job**

> Job用于运行结束就删除的应用，而其他Controller中的Pod通常是长期持续运行。



### Service

- Deployment可以部署多个副本，每个Pod都有自己的IP，外界如何访问这些副本呢？
- Pod是会被频繁的销毁和重启，它们的IP是会发生变化的
- 我们可以使用Service来访问这些Pod

> kubernetes Service定义了外界访问一组特定Pod的方式。Service有自己的IP和端口，Service为Pod提供了负载均衡。

**Kubernetes运行容器（Pod）与访问容器（Pod）这两项任务分别由Controller和Service执行。**

```bash
[root@centos-master ~]# kubectl get services -o wide
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE     SELECTOR
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP   3d      <none>
nginx        ClusterIP   10.96.125.84   <none>        80/TCP    2d22h   run=nginx-deploy
```



### Namespace

> Namespace用于区分多个不同的组使用同一个kubernetes cluster。

Namespace可以将一个物理的Cluster逻辑上划分为多个虚拟的Cluster，每个Cluster就是一个Namespace。  

不同的Namespace里的资源是完全隔离的。

`kubectl get namespace`可以查看有多少个namespace。默认有两个：

- `default`: 创建资源时如果不指定，将被放到这个namespace中。
- `kube-system`:kubernetes自己创建的系统资源将放到这个namespace中。

----

