## kubernetes
> Kubernetes是Google开源的容器集群管理系统，其提供应用部署、维护、 扩展机制等功能，利用Kubernetes能方便地管理跨机器运行容器化的应用

### Kubernetes基本概念和术语：
> 在Kubernetes中，Node，Deployment，Pod，Replication，Controller，Service等概念都可以看做一种资源对象，  
通过Kubernetes提供的Kubectl工具或者API调用进行操作，并保存在etcd中。

### 示例命令
- `kubectl get all | grep xxx`   `kubectl get all -o wide | grep codelieche`: 查看部署
- `kubectl exec -it xxxprod-xxxx bash`: 进入pod容器
- `kubectl edit deployment xxxx`: 编辑deployment的配置
- `kubectl delete pod xxxprod-xxx`: 如果删不掉后面加个`--now`的参数
- ` kubectl get all -o wide |grep 部署名`：查看容器部署在哪个节点部署的

### kubectl
#### kubectl常用命令列表
  1. `get`：显示一个或多个资源的信息
  2. `describe`：详细描述某个资源的信息
  3. `create`：通过文件名或标准输入创建一个资源
  4. `update`：通过文件名或标准输入修改一个资源
  5. `delete`：通过文件名、标准输入、资源的ID或标签删除资源
  6. `namespace`：设置或查看当前请求的命名空间
  7. `logs`：打印在Pod中的容器的日志信息
  8. `roling-update`：对一个给定的ReplicationController执行滚动更新（Rolling Update）
  9. `scale`：调节Replication Controller副本数量
  10. `exec`：在某个容器内执行某条命令
  11. `port-forward`：为某个pod设置一个或多个端口转发
  12. `proxy`：运行kubernetes API server代理
  13. `run`：在集群中运行一个独立的镜像（Image）
  14. `stop`：通过ID或资源名称删除一个资源
  15. `expose`：将资源对象暴露为Kubernetes Service
  16. `label`：修改某个资源上的标签（label）
  17. `config`：修改集群的配置信息
  18. `cluster-info`：显示集群信息
  19. `api-versions`：显示API版本信息
  20. `version`：打印Kebectl和API Server版本信息
  21. `help`：帮助命令
  
#### kubectl option列表
  1. `--alsologtostderr=false`：记录日志到标准错误输出及文件
  2. `--api-version=" "`：用于告知api server的Kubectl使用的API版本信息
  3. `--certificate-authority=" "`：证书文件的访问路径
  4. `--client-certificate=" "`：客户端证书文件路径（包括目录和文件名）
  5. `--client-key=" "`：客户端私匙文件路径（包括目录和文件名）
  6. `--cluster=" "`：指定集群的名称
  7. `--context=" "`：Kubectl配置文件上下文的名字
  8. `-h, --help=false`：是否支持kubectl帮助命令
  9. `--insecure-skip-tls-verify=false`：如果该值为true，则将不校验服务端证书，这将使用HTTPS连接不安全
  10. `--kubeconfig=" "`：kubectl配置文件的访问路径
  11. `--log-backtrace-at=:0`：当日志内容达到N行时，产生一个"stack trace"
  12. `--log-dir=`：指定日志文件的目录
  13. `--log-flush-frequency=5s`：两个log flush操作之间最大的时间间隔，单位为秒
  14. `--logtostderr=true`：打印日志到标准输出，代替写入文件
  15. `--match-server-version=false`：要求服务端版本和客户端版本匹配
  16. `--namespace=" "`：指定命名空间
  17. `--password=" "`：使用基本认证访问API Server时用到的密码
  18. `-s, --server=" "`：指定Kubernetes API Server的地址
  19. `--stderrthreshold=2`：设置讲日志写入标准错误输出的阈值
  20. `--token=" "`：使用Token方式访问API Server时用到的令牌
  21. `--user=" "`：访问API Server的用户名
  22. `---username=" "`：使用基本认证访问API Server时用到的用户名
  23. `--v=0`：V logs的日志级别
  24. `--validate=false`：如果该值为true，则在发送一个请求前使用一个"schema"校验输入信息
  25. `--vmodule=`：用于设置过滤日志的模式，各模式之间用逗号隔开。
