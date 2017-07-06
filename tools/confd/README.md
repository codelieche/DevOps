### 介绍
> ETCD是一个键值存储仓库，用于配置共享和服务发现。

随着CoreOS和Kubernetes等项目在开源社区日益火热，它们项目中都用到的etcd组件作为一个高可用、强一致性的服务发现存储仓库，渐渐为开发人员所关注。

一般是我们使用etcd来保存键值对，然后用confd来监控键值对的变化，而做相应的操作。


### 安装
- MacOS中安装etcd: `brew install etcd`
- MacOS安装confd: 去github下载二进制文件，移动到：`/usr/local/bin/confd`(注意+X)

### 参考文档
- [github etcd](https://github.com/coreos/etcd/)
- [github condf](https://github.com/kelseyhightower/confd)