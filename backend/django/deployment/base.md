## Django项目部署
> 使用: nginx + supervisor + gunicorn.

### 环境准备
- nginx
- supervisor: sudo apt-get install supervisor
- 运行项目的python环境，需要安装好gunicorn,django包

### 发布模版
> 模版文件中USERNAME是指服务器的用户名，SITENAME是web域名。使用的时候替换成自己需要的即可。

#### nginx配置模版
> nginx.template.conf

```
server {
    listen 80;
    server_name SITENAME;

    location /static {
        alias /data/www/SITENAME/static;
    }

    location / {
        proxy_set_header Host $host;
        proxy_pass http://unix:/tmp/SITENAME.socket;
    }
}
```

- `proxy_set_header`: 是让Gunicorn和Django知道他们运行在哪个域名下;
- Django项目settings.py中的ALLOWED_HOSTS需要设置nginx配置的域名;
- `proxy_pass`: 可以使用Unixi套接字,也可以使用端口号,如: `http://localhost:8000`。

#### gunicorn执行脚本模版
> gunicorn-run.template.sh

```bash
#!/bin/bash
NAME="django_projeact"
USER=USERNAME
WORKERS=2
DJANGODIR=/data/www/SITENAME
DJANGO_WSGI_MODULE=django_project.wsgi
PID_PATH=/tmp/gunicorn.${NAME}.pid

cd ${DJANGODIR}/source

exec ../virtualenv/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
    --name $NAME \
    --user $USER \
    --pid $PID_PATH \
    --workers $WORKERS \
    --bind=unix:/tmp/SITENAME.socket \
    --log-level=info \
    --access-logfile=${DJANGODIR}/logs/gunicorn.access.log \
    --error-logfile=${DJANGODIR}/logs/gunicorn.error.log \
```
> bind可以配置成 127.0.0.1:8080这种端口号，也可以是Unix套接字。  
django_project是项目创建时候的名字。

#### supervisor配置模版
> gunicorn-supervisor.template.conf

```
[program:django_project]
user=USERNAME
command = /data/www/SITENAME/run.sh
stdout_logfile = /data/www/SITENAME/logs/supervisor.logs
redirect_stderr = true
```

### fabric自动配置

把配置模版，放在django项目源码目录中的deploy_tools子目录中。

```
deploy_tools
├── fabfile.py
├── gunicorn-run.template.sh
├── gunicorn-supervisor.template.conf
└── nginx.template.conf
```

配置步骤:
1. 配置nginx
2. 配置gunicorn执行脚本
3. 配置supervisor

```python
from fabric.api import env, run
from fabric.context_managers import cd

SITE_NAME = 'test.codelieche.com'

def deploy_settings():
    site_folder = '/data/www/%s' % (SITE_NAME,)
    source_folder = site_folder + '/source'
    # 第一步：写入nginx的配置
    with cd(source_folder):
        # 进入source_folder
        run('sed "s/SITENAME/%s/g" deploy_tools/nginx.template.conf |'\
            ' sed "s/USERNAME/user_web/g" | sudo tee /etc/nginx/sites-enabled/%s' % (
                SITE_NAME,SITE_NAME))
    # 第二步: 写入gunicorn执行脚本
    with cd(source_folder):
        # 进入source_folder
        run('sed "s/SITENAME/%s/g" deploy_tools/gunicorn-run.template.sh |'\
            ' sed "s/USERNAME/user_web/g" | tee ../run.sh' % (
                SITE_NAME,))
        # 修改run.sh的权限
        run('chmod +x ../run.sh')

    # 第三步：添加supervisor配置
    with cd(source_folder):
        # 进入source_folder
        run('sed "s/SITENAME/%s/g" deploy_tools/gunicorn-supervisor.template.conf |'\
            ' sed "s/USERNAME/user_web/g" | sudo tee /etc/supervisor/conf.d/django_project.conf' % (
                SITE_NAME,))

```

- nginx配置文件所在目录: `/etc/nginx/sites-enabled/`
- supervisor配置所在目录: `/etc/supervisor/conf.d/`
- `run.sh`存放在项目的根目录下: `/data/www/SITENAME/run.sh`。

**说明：**
1. USERNAME替换成服务器的用户名(需要有sudo权限)
2. SITENAME替换成web项目域名
3. `sed`: (stream editor, 流编辑器)这里是linux自带的编辑文本流命令
4. `sed "s/replace/this/g"` 用this全局替换掉replace
5. `tee`: 标准输入复制到每个指定文件，并显示到标准输出
6. `|`: 是管道符，`sudo`: 是使用超级管理员权限。

用`fab deploy_settings`来运行任务，中途需要输入用户名密码。  
**然后:**   
- 重载nginx: `sudo service nginx reload`;  
- 重启supervisor: `sudo service supervisor restart`.

注意:
1. 这里使用的服务器系统是: debian和ubuntu;
2. 如果出错，注意查看日志信息;
3. 如果有问题，可以单独执行run.sh正常后，再复查supervisor的配置;
4. 项目的根目录是: `/data/www/SITENAME`。
