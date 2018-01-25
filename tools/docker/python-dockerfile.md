## 制作python镜像

主要是用于部署web项目，规划如下：

```
.
├── Dockerfile
└── www
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
- `Dockefile`: Docker镜像制作文件
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

### Dockerfile

```shell
FROM python:3.6.3-slim

# 指定工作目录
WORKDIR /data/www/
# 复制文件: ./是从docker build指定的上下文目录
COPY ./www/ /data/www/

# 创建devops用户和分组
# 安装一些包
	# pip安装有些包，需要先安装下面这些环境
	# pip install mysqlclient
	# pip install ansible
	# pip install pillow
	# 安装下httpie方便发起请求测试
	# 使用nginx + supervisor + nginx来部署项目
	# no-install-recommends参数来避免安装非必须的文件，从而减小镜像的体积
	# 执行完后删除本层的一些缓存文件
	# 移动conf文件和删除默认的nginx配置文件
	# 删除nginx默认的配置和supervisor默认的配置

RUN groupadd -r devops && useradd -m -r -g devops devops \
    && apt-get update && apt-get install -y \
	apt-utils \
	gcc \
	gettext \
	openssh-server \
	libmysqlclient-dev \
	python3-lxml \
	libjpeg-dev \
	libpng-dev \
	httpie \
	vim \
	nginx \
	supervisor \
	lrzsz \
	tree \
    --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& mkdir /root/.ssh && touch /root/.ssh/authorized_keys \
	&& cat /data/www/conf/id_rsa.pub >> /root/.ssh/authorized_keys \
	&& chmod 644 /root/.ssh/authorized_keys \
	&& chown -R devops:devops /data/www/ \
	&& ln -s /data/www/conf/mysite-nginx.conf /etc/nginx/sites-enabled/mysite-nginx.conf \
	&& cp /data/www/conf/mysite-supervisor.conf /etc/supervisor/conf.d/mysite-supervisor.conf \
	&& rm /etc/nginx/sites-enabled/default \
	&& echo "syntax on" >> /etc/vim/vimrc \
	&& echo "set nu" >> /etc/vim/vimrc \
	&& echo "set laststatus=2" >> /etc/vim/vimrc \
	&& echo "set ts=4" >> /etc/vim/vimrc \
	&& mkdir /data/backup \
	&& cp -rf /data/www /data/backup

	# service supervisor restart;
	# 使用python -m venv virtualenv 创建虚拟环境，挂载到/data/www/virtualenv中

# 定义匿名卷
VOLUME ["/data/www", "/home/devops"]
# 暴露端口
EXPOSE 80
ENTRYPOINT ["/data/backup/www/docker-entrypoint.sh"]
# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
```


### 其它文件内容

**1. www/conf/wsgi.py**:
> 一个简单的wsgi web程序。

```python
def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    return [b'<h1>Hello, Python Web!</h1>']
```

**2. www/conf/mysite-nginx.conf**
> nginx的配置文件。

```
server {
    listen 80;
	# 域名的过滤，请在Django的 settings.py中设：ALLOWED_HOSTS = ["codelieche.com"]
	# 当然也可以修改本文件，然后service nginx reload
    server_name  _;
    access_log /data/www/logs/access.log;
    error_log /data/www/logs/error.log;

    location / {
	    # unix套接字文件，需要与gunicorn里面的配置一一对应
        proxy_pass http://unix:/tmp/mysite.socket;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /robots.txt {
        alias /data/www/static/robots.txt;
    }

    location /favicon.ico {
        alias /data/www/static/favicon.ico;
    }

    # kubernetes中配置了健康检查，会用到:/check_health.html
    location /check_health.html {
        alias /data/www/check_health.html;
		default_type text/html;
    }

	# 用nginx来发布静态文件
    location ~ ^/(media|static)/ {
        root /data/www/;
        expires 30d;
    }

    location ~ /\. {
        access_log off; log_not_found off; deny all;
    }
}
```

**3. www/conf/mysite-supervisor.conf**

> supervisor配置文件

```
[program:mysite]
user=devops
command = /data/backup/www/run.sh
stdout_logfile = /data/www/logs/supervisor.logs
autostart=true
redirect_stderr = true
```

**4. www/docker-check.sh**

```shell
#!/bin/bash

# 检查/data/www是不是为空，如果为空就复制下/data/backup/www
if [ `ls /data/www | wc -l` -eq 0 ];
then
	cp -rf /data/backup/www/* /data/www;
fi

# 重启supervisor
service supervisor restart;
```

**5. www/docker-entrypoint.sh**

> 这个脚本是想当在执行 `CMD ["nginx", "-g", "daemon off;"]`前重启下supervisor服务。

```shell
#!/bin/sh

# 检查/data/www是不是为空，如果为空就复制下/data/backup/www
if [ `ls /data/www | wc -l` -eq 0 ];
then
	cp -rf /data/backup/www/* /data/www;
fi

# 判断命令是否包含nginx
result=$(echo $@ | grep "nginx")

if [ -n "$result" ];
then
    service supervisor restart
   # exec "$@"
fi

exec "$@"
```
