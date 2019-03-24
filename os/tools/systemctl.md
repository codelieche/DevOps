## systemctl启动脚本编写



### 编写elasticsearch.service

```
[Unit]
Description=elasticsearch

[Service]
Type=simple
User=esdata
Group=esdata
Environment=ES_HOME=/data/elasticsearch/6.6.2
Environment=ES_PATH_CONF=/data/elasticsearch/6.6.2/config
# ExecStart=/data/elasticsearch/6.6.2/bin/elasticsearch "-c /data/elasticsearch/6.6.2/config/elasticsearch.yml"
ExecStart=/data/elasticsearch/6.6.2/bin/elasticsearch -p ${ES_HOME}/elasticsearch.pid --quiet
Restart=always
WorkingDirectory=/data/elasticsearch

[Install]
WantedBy=multi-user.target
```





### 查看示例

- /etc/systemd/system/kibana.service

  ```
  [Unit]
  Description=Kibana
  
  [Service]
  Type=simple
  User=kibana
  Group=kibana
  # Load env vars from /etc/default/ and /etc/sysconfig/ if they exist.
  # Prefixing the path with '-' makes it try to load, but if the file doesn't
  # exist, it continues onward.
  EnvironmentFile=-/etc/default/kibana
  EnvironmentFile=-/etc/sysconfig/kibana
  ExecStart=/usr/share/kibana/bin/kibana "-c /etc/kibana/kibana.yml"
  Restart=always
  WorkingDirectory=/
  
  [Install]
  WantedBy=multi-user.target
  ```
