### 通过Service访问Pod

> Pod是会不断的销毁与创建，而且其IP也不是固定的。

每个Pod都有自己的IP地址。当Controller用新的Pod替代发生故障的Pod时，新的Pod会分配到新的IP地址。  

如果一组Pod对外提供服务（比如HTTP web服务），它们的IP很可能发生变化，那么客户端如何找到并访问这个服务呢？在Kubernetes中解决方案是Service。

> 问题有点类似：我们用云主机部署web网站，IP是变化的，但是用户通过唯一域名访问即可，不用关心背后是是部署在哪台服务器上的。



#### 创建Service

> Kubernetes Service从逻辑上代表了一组Pod，具体是哪些Pod则由label来挑选的。  
>
> Service有自己的IP，而且这个IP是不变的。

客户端只需要访问Service的IP，Kubernetes则负责建立和维护Service和Pod的映射关系。  

无论后端Pod如何变化，对客户端是没有影响的，因为Service的IP没有变。

- **先创建Deployment：nginx-deploy**

  ```yaml
  apiVersion: apps/v1beta1
  kind: Deployment
  metadata:
    name: nginx-deploy
  spec:
    replicas: 2
    template:
        metadata:
          labels:
            app: ops-web
            run: nginx-web
            group: ops
        spec:
          containers:
          - name: nginx
            image: nginx:1.14-alpine
            ports:
            - containerPort: 80
  ```

  **配置说明：**

  1. `apiVersion`: 是当前配置格式的版本
  2. `kind`: 是需要创建的资源类型，eg：Deployment, Service, ReplicaSet,Pod等
  3. `metadata`: 是该资源的元数据，**name**是必须的元数据项
  4. `spec`: 是该资源的规格说明
     1. `replicas`: 指明副本的数量，默认是1
     2. `template`：定义Pod的元数据，至少要定义一个label。label的key和value可以任意指定。
     3. `spec`: 描述Pod的规格，此部分中每一个容器的属性，name和image是必须的。

  通过：`kubectl apply -f  nginx-deploy.yml`创建Deployment。

  查看标签是app=ops-web的Pod：`kubectl get pods -l app=ops-web`

- **创建Service**：nginx-service

  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: nginx-svc
  spec:
    selector:
      app: ops-web
    ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  ```

  **配置说明：**

  1. `apiVersion`: api版本号，这里是v1
  2. `kind`: 这里当前资源的类型是Service
  3. `metadata`: 设置当前资源的元数据，设置name为nginx-svc
  4. `spec`: 当前资源Service的规格说明书
     1. `selector`: 指明挑选哪些label的Pod作为Service的后端
     2. `ports`: 端口映射

  通过`kubectl apply -f nginx-service.yml`部署service。

  ```bash
  [root@centos-master yml]# kubectl get service -o wide
  NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     SELECTOR
  kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   4d16h   <none>
  nginx-svc    ClusterIP   10.111.152.40   <none>        80/TCP    5m54s   app=ops-web
  ```

  Nginx-svc分配到了一个ClusterIP: 10.111.152.40。可以通过这个IP访问到后端的Pod。

  可以通过：`kubectl describe service nginx-svc`查看详细的信息。

  ```bash
  [root@centos-master yml]# kubectl describe service nginx-svc
  Name:              nginx-svc
  Namespace:         default
  Labels:            <none>
  Annotations:       kubectl.kubernetes.io/last-applied-configuration:
                       {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"nginx-svc","namespace":"default"},"spec":{"ports":[{"port":80,"pr...
  Selector:          app=ops-web
  Type:              ClusterIP
  IP:                10.111.152.40
  Port:              <unset>  80/TCP
  TargetPort:        80/TCP
  Endpoints:         10.244.1.26:80,10.244.2.19:80
  Session Affinity:  None
  Events:            <none>
  ```

  **Endpoints**罗列了2个Pod的IP和端口号。

  通过**iptables**把Pod的IP映射到ClusterIP.

  ClusterIP是一个虚拟IP，是由Kubernetes节点上的iptables规则管理的。

----

