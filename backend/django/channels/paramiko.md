## channels使用paramiko实现web ssh

### App djsocket文件目录

```bash
# tree apps/djsocket 
apps/djsocket
├── __init__.py
├── admin.py
├── apps.py
├── consumers
│   ├── __init__.py
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
  
  from djsocket.consumers.paramiko import ParamikoConsumer
  
  application = ProtocolTypeRouter({
      "websocket": AuthMiddlewareStack(
          URLRouter([
              url("paramiko", ParamikoConsumer),
          ])
      )
  })
  ```

- `apps/djsocket/consumers/paramiko.py`

  ```python
  # -*- coding:utf-8 -*-
  """"
  通过paramicko连接主机
  Websocket传输数据
  """
  import threading
  import time
  
  from asgiref.sync import async_to_sync
  
  import paramiko
  from channels.generic.websocket import AsyncWebsocketConsumer
  
  
  class HandlerWriteMessageThread(threading.Thread):
      def __init__(self, id, consumer):
          threading.Thread.__init__(self)
          self.consumer = consumer
  
      def run(self):
          while not self.consumer.chan.exit_status_ready():
              # time.sleep(0.1)
              try:
                  data = self.consumer.chan.recv(1024)
                  # print(data)
                  async_to_sync(self.consumer.channel_layer.group_send)(
                      # self.chan.scope['user'].username,
                      self.consumer.username,
                      {
                          "type": "user.message",
                          "text": bytes.decode(data)
                      },
                  )
              except Exception as ex:
                  # print(str(ex))
                  time.sleep(0.1)
          self.consumer.ssh_client.close()
          return False
  
  
  class ParamikoConsumer(AsyncWebsocketConsumer):
      """
      Paramiko Consumer
      """
  
      async def connect(self):
          # 创建websocket时候调用
          # 判断ip
          ip = self.scope["client"][0]
          if not ip.startswith(("192.168.", "127.0.0")):
              return
  
          # 将新的连接加入到用户群组
          if not self.scope["user"].is_authenticated:
              self.username = "anonymous"
              return
          else:
              user = self.scope["user"]
              # 只有超级用户才可以连接
              if not user.is_superuser:
                  return False
              self.username = user.username
          try:
              # 连接
              ssh_client = paramiko.SSHClient()
              ssh_client.set_missing_host_key_policy(policy=paramiko.AutoAddPolicy())
  
              ssh_client.connect(hostname="192.168.1.123", username="root",
                                 password="password", timeout=10)
              self.ssh_client = ssh_client
  
              self.chan = self.ssh_client.invoke_shell(term="xterm")
              self.chan.settimeout(10)
              t = HandlerWriteMessageThread(999, self)
              t.setDaemon(True)
              t.start()
          except Exception as e:
              print(e)
              return
  
          # 接受连接
          await self.accept()
          await self.channel_layer.group_add(self.username, self.channel_name)
  
          # self.i = 0
  
      async def disconnect(self, code):
          # 连接关闭时候调用
          # 将关闭的连接从群组中移除
          username = self.username
          self.channel_layer.group_discard(username, self.channel_name)
          try:
              self.chan.close()
          except Exception as e:
              print(e)
  
      async def receive(self, text_data=None, bytes_data=None):
          # 收到信息时候调用
          # 信息单独发送
  
          # if text_data == "1":
          #     pass
          # else:
          #     pass
          try:
              # print(text_data)
              if not self.chan.closed:
                  self.chan.send(text_data)
          except Exception as ex:
              print(str(ex))
  
          # # 信息群发，群组里的连接都可看到
          # username = self.username
          # await self.channel_layer.group_send(
          #     username,
          #     {
          #         "type": "user.message",
          #         "text": text_data
          #     }
          # )
  
      async def user_message(self, event):
          # 处理user.message事件
          await self.send(text_data=event["text"])
          # self.i += 1
          # await self.send(text_data=str(self.i))
          # if self.i == 10:
          #     self.chan.close()
  
  ```

- 文件：`views/index.py`

  ```python
  # -*- coding:utf-8 -*-
  from django.shortcuts import render
  from django.http.response import HttpResponse
  
  
  def paramamiko_socket(request):
      # 判断IP
      ip = request.META["REMOTE_ADDR"]
      # print(ip)
      if not ip.startswith(("192.168.", "127.0.0")):
          return render(request, '403.html')
  
      user = request.user
      if user.is_superuser:
          return render(request, "websocket.html")
      else:
          return render(request, '403.html')
      return HttpResponse(status=403)
  ```

### 前端文件websocket.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>django websocket</title>

    <link href="/static/xterm/xterm.css" rel="stylesheet" type="text/css"/>
    <link href="/static/xterm/addons/fullscreen/fullscreen.css" rel="stylesheet" type="text/css"/>
    <style>
        body {
            padding: 0;
        }
        .terminal {
            border: #000000 solid 5px;
            height: 100%;
        }
        #close{
            color: #666;
            font-weight: 400;
            background-color: #fff;
            {#width: 100px;#}
            {#height: 50px;#}
            position: absolute;
            right: 50px;
            top: 10px;
            z-index: 999;
            border-radius: 10px;
            padding: 5px 15px;
            cursor: pointer;
            border: 1px solid #999999;
        }
        #message {
            padding: 100px;
            margin: auto;
            height: 100%;
            text-align: center;
            color: #999;
            font-size: 16px;
        }

    </style>
</head>
<body>
    <div id="xterm"></div>
    <div id="close">Close</div>
    <div id="message">连接中</div>
</body>

<script src="/static/xterm/xterm.js"></script>
<script src="/static/xterm/addons/fullscreen/fullscreen.js"></script>
<script>
    var protocol = document.location.protocol;
    var host = document.domain;
    var port = document.location.port;
    var socketUrl;
    if(protocol === "http:"){
        socketUrl = "ws://" + host + ":" + port + "/paramiko";
    }else{
        socketUrl = "wss://" + host + ":" + port + "/paramiko";
    }
    var socket = new WebSocket(socketUrl);
    {#var socket = new WebSocket('ws://127.0.0.1:8080/podterminal');#}
    var xtermElement = document.getElementById('xterm');
    var closeElement = document.getElementById("close");

    socket.onopen = function () {
        Terminal.applyAddon(fullscreen)
        var term = new Terminal({
            cols: 120,
            rows: 50,
            cursorBlink: 5,
            scrollback: 100,
            tabStopWidth: 4
        });
        term.open(xtermElement);

        term.toggleFullScreen(true);

        term.on('data', function (data) {
            socket.send(data);
        });

        socket.onmessage = function (msg) {
            term.write(msg.data);

        };

        socket.onerror = function (e) {
            {#console.log(e);#}
        };

        socket.onclose = function (e) {
            term.destroy();
            var messageElement = document.getElementById("message");
            messageElement.textContent = "已经关闭连接!";
        };
    };

    closeElement.addEventListener("click", function () {
        socket.close();
    });

</script>
</html>
```

