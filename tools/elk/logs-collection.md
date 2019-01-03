## Filebeat + logstash + Elasticsearch日志收集

### 执行步骤

- Filebeat采集某个目录的文件，把采集的日志传给Logstash
- Logstash处理后把文件传给Elasticsearch
- kibana展示采集的数据

### 基本操作

> 假如我们有日志文件存放在：/data/logs下面
>
> 而且日志有3个字段：datetime, status, content，字段之间以管道符分割`|`

#### Filebeat

- Filebeat.yml

  ```yml
  filebeat.prospectors:
  - type: log
    paths:
      - /data/logs/logstash.log
      - /data/logs/filebeat.log
    exclude_lines: ['DEBUG']
    include_lines: ['\d+', '.*?\|']
    tags:
    - "study"
    - "backend"
    fields:
      project: ops
      template: codelieche
      index: codelieche
  
  output.logstash:
    hosts: ["localhost:5044"]
  ```

- 参数说明：

  - `prospectors`：勘探者
  - `type`：Filebeat当前支持两种勘测类型：log和 stdin
  - `exclude_lines`: 排除的行，正则匹配
  - `include_lines`: 包含的行，正则匹配，多个满足一个即可
  - `tags`: 自定义些标签
  - `fields`: 自定义一些字段, 可当参数传给`logstash`
  - `output.logstash`: 配置为输出给logstash

- 启动filebeat：`sudo ./filebeat -e -c ./filebeat.yml -d "publish"`



#### Logstash

- Logstash.yml

  ```yml
  input {
   beats {
      port => 5044
   }
    # stdin { }
  }
  
  filter {
      grok {
          match => {
              "message" => "%{DATA:datetime}\|%{DATA:status}\|%{DATA:content}$"
          }
          add_field => {"project" => "testproject"}
          add_field => {"group" => "codelieche"}
      }
  }
  
  output {
   elasticsearch {
     hosts => ["http://localhost:9200"]
     index => "%{[fields][index]}-%{+YYYY.MM.dd}"
   }
     stdout {
     }
  }
  ```

- 参数说明：

  - `input`: 设置输入
  - `filter`: 设置过滤，可根据不同条件做过滤：`if [fields][template] == "xxx" {...}`
  - `output`: 设置输出到哪

- 启动logstash：`bin/logstash -f ./logstash.yml`



#### 写入测试日志

```bash
for i in {1..10};do echo "`date`|success|成功日志内容${i}" >> /data/logs/logstash.log;sleep 10;done
for i in {1..3};do echo "`date`|error|错误内容${i}" >> /data/logs/logstash.log;sleep 10;done
for i in {1..5};do echo "`date`|warn|警告内容${i}" >> /data/logs/logstash.log;sleep 10;done
```

写点success/error/warn日志信息到日志文件。

