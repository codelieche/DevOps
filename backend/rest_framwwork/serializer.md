## Serializer

### 简单示例
> 以DNS模型为例：

**1. 创建Django Model**

```python
@python_2_unicode_compatible
class DNS(models.Model):
    """
    域名解析
    如果IP是内网ip就是内网解析，如果ip是外网的，还需要在DNS服务器上修改解析
    """
    domain = models.ForeignKey(to=Domain, verbose_name="域名")
    ip = models.ForeignKey(to=IP, verbose_name="IP")
    description = models.CharField(max_length=128, verbose_name="备注", blank=True, null=True)

    def __str__(self):
        return "DNS:{}".format(self.domain.name)

    class Meta:
        verbose_name = 'DNS'
        verbose_name_plural = verbose_name
```
**2. 编写Serializer**

```python
from rest_framework import serializers

from asset.models import DNS

class DNSSerializer(serializers.ModelSerializer):
    """DNS serializer Model"""

    class Meta:
        model = DNS
        fields = ('id', 'domain', 'ip', 'description')
```

**3. 在views中运用**
> 文件：`apps/asset/views/asset.py`

```python
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated, IsAdminUser

from asset.models import DNS
from asset.serializers.asset import DNSSerializer

class DNSList(generics.ListAPIView):
    """DNS list view"""
    queryset = DNS.objects.all()
    serializer_class = DNSSerializer


class DNSListAll(generics.ListAPIView):
    """DNS list all view"""
    queryset = DNS.objects.all()
    serializer_class = DNSSerializer
    # 不使用分页，列出所有
    pagination_class = None
    permission_class = (IsAuthenticated,)


class DNSCreate(generics.CreateAPIView):
    """DNS create view"""
    queryset = DNS.objects.all()
    serializer_class = DNSSerializer
    # 权限控制
    permission_classes = (IsAdminUser,)


class DNSDetail(generics.RetrieveUpdateDestroyAPIView):
    """DNS detail update delete view"""
    queryset = DNS.objects.all()
    serializer_class = DNSSerializer
    # 权限控制
    permission_classes = (IsAdminUser,)
```

### Serializer Fields

#### DatetimeField
```
DateTimeField(format=api_settings.DATETIME_FORMAT, input_formats=None)
```
Datetime字段默认返回的格式是：`2017-08-04T02:55:50.766734Z`,我们可以通过传递`format`参数对时间进行格式化。eg:`iso-8601`,`%Y-%m-%d %H:%M:%S`.  
时间的格式：也可以在`settings.py`中设置`REST_FRAMEWORK`的`DATETIME_FORMAT`。

```python
class DocumentSerializer(serializers.ModelSerializer):
    """
    文档 ModelSerializer
    """
    file = serializers.FileField(max_length=None, use_url=True)
    user = serializers.SlugRelatedField(many=False, read_only=True, slug_field='username')
    # 设置时间格式，可以指定format，也可以在settings.py中设置DEFATUL_FORMAT
    time_added = serializers.DateTimeField(format="%Y-%m-%d %H:%M:%S")

    class Meta:
        model = Document
        fields = ('id', 'user', 'filename', 'file', 'time_added')
```

##### 把UTC时间转成北京时间
> Django中如果设置`TIME_ZONE = 'Asia/Shanghai'`而数据库中的时间保存成UTC的时间(`USE_TZ = True`)。  
如果用Django自带的模板渲染时间的时候，会显示成设置的时区的时间。  
比如：数据库中保存的是`02:00`，而django模板会渲染成`10:00`.而如果`django rest framwork`中也想这样，需要拓展一下`DatetimeField`.

```python
from rest_framework import serializers
from django.utils import timezone
import pytz

class DateTimeLocalField(serializers.DateTimeField):
    """
    本地化时区时间
    """
    def to_representation(self, value):
        value = timezone.localtime(value, pytz.timezone('Asia/Shanghai'))
        return super(DateTimeLocalField, self).to_representation(value)


class DocumentSerializer(serializers.ModelSerializer):
    """
    文档 ModelSerializer
    """
    file = serializers.FileField(max_length=None, use_url=True)
    user = serializers.SlugRelatedField(many=False, read_only=True, slug_field='username')
    # 设置时间格式，可以指定format，也可以在settings.py中设置DEFATUL_FORMAT
    # time_added = serializers.DateTimeField(format="%Y-%m-%d %H:%M:%S")
    time_added = DateTimeLocalField()

    class Meta:
        model = Document
        fields = ('id', 'user', 'filename', 'file', 'time_added')
```

如果对`DateTimeLocalField`没设置format,会显示成：`2017-08-04T10:55:50.766734+08:00`这种格式的时间。  
传递`format`参数`format="%Y-%m-%d %H:%M:%S"`，时间就是：`2017-08-04 10:55:50`了。


### 数据校验及获取request过来的数据
> 比如我们上传Document,上传的user，我想设置为`request.user`，同时，还想如果`filename`为空，机会设置成`request`传过来的`file`的名字。

```python
class DocumentCreateSerializer(serializers.ModelSerializer):
    """
    上传文档 ModelSerializer
    """
    file = serializers.FileField(max_length=None, use_url=True)

    class Meta:
        model = Document
        fields = ('id', 'user', 'filename', 'file')

    def validate(self, attrs):
        # 数据验证前，设置当前user为Document的用户
        request = self.context['request']
        user = request.user
        attrs['user'] = user
        if 'filename' not in attrs:
            attrs['filename'] = request.data.get('file')
        return attrs
```

**注意：**其中重点就是`self.context['request']`可以获取到`request`。  
另外如果想校验某个字段，可以编写`validate_fieldname`函数来处理。  
如果传递的数据有误，可以抛出`serializers.ValidationError`错误：`raise serializers.ValidationError("字段不合法")`。

