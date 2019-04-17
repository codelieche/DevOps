## channels的基本使用

### App djsocket文件目录

```bash
# tree apps/djsocket 
apps/djsocket
├── __init__.py
├── admin.py
├── apps.py
├── consumers
│   ├── __init__.py
│   ├── message.py
│   ├── paramiko.py
├── migrations
│   └── __init__.py
├── models.py
├── routing.py
├── tasks
│   └── __init__.py
├── tests.py
├── urls
│   ├── __init__.py
│   └── main.py
└── views
    ├── __init__.py
    └── index.py
```



### 配置文件：settings.py

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

### 文件代码

- `apps/djsocket/routing.py`

  ```python
  # -*- coding:utf-8 -*-
  from django.conf.urls import url
  from channels.routing import ProtocolTypeRouter, URLRouter
  from channels.auth import AuthMiddlewareStack
  
  from djsocket.consumers.message import MessageConsumer
  from djsocket.consumers.paramiko import ParamikoConsumer
  
  application = ProtocolTypeRouter({
      "websocket": AuthMiddlewareStack(
          URLRouter([
              url("^message/?$", MessageConsumer),
              url("paramiko", ParamikoConsumer),
          ])
      )
  })
  ```

- `apps/djsocket/consumers/message.py`

  ```python
  # -*- coding:utf-8 -*-
  import datetime
  
  from channels.generic.websocket import AsyncWebsocketConsumer
  
  
  class MessageConsumer(AsyncWebsocketConsumer):
      """
      用户消息WebSocket Consumer
      """
      async def connect(self):
          # 创建websocket时候调用
          # 将新的连接加入到用户群组
          if not self.scope["user"].is_authenticated:
              self.username = "anonymous"
              # return
          else:
              username = self.scope["user"].username
              self.username = username
          await self.accept()
          await self.channel_layer.group_add(self.username, self.channel_name)
  
      async def disconnect(self, code):
          # 连接关闭时候调用
          # 将关闭的连接从群组中移除
          # username = self.scope["user"].username
          username = self.username
          await self.channel_layer.group_discard(username, self.channel_name)
  
      async def receive(self, text_data=None, bytes_data=None):
          # 收到信息时候调用
          # 信息单独发送
  
          # 信息群发，群组里的连接都可看到
          # username = self.scope["user"].username
          username = self.username
          # print("username:", username)
          # print("self.username", self.username)
          await self.channel_layer.group_send(
              username,
              {
                  "type": "user.message",
                  "text": text_data,
              }
          )
  
      async def user_message(self, event):
          # 处理user.message事件
          now = datetime.datetime.now().strftime("%F %T")
          message = "{}收到消息：{}".format(now, event["text"])
          await self.send(text_data=event["text"])
          await self.send(text_data=message)
  ```


