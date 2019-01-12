## 参考文档：
- [Install Elasticsearch With Docker](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/docker.html)


### 镜像制作
#### 文件结构【版本一】
```
├── Dockerfile
├── README.md
└── elasticsearch.yml
```
- elasticsearch.yml
```yml
FROM docker.elastic.co/elasticsearch/elasticsearch:6.5.4

# USER root
COPY --chown=elasticsearch:elasticsearch ./elasticsearch.yml /usr/share/elasticsearch/config
```
> 版本一：只修改配置文件，挂载的目录都不变更

#### 文件结构【版本二】：
```
├── Dockerfile
├── README.md
└── backup
    ├── check_config.sh
    └── config
        └── elasticsearch.yml
```
- 配置文件：`elasticsearch.yml`
```yml
# 挂载数据:
path.data: /data/elasticsearch/data
path.logs: /data/elasticsearch/logs

cluster.name: '${CLUSTER_NAME:elasticsearch}'
network.host: '${NETWORK_HOST:0.0.0.0}'

node.name: '${NODE_NAME:node}'
http.port: ${HTTP_PORT:9200}
transport.tcp.port: 9300

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 1
discovery.zen.ping.unicast.hosts: ['${DISCOVERY_HOSTS:elasticsearch}']

http.cors.enabled: true
http.cors.allow-origin: "*"
```

- 编写：`check_config.sh`
```bash
#!/bin/sh

# 1. 检查日志目录是否为空
# 1-1: 检查Data目录文件
if [ ! -d /data/elasticsearch/data ];then
    mkdir -p /data/elasticsearch/data;
    chown -R elasticsearch:elasticsearch /data/elasticsearch
fi

# 1-2：检查配置目录
if [ ! -d /data/elasticsearch/config ];then
    # 创建配置和日志目录
    mkdir -p /data/elasticsearch/config;
    chown -R elasticsearch:elasticsearch /data/elasticsearch
fi

# 1-3：检查logs目录
if [ ! -d /data/elasticsearch/logs ];then
    # 创建配置和日志目录
    mkdir -p /data/elasticsearch/logs
    chown -R elasticsearch:elasticsearch /data/elasticsearch
fi

# 2：检查配置文件
if [ `ls /data/elasticsearch/config/ | wc -l` -eq 0 ];
then
    cp -rf /var/backup/config/* /data/elasticsearch/config/;
    chown -R elasticsearch:elasticsearch /data/elasticsearch/config 
fi;

if [ `ls /data/elasticsearch/config/ | wc -l` -gt 1 ];
then
    # 如果data下面的config有配置文件，就把这些配置文件拷贝过去
    rm -rf /usr/share/elasticsearch/config/elasticsearch.yml
    cp -rf /data/elasticsearch/config/* /usr/share/elasticsearch/config/
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config/
fi;

# 3: 链接elasticsearch.yml
# 容器第一次启动：是无elasticsearch.lock这个文件的
# 这个时候，我们把/data下面的elasticsearch.yml软链到/usr/share/elasticsearch/config/
# 然后创建elasticsearch.lock文件
if [ ! -f /usr/share/elasticsearch/config/elasticsearch.lock ]
then
   if [ -f /data/elasticsearch/config/elasticsearch.yml ];then
        rm /usr/share/elasticsearch/config/elasticsearch.yml
        ln -s /data/elasticsearch/config/elasticsearch.yml /usr/share/elasticsearch/config/
        touch /usr/share/elasticsearch/config/elasticsearch.lock
        chown -R elasticsearch:elasticsearch /data/elasticsearch/ 
   fi;
    
fi;
```
- `check_config.yml`的作用
    1. 替换掉基础镜像中的相关文件
    2. 挂载的时候目录为空，就从backup中拷贝出文件
    3. 当挂载的文件中，已经有了配置文件，就采用挂载的相关文件

- `Dockerfile`
```Dockerfile
FROM docker.elastic.co/elasticsearch/elasticsearch:6.5.4

# USER root
COPY --chown=elasticsearch:elasticsearch ./backup /var/backup

RUN chmod +x /var/backup/check_config.sh && sh /var/backup/check_config.sh && \
   chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config /data/elasticsearch

# EXPOSE 9200 9300
VOLUME [ "/data/elasticsearch/" ]

# ENTRYPOINT ["/var/backup/entrypoint.sh"]
```

#### 构建镜像
- 进入`Dockerfile`所在的目录
- 构建镜像：`docker build . -t elasticsearch:6.5.4`

#### 使用镜像
- `docker run -itd --name elasticsearch -p 9201:9200 -p 9301:9300 -e CLUSTER_NAME=codelieche-es elasticsearch:6.5.4`
- 进入容器(`-u 0` 以root用户进入)：`docker exec -u 0 -it elasticsearch /bin/bash`
- 安装：net-tools：`yum install net-tools`
- 查看监听的端口：`netstat -an`

```bash
[root@6d0d44f21300 elasticsearch]# netstat -an | grep LISTEN
tcp        0      0 0.0.0.0:9300            0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:9200            0.0.0.0:*               LISTEN
```

#### 删除容器

```bash
docker stop elasticsearch
docker rm elasticsearch
docker rmi elasticsearch:6.5.4
```

### kubernetes中部署：

#### Deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: codelieche-es
    role: master
  name: codelieche-es-master
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: codelieche-es
      role: master
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: codelieche-es
        role: master
    spec:
      containers:
      - name: elasticsearch
        env:
        - name: CLUSTER_NAME
          value: elasticsearch-codelieche
        - name: NODE_NAME
          value: master
        - name: DISCOVERY_HOSTS
          value: codelieche-es
        image: registry.codelieche.com:5000/elasticsearch:6.5.v1
        imagePullPolicy: Always
        resources:
          limits:
            memory: 4Gi
          requests:
            memory: 512Mi
#        livenessProbe:
 #         failureThreshold: 3
  #        initialDelaySeconds: 180
   #       periodSeconds: 10
    #      successThreshold: 1
     #     tcpSocket:
     #       port: 9200
      #    timeoutSeconds: 30
        volumeMounts:
        - mountPath: /usr/share/elasticsearch/data
          name: esdatadir

      dnsPolicy: ClusterFirst
      nodeSelector:
        ELASTICSERACH: ""
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - hostPath:
          path: /data/codelieche-es-master/data
        name: esdatadir
```
- node节点的差不多，记得改下name和role

#### Service
- `codelieche-es`: 配置clusterIP为None【重点】用于es集群的discovery
```
discovery.zen.ping.unicast.hosts: ['${DISCOVERY_HOSTS:elasticsearch}']
```
- `codelieche-es-master`: 集群master节点的Service，这个是需要有clusterIP的
- `colelieche-es-node01`: 集群node01节点的Service，这个是需要有clusterIP的
- 节点是否是master，由集群自己去确定的

```yml
# Elasticsearch
apiVersion: v1
kind: Service
metadata:
  labels:
    app: codelieche-es
  name: codelieche-es
  namespace: default
spec:
  clusterIP: None
  ports:
  - port: 9200
    protocol: TCP
    targetPort: 9200
    name: http
  - port: 9300
    protocol: TCP
    targetPort: 9300
    name: transport
  selector:
    app: codelieche-es
  sessionAffinity: None
  type: ClusterIP

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: codelieche-es
    role: master
  name: codelieche-es-master
  namespace: default
spec:
  ports:
  - port: 9200
    protocol: TCP
    targetPort: 9200
    name: http
  - port: 9300
    protocol: TCP
    targetPort: 9300
    name: transport
  selector:
    app: codelieche-es
  sessionAffinity: None
  type: ClusterIP

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: codelieche-es
    role: node01
  name: codelieche-es-node01
  namespace: default
spec:
  ports:
  - port: 9200
    protocol: TCP
    targetPort: 9200
    name: http
  - port: 9300
    protocol: TCP
    targetPort: 9300
    name: transport
  selector:
    app: codelieche-es
  sessionAffinity: None
  type: ClusterIP
```

---

### 遇到的问题
- 挂载目录，所有者为root而不是elasticsearch