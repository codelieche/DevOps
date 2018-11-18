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

> kubernetes Service定义了外界访问一组特定Pod的方式。

