### Rest FrameWork Pagination

> 当我们获取列表页的时候，一般不需要返回全部的数据，而是一次返回10条。  
> 这个时候就需要用到分页器\(Pagination\).

### 1. 简单使用（LimitOffsetPagination）

> 我们查询项目的ID、Name一次查询10条数据。  
> 第一页：SELECT id, name FROM tproject\_project LIMIT 10;  
> 第二页：SELECT id, name FROM tproject\_project LIMIT 10 OFFSET 10;  
> 设置了LIMIT和OFFSET就能满足SQL查询分页的功能了。

在Django Rest FrameWork中，有个默认的类：`rest_framework.pagination.LimitOffsetPagination`

#### 1-1 settings.py

在设置文件中，设置`REST_FRAMEWORK`中`DEFAULT_PAGINATION_CLASS`和`PAGE_SIZE`.

```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
    'PAGE_SIZE': 5,
    'DEFAULT_RENDERER_CLASSES': (
        'rest_framework.renderers.JSONRenderer',
        # 为了调试，需要BrowsableAPIRenderer，正式环境需要注释下面这行
        'rest_framework.renderers.BrowsableAPIRenderer',
    )
}
```

#### 1-2 views

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
```

#### 1-3 使用

用Postman GET访问：`http://127.0.0.1:8080/api/1.0/asset/group/list`

结果中：有`count`,`next`,`previous`,`results`字段。

```json
{
    "count": 35,
    "next": "http://127.0.0.1:8080/api/1.0/asset/group/list?limit=5&offset=5",
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

### 2. 自定义编写pagination

#### 2-1 继承pagination.PageNumberPagination

```python
from rest_framework.pagination import PageNumberPagination


class SelfPagination(PageNumberPagination):
    """
    Rest FrameWork 自定义分页器类
    在generics.ListAPIView中可以设置:pagination_class = SelfPagination
    或者在settings.py中指定REST_FRAMEWORK.DEFAULT_PAGINATION_CLASS = 'utils.paginations.SelfPagination'
    另外也可以设置为：'rest_framework.pagination.LimitOffsetPagination'这个类
    加了这个ListView返回的json数据有：count、next、previous、results字段
    """
    page_size = 10
    max_page_size = 1000
    page_size_query_param = 'page_size'
```

#### 2-2 settings.py

修改settings.py中`REST_FRAMEWORK.DEFAULT_PAGINATION_CLASS`为自定义的PageNumberPagination子类。

```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'utils.pagination.SelfPagination',
}
```

#### 2-3 使用

还是原来的链接，这次结果会有小差异：

```json
{
    "count": 35,
    "next": "http://127.0.0.1:8080/api/1.0/asset/group/list?page=2",
    "previous": null,
}
```

### 3. 不使用分页，返回全部数据
> 当设置了DEFAULT_PAGINATION_CLASS, 所有的generics.ListAPIView默认都会分页，  
而有时候，我们不想分页，而是想获取全部的对象列表。

#### 3.1 获取全部的Group

```python

class GroupList(generics.ListAPIView):
    """
    Group 列表 api
    """
    queryset = Group.objects.all().filter(parent=None)
    serializer_class = GroupSerializer
    # 由于settings.py中设置了DEFAULT_PAGINATION_CLASS
    # 而如果不想分页，可以在这里设置pagination_class为None
    pagination_class = None
```    

这样当我们再次访问list页面，就会返回全部的数据。

```json

[
    {
        "id": 1,
        "name": "AliYun",
        "parent": null,
        "description": "阿里云服务器",
        "subs": []
    },
    {
        "id": 48,
        "name": "AWS",
        "parent": null,
        "description": "这个是AWS描述内容",
        "subs": []
    }
]
```
