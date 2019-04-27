## channels容器pod实现web ssh

### App djsocket文件目录

```bash
# tree apps/djsocket 
apps/djsocket
├── __init__.py
├── admin.py
├── apps.py
├── consumers
│   ├── __init__.py
│   ├── podterminal.py
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
  
  from djsocket.consumers.podterminal import PodTerminalConsumer
  
  application = ProtocolTypeRouter({
      "websocket": AuthMiddlewareStack(
          URLRouter([
              url("websocket/podterminal", PodTerminalConsumer),
          ])
      )
  })
  ```

- `apps/djsocket/models.py`

  ```python
  from django.db import models
  
  # Create your models here.
  from account.models import User
  
  class Connection(models.Model):
      """
      SSH Operation Connection
      """
      user = models.ForeignKey(verbose_name="操作者", to=User)
      username = models.CharField(verbose_name="操作者(名字)", max_length=40)
      ip = models.GenericIPAddressField(verbose_name="连接IP", blank=True, null=True)
      # 主机可以是IP或者容器的Pod
      host = models.CharField(verbose_name="主机", max_length=100)
      history_count = models.IntegerField(verbose_name="日志条数", blank=True, null=True)
      time_start = models.DateTimeField(verbose_name="开始时间", auto_now_add=True, blank=True)
      time_end = models.DateTimeField(verbose_name="结束时间", blank=True, null=True)
  
      def get_history_by_order(self, order):
          history = self.history_set.filter(order=order).first()
          return history
  
      class Meta:
          verbose_name = "SSH连接"
          verbose_name_plural = verbose_name
  
  class History(models.Model):
      """
      SSH Operation History
      """
      connection = models.ForeignKey(verbose_name="连接", to=Connection, on_delete=models.CASCADE)
      # 在记录日志的时候,记得处理好日志的order
      order = models.IntegerField(verbose_name="序号", blank=True, default=1)
      content = models.CharField(verbose_name="日志内容", max_length=2048)
      # 计算上一次日志与这次日志的间隔秒数，日志回放的时候会用到它
      seconds = models.FloatField(verbose_name="间隔(秒)", blank=True)
      time_added = models.DateTimeField(verbose_name="添加时间", blank=True, auto_now_add=True)
  
      class Meta:
          unique_together = ("connection", "order")
          verbose_name = "连接操作日志"
          verbose_name_plural = verbose_name
  ```

  

- `apps/djsocket/consumers/podssh.py`

  ```python
  # -*- coding:utf-8 -*-
  """
  连接kubernetes pod
  注意事项：
  1. 只连接dev的
  2. 只超级管理员可以连接
  3. 日志记录
  """
  import time
  import datetime
  import threading
  
  from asgiref.sync import async_to_sync
  from kubernetes.stream import stream
  from kubernetes import client, config
  from channels.generic.websocket import AsyncWebsocketConsumer
  from django.db import close_old_connections
  
  from cloud.models.cloud import Cluster
  from djsocket.models.webssh import Connection, History
  
  
  class HandlerWriteMessageThread(threading.Thread):
      def __init__(self, consumer):
          threading.Thread.__init__(self)
          self.consumer = consumer
          self.history_conent = ""
  
      def run(self):
          order = 1
          prev_time = datetime.datetime.now()
  
          while self.consumer and self.consumer.k8s and self.consumer.k8s.sock.connected:
              # time.sleep(0.1)
              # print("循环接收消息")
              try:
                  data = self.consumer.k8s.read_stdout()
                  # print(data)
                  async_to_sync(self.consumer.channel_layer.group_send)(
                      # self.chan.scope['user'].username,
                      self.consumer.username,
                      {
                          "type": "user.message",
                          "text": data
                      },
                  )
                  # 判断回车，以及数据长度大于2的，记录一下
                  if data == '\r\n' or len(data) > 2:
                      now = datetime.datetime.now()
                      sub = now - prev_time
                      # print(sub.total_seconds(), sub.microseconds)
                      seconds = sub.total_seconds()
                      prev_time = now
                      self.history_conent += data
                      History.objects.create(connection=self.consumer.connection, order=order,
                                             seconds=seconds, time_added=now,
                                             content=self.history_conent)
                      # print(h)
                      order += 1
                      self.history_conent = ""
                  else:
                      self.history_conent += data
  
              except Exception as ex:
                  # print(str(ex))
                  time.sleep(0.1)
          return True
  
  
  def handler_query_string(query_string):
      if type(query_string) == bytes:
          query_string = str(query_string, encoding="utf-8")
      results = {}
      for item_i in query_string.split("&"):
          if item_i.index("=") > 0:
              kv = item_i.split("=")
              results[kv[0]] = kv[1]
  
      # get cluster,pod, container
      cluster = results.get("cluster", "default").strip()
      namespace = results.get("namespace", "default").strip()
      pod = results.get("pod", "").strip()
      container = results.get("container", "default").strip()
      return cluster, namespace, pod, container
  
  
  class PodTerminalConsumer(AsyncWebsocketConsumer):
      """
      Pod Terminal Consumer
      """
  
      async def connect(self):
          # 创建websocket时候调用
          # 第1步：判断客户端IP
          # 1-1： 获取client的ip
          user = None
          ip = self.scope["client"][0]
          # 1-2：指定开头的ip可以访问
          if not ip.startswith(("192.168.", "127.0.0")):
              return
  
          # 第2步：将新的连接加入到用户群组【通过redis工具可以查看到相关数据】
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
              # 第3步：建立容器的连接
              # 3-1：获取连接容器需要的信息，根据url params提取
              query_string = self.scope["query_string"]
              cluster_name, namespace, pod_name, container = handler_query_string(query_string)
  
              # 3-2: 对pod_name做过滤，正式环境的暂时不能操作
              if not (pod_name.find("dev-") > 0 or pod_name.find("test-") > 0
                      or pod_name.find("dbdm") > 0 or pod_name.find("dbtm") > 0):
                  return
  
              # 3-3：根据cluster获取kubernetes的配置文件
              config_path = None
              # 总会会自动断开MySQL的连接
              try:
                  Cluster.objects.first()
              except :
                  close_old_connections()
  
              if cluster_name == "default":
                  cluster = Cluster.objects.filter(is_default=True).first()
                  if cluster:
                      config_path = cluster.config_path
              else:
                  cluster = Cluster.objects.filter(name=cluster_name).first()
                  if cluster:
                      config_path = cluster.config_path
              # 如果配置文件为空，退出
              if not config_path:
                  return
  
              config.load_kube_config(config_file=config_path)
  
              api = client.CoreV1Api()
              # pod_name = "mystudydev-c5ddf4ff9-8d44k"
              # container = "nginx"
              # namespace = "default"
  
              field_selector = "metadata.name={}".format(pod_name)
              ret = api.list_namespaced_pod(namespace=namespace, field_selector=field_selector, limit=1)
  
              # 3-4：获取pod对象的容器，如果是default就采用第一个container
              if container == "default":
                  pod_instance = None
                  for i in ret.items:
                      # print("%s  %s  %s" % (i.status.pod_ip, i.metadata.namespace, i.metadata.name))
                      pod_instance = i
                      break
                  if pod_instance:
                      container = pod_instance.spec._containers[0]._name
                      # print(pod_instance, pod_instance.spec._containers)
  
              # 第4步: 发起执行命令了
              command = [
                  "/bin/sh",
                  "-c",
                  'TERM=xterm-256color; export TERM; [ -x /bin/bash ] '
                  '&& ([ -x /usr/bin/script ] '
                  '&& /usr/bin/script -q -c "/bin/bash" /dev/null || exec /bin/bash) '
                  '|| exec /bin/sh'
              ]
  
              k8s = stream(
                  api.connect_get_namespaced_pod_exec,
                  name=pod_name,
                  namespace=namespace,
                  container=container,
                  command=command,
                  stdin=True,
                  stdout=True,
                  stderr=True,
                  tty=True,
                  _preload_content=False
              )
              self.k8s = k8s
              # print("k8s:", k8s)
  
              # 第5步：记录日志之：记录连接
              time_start = datetime.datetime.now()
              connection = Connection.objects.create(user=user, username=self.username, host=pod_name,
                                                     ip=ip, time_start=time_start)
              self.connection = connection
  
              # 第6步：启动处理输出信息的线程
              t = HandlerWriteMessageThread(self)
              t.setDaemon(True)
              t.start()
              # print(t)
  
              # await asyncio.wait([self.write_message()])
          except Exception as e:
              print(e)
              return
  
          # 最后：接受连接
          await self.accept()
          await self.channel_layer.group_add(self.username, self.channel_name)
  
      async def disconnect(self, code):
          # 连接关闭时候调用
          # 将关闭的连接从群组中移除
          username = self.username
          self.channel_layer.group_discard(username, self.channel_name)
          try:
              if hasattr(self, "k8s"):
                  self.k8s.close()
              # pass
              # 设置connection的结束时间
              now = datetime.datetime.now()
              history_count = self.connection.history_set.count()
              history_last = self.connection.history_set.last()
              if history_last:
                  now = history_last.time_added
              self.connection.time_end = now
              self.connection.history_count = history_count
              self.connection.save()
  
          except Exception as e:
              print("disconnect exception:", str(e))
  
      async def receive(self, text_data=None, bytes_data=None):
          # 收到信息时候调用
          # 信息单独发送
          try:
              if self.k8s.sock.connected:
                  self.k8s.write_stdin(text_data)
          except Exception as ex:
              print("write stdin error:", ex)
              # print(str(ex))
  
      async def user_message(self, event):
          # 处理user.message事件
          await self.send(text_data=event["text"])
  
  ```

- 文件：`views/index.py`

  ```python
  def podterminal(request):
      # 判断IP
      ip = ""
      try:
          ip = request.META['HTTP_X_REAL_IP']
      except KeyError:
          if settings.DEBUG:
              ip = request.META["REMOTE_ADDR"]
  
      # print(ip)
      if not ip.startswith(("192.168.", "127.0.0")):
          content = {
              "message": "当前IP({})不可连接容器".format(ip)
          }
          return render(request, '403.html', content)
  
      user = request.user
      pod = request.GET.get("pod", "")
      cluster = request.GET.get("cluster", "default")
      container = request.GET.get("container", "")
      message = "连接（{}）中。。。。。。".format(pod)
      if not (pod.find("dev-") > 0 or pod.find("test-") > 0):
          message = "不可连接非dev/test环境的容器,当前尝试连接的pod是：{}".format(pod)
      if user.is_superuser:
          content = {
              "pod": pod,
              "cluster": cluster,
              "container": container,
              "message": message
          }
          return render(request, "webterminal.html", content)
      else:
          content = {
              "message": "当前用户{}不可连接容器".format(user)
          }
          return render(request, '403.html', content)
  ```

### 前端文件webterminal.html

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
    <div id="message">"{{ message }}"</div>
</body>

<script src="/static/xterm/xterm.js"></script>
<script src="/static/xterm/addons/fullscreen/fullscreen.js"></script>
<script>

    var protocol = document.location.protocol;
    var host = document.domain;
    var port = document.location.port;
    var socketUrl;
    {# URL需要携带cluster, pod, container信息#}
    var params = "pod={{ pod }}&container={{ container }}&cluster={{ cluster }}"
    if(protocol === "http:"){
        socketUrl = "ws://" + host + ":" + port + "/websocket/podterminal?" + params;
    }else{
        socketUrl = "wss://" + host + ":" + port + "/websocket/podterminal?" + params;
    }
    var socket = new WebSocket(socketUrl);
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
            {#console.log(e);#}
            term.destroy();
            var messageElement = document.getElementById("message");
            messageElement.textContent = "已经关闭 {{ pod }} 的连接!";
        };
    };

    closeElement.addEventListener("click", function () {
        socket.close();

    })

</script>
</html>
```

