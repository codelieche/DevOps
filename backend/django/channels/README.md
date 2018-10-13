## Djiago Channels



#### 参考文档

- [Django Channels Docs](https://channels.readthedocs.io/en/latest/)

#### 安装

- 安装channels

```
pip install channels
```

把channels写到django项目的settings.py的`INSTALL_APPS`中。

- 安装channels_redis

```
pip install channels_redis
```

配置：

```python
# Django WebSocket相关配置
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



