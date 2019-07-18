### Filebeat工作原理

> Filebeat启动一个或者多个`Prospector`去配置文件中指定的日志路径(比如：`/var/log/*.log`)下勘查文件。  
>
> 对于勘查到的文件，每个文件启动一个`Harvester`。
>
> 每个`Harvester`都读取一个文件，并把文件中新的数据发送到`Libbeat`。
>
> `Libbeat`会聚合接收到的事件，并把聚合后的数据发送给配置文件中指定的`Output`。

### Prospector

> Prospector负责管理Harvester,并发现所有可读的数据。

```yaml
# filebeat.prospectors:
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - "/var/log/apache/*.log"
    - "/var/log/nginx/*.log"
```

Filebeat当前支持两种勘查类型：log和stin。



### Harvester

> Harvester负责打开文件，开始逐行读取单个文件的内容，并将读取到的数据发送到Output。



### 参考文档

- [Filebeat Docs](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [config filebeat inputs](https://www.elastic.co/guide/en/beats/filebeat/master/configuration-filebeat-options.html)

