### 健康检查（Health Check）

> 强大的自愈能力是Kubernetes这类容器编排引擎的一个重要特性。
>
> 自愈的默认实现方式是自动重启发生故障的容器。
>
> 用户可以利用`Liveness`和`Readiness`探测机制设置更精细的监控检查，进而实现如下需求。
>
> 1. 零停机部署
> 2. 避免部署无效的镜像
> 3. 更加安全的滚动升级

Docker每个容器启动时都会执行一个进程，此进程由Dockerfile的CMD或ENTRYPOINT指定。  

如果进程退出时返回码非零，则认为容器发生故障，kubernetes就会根据restartPolicy重启容器。

在shell脚本中exit 0;就是正常退出的，exit 非零一般表示脚本执行错误。在c、python其它语言中都遵循了这个。



#### 默认的健康检查

```c
exit(0)表示程序正常, exit(1)和exit(-1)表示程序异常退出，exit(2)表示表示系统找不到指定的文件。
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: healthcheck
  labels:
    app: healthcheck
    group: ops
spec:
  restartPolicy: OnFailure
  containers:
  - name: healthcheck
    image: busybox
    args:
    - /bin/sh
    - -c
    - echo `date`; sleep 15; exit 1
```

创建个简单的Pod，15秒后它异常退出。同时设置其当容器失败的时候，重新启动个容器。

- `restartPolicy`: 重启策略，默认是Always，这里设置**OnFailure**

```bash
[root@centos-master yml]# vim health-check.yml
[root@centos-master yml]# kubectl apply -f health-check.yml
pod/healthcheck created
[root@centos-master yml]# kubectl get pods | grep health
healthcheck                     0/1     Error     0          17s
[root@centos-master yml]# kubectl get pods | grep health
healthcheck                     1/1     Running   1          22s
```

查看Pod资源的详情信息:

```bash
kubectl describe pod healthcheck

healthcheck   0/1     Error    1          38s
[root@centos-master yml]# kubectl get pod healthcheck
NAME          READY   STATUS   RESTARTS   AGE
healthcheck   0/1     Error    1          40s
[root@centos-master yml]# kubectl get pod healthcheck
NAME          READY   STATUS             RESTARTS   AGE
healthcheck   0/1     CrashLoopBackOff   1          44s
[root@centos-master yml]# kubectl get pod healthcheck
NAME          READY   STATUS    RESTARTS   AGE
healthcheck   1/1     Running   2          45s
```

#### Liveness探测

当我们web服务出现500内部错误，或者某个api访问不了，此时httpd进程是没有异常退出的。在这种情况下想重启容器，我们如何利用Health Check机制来处理这类场景呢？

**这个时候就可以使用：Liveness探测。**



