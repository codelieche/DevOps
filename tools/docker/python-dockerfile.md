## 制作python镜像

主要是用于部署web项目，规划如下：

```
/data/www
├── check_health.html
├── conf
│   ├── id_rsa.pub
│   ├── mysite-nginx.conf
│   ├── mysite-supervisor.conf
│   └── wsgi.py
├── docker-entrypoint.sh
├── docker_check.sh
├── logs
├── media
├── run.sh
├── source
└── static
```

### 目录/文件说明
- `/data/www`:项目所有相关文件都放这里, 使用的时候会挂载这个目录
- `conf`: 部署项目需要用到的配置文件
    1. `id_rsa.pub`: 想用ssh去连接容器，会把里面的公匙加入到/root/.ssh/authorized_keys中
    2. `mysite-nginx.conf`: nginx的配置文件
    3. `mysite-supervisor.conf`: supervisor的配置文件
    4. `wsgi.py`: 一个简单的web服务
    
- `docker-entrypoint.sh`: Dockfile中的ENTRYPOINT脚本
- `docker_check.sh`: 一个检查的脚本
- `logs`: 项目的日志信息，放这里
- `media`: 多媒体文件
- `run.sh`: supervisor执行的命令，gunicorn运行web项目命令在里面
- `source`: 项目的源代码所在目录
- `static`: 一些用nginx发布的静态文件所在目录

