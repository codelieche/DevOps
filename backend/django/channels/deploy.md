## Dango Channels Deploy



### asgi.py

- 文件：`project/asgi.py` 与`project/settings.py`目录同级别

  ```python
  # -*- coding:utf-8 -*-
  import os
  import django
  # from channels.asgi import get_channel_layer
  from channels.routing import get_default_application
  
  os.environ.setdefault("DJANGO_SETTINGS_MODULE", "codelieche.settings")
  django.setup()
  
  # channel_layer = get_channel_layer()
  application = get_default_application()
  ```

### settings.py

```python
# Django Web Socket相关配置
ASGI_APPLICATION = "djsocket.routing.application"

# 设置消息队列，redis
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": [("127.0.0.1", 6379)],
        }
    }
}
```

### 启动服务

```bash
#!/bin/bash

cd /data/www/
source ./virtualenv36/bin/activate
cd ./source

# daphne -b 0.0.0.0 -p 8085 codelieche.asgi:application
daphne -b 127.0.0.1 -p 8085 codelieche.asgi:application
```



### nginx配置

```
server {
    listen       80;
    server_name  mysite.com;
    rewrite ^(.*)$  https://$host$1 permanent;

    location / {
        proxy_pass http://unix:/tmp/mysite.com.socket;
        # proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header REMOTE_ADDR $remote_addr;
    }

    location /websocket/ {
        # proxy_pass http://unix:/tmp/daphne.socket;
        proxy_pass http://127.0.0.1:8085/websocket/;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_redirect     off;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;
    }

    location /robots.txt {
        alias /data/www/mysite.com/static/robots.txt;
    }

    location /favicon.ico {
        alias /data/www/mysite.com/static/favicon.ico;
    }

    location ~ ^/(media|static)/ {
        root /data/www/mysite.com;
        expires 30d;
    }
    location ~ /\. {
        access_log off; log_not_found off; deny all;
    }
}
```

