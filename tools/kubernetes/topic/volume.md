### Kubernetes Volume

> 为了持久化保存容器的数据，可以使用Kubernetes Volume。

Volume的生命周期独立于容器，Pod中的容器可能被销毁和重建，单Volume会被保留。

本质上，Kubernetes Volume是一个目录，这一点与Docker Volume类似。当Volume被mount到Pod，Pod中的所有容器都可以访问这个Volume。  

Kubernetes Volume支持多种backend类型，包括：`emptyDir`、`hostPath`、`GCE Persistem Disk`、`NFS`、`Ceph`、`AWS Elastic Block Store`等。可参考[Kubernetes Voolume支持的类型](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes)



#### emptyDir

> emptyDir是最基础的Volume类型。正如其名字所示，一个emptyDir Volume是Host上的一个空目录。

emptyDir Volume对于容器类说是持久的，对于Pod则不是。  

当Pod从节点删除时，Volume的内容也会被删除。单如果只是容器被销毁而Pod还在，则Volume不受影响。

也就是是说：**emptyDir Volume**的生命周期与Pod一致。



**emptyDIr**是Host上创建的临时目录，其优点是能够方便地为Pod中的容器提供共享存储，不需要额外的配置。  

它不具备持久性，如果Pod不存在了，emtpyDir也就没有了。  

根据这个特性，emptyDir特别适合Pod中的容器需要临时共享存储空间的场景，比如前面的生产者和消费者用例。



#### hostPath

> hostPath Volume的作用是将Docker Host文件系统中已经存在的目录mount给Pod的容器。

大部分应用都不会使用hostPath Volume，因为这实际上增加了Pod与节点的耦合，限制了Pod的使用。  

不过那些需要访问Kubernetes或Docker内部数据（配置文件和二进制库）的应用则需要使用hostPath。



#### 外部Storage Provider



