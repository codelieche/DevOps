### Generics

#### Concrete View Classes
- ListAPIView
- CreateAPIView
- RetrieveAPIView
- RetrieveUpdateDestoryAPIView

##### 使用示例
文件位置：`apps/asset/views/asset.py`  
先创建`HostSerializer`, 权限控制：`IsSuperUser`,`IsSuperUserOrReadyOnly`类，然后引入。

**1. Serializer**

```python
class HostSerializer(serializers.ModelSerializer):
    """Host Serializer Model"""
    # category = CategorySerializer(many=False, read_only=True)
    group = GroupSerializer(many=True, read_only=True)

    class Meta:
        model = Host
        fields = '__all__'
```

**2. View**

```python
class HostList(generics.ListAPIView):
    """host list view"""
    queryset = Host.objects.all()
    serializer_class = HostSerializer

class HostListAll(generics.ListAPIView):
    """host list all view"""
    queryset = Host.objects.all()
    serializer_class = HostSerializer
    # 不使用分页
    pagination_class = None

class HostCreate(generics.CreateAPIView):
    """Host Create view"""
    queryset = Host.objects.all()
    serializer_class = HostSerializer
    # 权限控制
    permission_classes = (IsSuperUser,)

class HostDetail(generics.RetrieveUpdateDestroyAPIView):
    """Host detail view"""
    queryset = Host.objects.all()
    serializer_class = HostSerializer
    # 权限控制
    permission_classes = (IsSuperUserOrReadyOnly,)
```

**3. urls**
文件位置：`apps/asset/urls/asset.py`

```python
from django.conf.urls import url
from rest_framework.urlpatterns import format_suffix_patterns

from asset.views import asset

urlpatterns = [
    # host相关url
    url(r'host/list/?$', asset.HostList.as_view(), name='host_list'),
    url(r'^host/all/?$', asset.HostListAll.as_view(), name='host_all'),
    url(r'^host/create/?$', asset.HostCreate.as_view(), name='host_create'),
    url(r'^host/(?P<pk>\d+)/?$', asset.HostDetail.as_view(), name='host_detail'),
]

urlpatterns = format_suffix_patterns(urlpatterns)
```




#### get_queryset
> 当我们使用`generics.ListAPIView`的时候，试图对象会先调用`get_queryset`来获取`QuerySet`对象，然后再返回序列化后的数据。

比如：我们现在想获取主机的修改记录。
1. 我们先要获取到`Host`对象
2. 然后根据host对象获取到对应的HostHistory

**1. 编写serializer**

```python
class HostHistorySerializer(serializers.ModelSerializer):
    """Host history Serializer Model"""

    class Meta:
        model = HostHistory
        fields = ('id', 'user', 'host', 'content')

    def create(self, validated_data):
        # 创建history的时候，需要传入request.user
        history = HostHistory(user=self.context['request'].user, **validated_data)
        history.save()
        return history
```

**2. 编写View**

```python
class DisplayHostHistory(generics.ListAPIView):
    """通过host的id获取HostHistory的列表"""
    serializer_class = HostHistorySerializer
    # 这个默认是带了分页功能的，结果在返回的json的results字段中

    def get_queryset(self):
        # 先获取到
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
        # print(self.kwargs) # {'pk': '2'}
        filter_kwargs = {lookup_url_kwarg: self.kwargs.get(lookup_url_kwarg, None)}
        # 得到值后先获取到Host，然后再是获取HostHistory的列表
        host = get_object_or_404(Host, **filter_kwargs)
        return host.hosthistory_set.all()
```
> 一般我们编写ListAPIView的子类，会设置queryset。这里我们没设置，而是覆写了`get_queryset`方法。

**3. url**

```
url(r'^host/(?P<pk>\d+)/history/?$', asset.DisplayHostHistory.as_view(), name='host_history')
```

**4. 说明**
- `self.kwargs`：会返回url中设置的参数名称和值
- `self.lookup_field`：过滤field名
- `get_queryset`返回的结果是个序列化对象


#### 参考文档：
- [generic-view](http://www.django-rest-framework.org/api-guide/generic-views/)