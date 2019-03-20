## 安装kibana

- [ install kibana](https://www.elastic.co/guide/en/kibana/current/rpm.html)

### CensOS安装kibana

#### 方式一: Installing from the RPM repository

- `cd /etc/yum.repos.d/`: 进入目录
- 创建文件：`kibana-6.x.repo`

```bash
[kibana-6.x]
name=Kibana repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

- 安装：`yum install kibana`

#### 方式二：Download and install the RPM manually

```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-x86_64.rpm
shasum -a 512 kibana-6.5.4-x86_64.rpm 
sudo rpm --install kibana-6.5.4-x86_64.rpm
```

修改配置文件：`/etc/kibana/kibana.yml`

```yml
server.port: 5601
server.host: "0.0.0.0"

elasticsearch.url: "http://192.168.1.123:9200"
elasticsearch.username: "elastic"
elasticsearch.password: "ThisIsPassword"
```

启动kibana：`systemctl kibana start`

