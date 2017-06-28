## rest\_framework简单使用

> 我们创建一个资产分组Group，然后为Group创建REST full API。
>
> 我们首先创建asset app，且app都放在项目根目录下的apps中。

### 1. 创建Model

文件位置：`apps/asset/models/asset.py`，在`models\__init__.py`文件中要导入Group\(`from .asset import Group`\).

```python
from django.db import models
from django.utils.encoding import python_2_unicode_compatible

@python_2_unicode_compatible
class Group(models.Model):
    """资产组Model"""
    name = models.CharField(verbose_name="资产组", max_length=40)
    parent = models.ForeignKey(to='self', null=True, blank=True, verbose_name="上级分组")
    description = models.CharField(verbose_name="描述", max_length=256, blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "资产组"
        verbose_name_plural = verbose_name
```

### 2. 创建ModelSerializer

文件位置：`apps/asset/serializers/asset.py`

```python
from rest_framework import serializers

from asset.models import Group

class GroupSerializer(serializers.ModelSerializer):
    """Group Serializer Model"""

    class Meta:
        model = Group
        fields = ('id', 'name', 'parent', 'description')
```

### 3. 创建APIView

文件位置：`apps/asset/views/asset.py`

```python
from rest_framework import generics

from asset.models import Group
from asset.serializers.asset import GroupSerializer

class GroupList(generics.ListAPIView):
    """
    Group 列表 api
    """
    queryset = Group.objects.all()
    serializer_class = GroupSerializer


class GroupCreate(generics.CreateAPIView):
    """创建Group"""
    queryset = Group.objects.all()
    serializer_class = GroupSerializer


class GroupDetail(generics.RetrieveUpdateDestroyAPIView):
    """Group 详情相关的View"""
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
```

### 4. 编写urls

文件位置：`apps/asset/urls/asset.py`

```python
from django.conf.url import url
from rest_framework.urlpatterns import format_suffix_patterns

from asset.views.asset import GroupList, GroupCreate, GroupDetail

urlpatterns = [
   # get：group list page
    url(r'^group/list$', GroupList.as_view(), name='group_list'),
    # post: group add page
    url(r'^group/create$', GroupCreate.as_view(), name='group_create'),
    # group detail
    url(r'^group/(?P<pk>[0-9]+)/?$', GroupDetail.as_view(), name='group_detail')
]

urlpatterns = format_suffix_patterns(urlpatterns)
```

然后我们在项目跟urls中把这个url添加进去：

```python
url('^api/1.0/asset', include('asset.urls.asset', namespace='asset')
```

### 5. 使用

#### 创建Group

* url: \`[http://127.0.0.1:8080/api/1.0/asset/group/create\`](http://127.0.0.1:8080/api/1.0/asset/group/create`)
* 参数：
  * `name`: 分组名称
  * `parent`: 上级分组，可以为空
  * `description`: 组描述

### list:

`curl http://127.0.0.1:8080/api/1.0/asset/group/list?page=1&page_size=5`

返回结果：

```json

{
    "count": 35,
    "next": "http://127.0.0.1:8080/api/1.0/asset/group/list?page=2&page_size=5",
    "previous": null,
    "results": [
        {
            "id": 1,
            "name": "阿里云",
            "parent": null,
            "description": "阿里云服务器"
        },
        {
            "id": 2,
            "name": "阿里云-华南区",
            "parent": 1,
            "description": "阿里云服务器"
        },
        {
            "id": 3,
            "name": "阿里云-华东区",
            "parent": 1,
            "description": "阿里云服务器"
        },
        {
            "id": 4,
            "name": "阿里云-华北区",
            "parent": 1,
            "description": "阿里云服务器"
        },
        {
            "id": 5,
            "name": "阿里云-华北区",
            "parent": 1,
            "description": "阿里云服务器"
        }
    ]
}
```

**注意**

1. 这个是添加了分页功能的效果
2. url后面的`?page=2&page_size=5`不要，默认是每页返回10个，如果不加分页器，会返回全部
3. 关于paginations请查看分页相关的章节

#### Detail

> 详情页面get方法是查看，put是更新，delete是删除。

url: `http://127.0.0.1:8080/api/1.0/asset/group/2/`

返回结果：

```json

{
    "id": 2,
    "name": "阿里云-华南区",
    "parent": 1,
    "description": "阿里云服务器"
}
```



