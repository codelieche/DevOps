### 测试
- [grok-patterns](https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/grok-patterns)

### 安装
- ubuntu安装：
1. `apt-get install openjdk-8-jre`
2. 下载tar.gz文件解压

- `apt-get install`
```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list

apt-get update && apt-get install logstash
service logstash start|status|stop
```

### 服务器中logstash配置：
- `/etc/logstash/logstash.yml`[默认]
```yml
path.data: /var/lib/logstash
# 自己加入了: path.config
path.config: /etc/logstash/conf.d/*.conf
path.logs: /var/log/logstash
```
#### /etc/logstash/conf.d目录下配置文件
- 01-input-beats.conf
```yml
input {
    beats {
        port => 5044
        # ssl => true
        # ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
        # ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
    }
}
```

- 11-filter-log-default.conf
```yml
filter {
    if [fields][template] == "log-default" {
        grok {
            match => { "message" => "%{DATA:datetime}\|%{DATA:status}\|%{DATA:content}$" }
        }
        mutate {
          # 添加字段
          add_field => { "project" => "%{fields[project]}" }
          add_field => { "podIP" => "%{fields[podIP]}" }
        }
    }
}
```

## 文档摘要
### [Stashing You First Event](https://www.elastic.co/guide/en/logstash/current/first-event.html)
> A Logstash pipeline has two required elements, input and output, and one optional element, filter. The input plugins consume data from a source, the filter plugins modify the data as you specify, and the output plugins write the data to a destination.
> 一个Logstash管道有2个必须的参数，input和output，同时还有一个可选项（filter）。  
- `Input`: 输入插件消费一个数据源的数据
- `Filter`: 过滤插件修改数据为你具体想要的格式
- `Output`：输出插件把数据写入到目标位置

![](https://www.elastic.co/guide/en/logstash/current/static/images/basic_logstash_pipeline.png)

```
bin/logstash -e 'input { stdin { } } output { stdout {} }'
```

### [Parsing Logs with Logstash](https://www.elastic.co/guide/en/logstash/current/advanced-pipeline.html)
运行命令：
```bash
bin/logstash -f first-pipeline.conf --config.test_and_exit
bin/logstash -f first-pipeline.conf --config.reload.automatic
```
- `--config.test_and_exit`: 选项会解析配置文件并报告任何错误
- `--config.reload.automatic`: 会启用自动重新加载配置文件，这样每次修改配置文件不必重启Logstash

#### Parsing Web Logs with the Grok Filter Plugin
```yml
input {
    beats {
        port => 5044
    }
}

output {
    stdout {
        codec => rubydebug
    }
}
```

> Now you have a working pipeline that reads log lines from Filebeat. However you’ll notice that the format of the log messages is not ideal. You want to parse the log messages to create specific, named fields from the logs. To do this, you’ll use the grok filter plugin.
> 现在你有一个工作管道从Filebeat读取日志行。
> 但是注意到日志消息格式并不理想，你希望解析日志消息以从日志中创建特定的命名字。
> 这个时候，就需要用到`Grok`过滤插件了。

为了方便测试Grok可以通过[Grok Debug](https://www.elastic.co/guide/en/kibana/6.5/xpack-grokdebugger.html)调试。



----
### filebeat --> logstash --> elasticsearch

- study-to-logstash.yml配置内容：

```bash
filebeat.prospectors:
- type: log
  paths:
    - /data/logs/logstash.log
    - /data/logs/filebeat.log
  tags:
  - "codelieche"
  - "backend"
  fields:
    project: codelieche
    podIP: 192.168.1.123
    index: log-default

output.logstash:
  hosts: ["192.168.2.123:5044"]
```
- **启动filebeat**

```bash
➜  filebeat sudo ./6.3.2/filebeat -e -c ./study-to-logstash.yml -d "publish"
Exiting: error loading config file: config file ("study-to-logstash.yml") must be owned by the beat user (uid=0) or root
➜  filebeat sudo chown root ./study-to-logstash.yml
➜  filebeat sudo ./6.3.2/filebeat -e -c ./study-to-logstash.yml -d "publish"
```

- **启动logstash**
```bash
6.5.4/bin/logstash -e "input { beats{ port => "5044" } } output { stdout {} }"
```

- **测试**：往日志文件中追加内容：
```bash
echo "This Is Good | ddddd | dhahsha" >> /data/logs/logstash.log
```

- logstash的输出：
```bash
{
    "tags" => [
        [0] "codelieche",
        [1] "backend",
        [2] "beats_input_codec_plain_applied"
    ],
      "@version" => "1",
        "offset" => 31,
       "message" => "This Is Good | ddddd | dhahsha",
          "beat" => {
            "name" => "alexzhoudeMacBook-Pro.local",
        "hostname" => "alexzhoudeMacBook-Pro.local",
         "version" => "6.3.2"
    },
        "fields" => {
        "project" => "codelieche",
          "podIP" => "192.168.2.123"
    },
         "input" => {
        "type" => "log"
    },
        "source" => "/data/logs/logstash.log",
    "@timestamp" => 2019-01-03T07:34:23.172Z,
    "prospector" => {
        "type" => "log"
    },
          "host" => {
        "name" => "MacBook-Pro.local"
    }
}
```

- 升级版filebeat：加入过滤正则条件
```yml
filebeat.prospectors:
- type: log
  paths:
    - /data/logs/logstash.log
    - /data/logs/filebeat.log
  exclude_lines: ['DEBUG']
  include_lines: ['^\d+', '^Good']
  tags:
  - "codelieche"
  - "backend"
  fields:
    project: codelieche
    podIP: 192.168.2.123

output.logstash:
  hosts: ["localhost:5044"]
```

----

### logstash filter

```yml
filter {
   if [fields][template] == "log-default" {
    grok {
        match => {"message" => "%{DATA:ip}|%{DATA:status}|%{DATA:content}"}
        add_field => {"project" => "%{[fields][project]}"}
        # add_field => {"podIP" => "%{[fields][podIP]}"}
    }
    mutate {
         # 添加字段
         # add_field => { "project" => "%{fields[project]}" }
         add_field => { "podIP" => "%{fields[podIP]}" }
    }
   } 
    
}

```

- 简单filter：
```bash
filter {
    grok {
        match => {
            # "message" => "Duration: %{NUMBER:duration}"
            "message" => "%{DATA:datetime}\|%{DATA:status}\|%{DATA:content}$"
        }
        add_field => {"project" => "codelieche"}
        add_field => {"project2" => "codelieche2"}
    }
}
```

-----


### 遇到的问题
- 运行logstash报错：`Unrecognized VM option 'UseParNewGC'`

> 解决方式：vim 6.5.4/config/jvm.options
> 把-XX:UseParNewGC注释掉。

```
./bin/logstash -e "input { stdin { } } output { stdout {} }"
```


- Filebeat配置
```yml
filebeat.prospectors:
- type: log
  paths:
    - /data/logs/logstash.log
    - /data/logs/filebeat.log
  exclude_lines: ['DEBUG']
  #include_lines: ['^\d+', '^Good']
  include_lines: ['\d+', '^Good']
  tags:
  - "codelieche"
  - "backend"
  fields:
    project: codelieche
    podIP: 192.168.2.123
    index: codelieche-crontab

output.logstash:
  hosts: ["localhost:5044"]
```

 - Logstash配置
```yml
input {
 beats {
    port => 5044
 }
}

filter {
  if [fields][template] == "log-default" {
    grok {
            match => {
            "message" => "%{DATA:datetime}\|%{DATA:status}\|%{DATA:content}$"
        }
        # add_field => {"project" => [fields][project]}
        add_field => {"project" => "codelieche"}
        add_field => {"project2" => "codelieche2"}
    }
    mutate {
          # 添加字段
          add_field => { "project" => "%{fields[project]}" }
          add_field => { "podIP" => "%{fields[podIP]}" }
    }
  }

}

output {
 elasticsearch {
   hosts => ["http://127.0.0.1:9200"]
   index => "%{[fields][index]}-%{+YYYY.MM.dd}"
 }
  # stdout {}
}
```
-----