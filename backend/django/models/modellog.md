## 自定义Model日志记录模块
> django admin中有 LogEntry记录了，管理后台对数据操作的行为。  
如果用它的来记录，自定义有点不方便，所以参考`django.contrib.admin.models.LogEntry`自己编写了个日志模块。


## modellog app

### 文件说明：
- `models.py`: 定义了日志Model，LogsEntry
- `mixins.py`: 编写了rest_framework的ViewSet中间件`LoggingViewSetMixin`
- `serializers.py`: 定义了LogsEntrySerializer
- `views.py`: 获取model的日志，或者获取某个对象的操作日志
    1. `LogsEntryDetailApiView`: 获取LogsEntry的详情
    2. `ModelLogsEntryListAPIView`: 获取某个模块的所有操作日志
    3. `ObjectLogsListDetailApiView`: 某个app的某个model的具体对象的操作日志
    
- `urls.py`: 配置了路由，可以用`include('modellog.urls', namespace='modellog')`

### LogsEntry
文件位置：`apps/modellog/models.py`

```python
import json

from django.db import models
from django.contrib.contenttypes.models import ContentType
from django.utils.encoding import python_2_unicode_compatible, force_text
from django.contrib.auth import get_user_model
from django.utils import timezone
# from django.contrib.admin.models import LogEntry
# 获取到用户的Model，有可能是自定义的User，也可能是Django自带的User
User = get_user_model()

class LogsEntryManager(models.Manager):
    """
    日志管理器
    Django自带了LogEntry
    """

    def log_action(self, user_id, content_type_id, object_id, object_repr, action_flag,
                   message=''):
        """
        添加日志
        :param user_id: 用户的ID
        :param content_type_id: 模型内容的id
        :param object_id: 对象的id
        :param object_repr: 对象 __repr__返回值或者 __str__
        :param action_flag: 操作标志
        :param message: 消息内容，默认为空
        :return:
        """

        if isinstance(message, list):
            message = json.dumps(message)
        self.model.objects.create(
            user_id=user_id,
            content_type_id=content_type_id,
            object_id=object_id,
            object_repr=object_repr,
            action_flag=action_flag,
            message=message
        )

    def get_actions(self, user=None, action_flag=None, content_type=None, object_id=None):
        """
        获取用户的操作日志
        :param user: 用户
        :param action_flag: 操作标志：1.增加；2.修改；3.删除
        :param content_type: 模型的content_type
        :param object_id:
        :return:
        """
        if user or action_flag or content_type or object_id:
            fields_all = {'user': user, 'action_flag': action_flag,
                          'content_type': content_type, 'object_id': object_id}
            fields = {}
            for field in fields_all:
                if fields_all[field]:
                    fields[field] = fields_all[field]

            return self.filter(**fields)
        else:
            return []


@python_2_unicode_compatible
class LogsEntry(models.Model):
    """
    模型的日志
    为了跟django.contrib.admin.models.LogEntry区分，就加个s
    如果不加s，还需要制定几个related_name
    """
    ACTION_FLAG_CHOICES = (
        (1, '添加'),
        (2, '修改'),
        (3, '删除')
    )
    time_added = models.DateTimeField(verbose_name="添加时间", default=timezone.now, editable=False)
    user = models.ForeignKey(to=User, on_delete=models.CASCADE, verbose_name="用户")
    # 当模型对象被删除了，日志这个字段就设置为空，所以当前字段需要允许为null
    content_type = models.ForeignKey(to=ContentType, on_delete=models.SET_NULL,
                                     verbose_name="Content Type", blank=True, null=True)
    object_id = models.IntegerField(verbose_name="对象ID")
    object_repr = models.CharField(verbose_name="对象", max_length=200)
    # 操作标志：
    action_flag = models.PositiveSmallIntegerField(verbose_name="操作标志",
                                                   choices=ACTION_FLAG_CHOICES)
    message = models.TextField(verbose_name="变更消息", blank=True)

    # 使用自定义的管理器
    objects = LogsEntryManager()

    class Meta:
        verbose_name = "Model日志"
        verbose_name_plural = verbose_name
        ordering = ('-time_added', )

    def __repr__(self):
        return force_text(self.time_added)

    def __str__(self):
        return force_text(self.time_added)

    def get_edited_object(self):
        """
        返回日志对象
        """
        return self.content_type.get_object_for_this_type(pk=self.object_id)

    def get_message(self):
        message = self.message
        if message and message.startswith(('[', '{')):
            try:
                message = json.loads(message)
                return message
            except Exception:
                return message
        else:
            return message
```

### LogsEntrySerializer
文件位置：`apps/modellog/serializers.py`

```python
from rest_framework import serializers

from .models import LogsEntry


class LogsEntrySerializer(serializers.ModelSerializer):
    """模块日志 序列化模型"""
    user = serializers.CharField(source='user.username', read_only=True)
    action = serializers.CharField(source='get_action_flag_display', read_only=True)
    message = serializers.SerializerMethodField()

    def get_message(self, obj):
        return obj.get_message()

    class Meta:
        model = LogsEntry
        fields = ('id', 'user', 'action_flag', 'action', 'object_id', 'time_added', 'message')
```

### ObjectLogsListAPIView
文件位置：`apps/modellog/views.py`

```python
from django.shortcuts import get_object_or_404
from django.contrib.contenttypes.models import ContentType
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated

from .models import LogsEntry
from .serializers import LogsEntrySerializer

class ObjectLogsListApiView(generics.ListAPIView):
    """
    获取model某个对象的历史记录列表
    """
    serializer_class = LogsEntrySerializer
    # 权限控制
    permission_classes = (IsAuthenticated,)

    def get_queryset(self):
        # 第1步：先获取到app和model的字符串，pk
        app = self.kwargs['app']
        model = self.kwargs['model']
        pk = self.kwargs['pk']

        # 第2步：获取到Model的content_type
        content_type = get_object_or_404(ContentType, app_label=app, model=model)

        # 第3步：获取数据
        objects_list = LogsEntry.objects.filter(content_type=content_type,
                                                object_id=pk).order_by('-time_added')

        # 第4步：返回数据
        return objects_list

    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
```

### urls.py
文件位置：`apps/modellog/urls.py`

```python
from django.conf.urls import url
from .views import ModelLogsEntryListAPIView, ObjectLogsListDetailApiView, LogsEntryDetailApiView

urlpatterns = [
    # 日志详情
    url(r'^(?P<pk>\d+)/?$', LogsEntryDetailApiView.as_view(), name='detail'),
    # 模块日志列表
    url(r'^(?P<app>\w+)/(?P<model>\w+)/list/?$',
        ModelLogsEntryListAPIView.as_view(), name="model_logs_list"),
    # 模块中某个对象的日志列表
    url(r'^(?P<app>\w+)/(?P<model>\w+)/(?P<pk>\d+)/list/?$',
        ObjectLogsListDetailApiView.as_view(), name='object_logs_list'),
]
```