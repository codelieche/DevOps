## 参考文档
- [elasticsearch官网](https://www.elastic.co/)
- [eleasticsearch-rtf](https://github.com/medcl/elasticsearch-rtf)
- [eleasticsearch-head](https://github.com/mobz/elasticsearch-head)
- [kibana](https://www.elastic.co/downloads/kibana)

## elasticsearch-rtf
> elasticsearch中文发行版，针对中文集成了相关插件，方便新手学习测试.  
使用kibana的版本，需要和elasticsearch的版本相同【匹配】。  
需要java8的环境。

### 基本使用

#### 下载

```
git clone git://github.com/medcl/elasticsearch-rtf.git -b master --depth 1
```

#### 运行
Linux/MacOS:

```bash
cd elasticsearch/bin
./elasticsearch
```

windows:

```
cd elasticsearch/bin
elasticsearch.bat
```
判断是否启动成功：`curl http://localhost:9200/`

```
➜  elasticsearch-rtf git:(master) ✗ curl http://localhost:9200/
{
  "name" : "Ghjv9zj",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "CLOh7iavQVC-nry8_WDxoA",
  "version" : {
    "number" : "5.1.1",
    "build_hash" : "5395e21",
    "build_date" : "2016-12-06T12:36:15.409Z",
    "build_snapshot" : false,
    "lucene_version" : "6.3.0"
  },
  "tagline" : "You Know, for Search"
}
```

### EleasticSearch集群配置

#### master
配置：

```yml
cluster.name: esdata
node.name: master

network.host: 127.0.0.1
```

#### slave
- 集群名要和主节点的名相同
- 由于是本地测试，所以http.port要不同，默认的9200被主节点占用了

配置：

```yml
cluster.name: esdata
node.name: slave1

network.host: 127.0.0.1
http.port: 9201

discovery.zen.ping.unicast.hosts: ["127.0.0.1"]
```

## elasticsearch-head

### 安装
> 5.X的版本已经不是个插件了，成为一个独立前端项目。并且需要设置下es的跨域访问。

- git clone git://github.com/mobz/elasticsearch-head.git
- cd elasticsearch-head
- npm install
- npm run start
- open http://localhost:9100/

### 配置elasticsearch的跨域访问
文件位置：`elasticsearch/config/elasticsearch.yml`，在文件末尾追加配置。

最简单的设置：

```
# 配置elasticsearch-head能跨域访问调用接口数据
http.cors.enabled : true
http.cors.allow-origin: "*"
```

详细一点再配置下方法和头信息：

```
http.cors.enabled : true
http.cors.allow-origin: "*"
http.cors.allow-methods: OPTIONS, HEAD, GET, POST, PUT, DELETE
http.cors.allow-headers: "X-Requested-With, Content-Type, Content-Length, X-User"
```
重新启动`elasticsearch`后，刷新下`http://localhost:9100/`,集群监控状态就显示为正常了。


## Kibana
> Kibana是需要和elasticsearch配套的。  

### 安装
- 下载：`https://www.elastic.co/downloads/past-releases`
- 解压后放到响应目录运行：`./kibana/bin/kibana`
-  浏览器访问：`open http://localhost:5601`

