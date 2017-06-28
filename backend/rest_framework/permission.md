## Django REST full Framework Permission

> 权限控制是一个非常重要的功能。

## 基本使用

### 1：编写BasePermission子类

文件位置：`apps/utils/permissions.py`

```python
from rest_framework import permissions


class IsSuperUser(permissions.BasePermission):
    """需要是超级用户才能操作的权限"""

    def has_object_permission(self, request, view, obj):
        # 关于对象的权限，查看、修改、删除
        # rest_framework..generics.RetrieveUpdateDestroyAPIView
        # 继承 BasePermission 复写这个方法，只有当 has_permission 返回True或者没设置，才会来执行此方法
        return request.user.is_superuser

    def has_permission(self, request, view):
        # 这个是全局的是否有权限
        # 关于权限会先用has_permission处理
        # 如果是关于对象的权限，这里返回了True 就还需要去 has_object_permission判断一下，是 False就直接返回
        return request.user.is_superuser


class IsSuperUserOrReadyOnly(permissions.BasePermission):
    """如果不是超级管理员，那么只能对对象进行查看的权限"""

    def has_object_permission(self, request, view, obj):
        # 如果是GET方法，那么可以查看，但是如果是PUT或者DELETE就需要是超级用户
        if request.method in permissions.SAFE_METHODS:
            # 'GET', 'HEAD', 'OPTIONS'
            return True
        else:
            # 需要是超级用户才可以操作
            return request.user.is_superuser
```

### 2：在Views中使用

> 创建Group我们需要是超级用户，使用`IsSuperUser`.  
> 获取Group的详情\(让非超级用户也可以访问\)、编辑和删除需要是超级用户，那么就使用`IsSuperOrReadyOnly`。

```python
from rest_framework import generics

from asset.models import Group
from asset.serializers.asset import GroupSerializer
from utils.permissions import IsSuperUser, IsSuperUserOrReadyOnly

class GroupCreate(generics.CreateAPIView):
    """创建Group"""
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    # 权限控制
    permission_classes = (IsSuperUser,)


class GroupDetail(generics.RetrieveUpdateDestroyAPIView):
    """Group 详情相关的View"""
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    # 权限控制
    permission_classes = (IsSuperUserOrReadyOnly,)
```

### 3：使用

#### 3-1：查看

```json
➜  devops git:(master) http http://127.0.0.1:8080/api/1.0/asset/group/1/
HTTP/1.0 200 OK
Allow: GET, PUT, PATCH, DELETE, HEAD, OPTIONS
Content-Length: 76
Content-Type: application/json
Date: Tue, 27 Jun 2017 04:01:50 GMT
Server: WSGIServer/0.2 CPython/3.5.3
Vary: Accept, Cookie
X-Frame-Options: SAMEORIGIN

{
    "description": "阿里云服务器",
    "id": 1,
    "name": "阿里云",
    "parent": null
}
```

#### 3-2: 编辑Group

> 不填写账号或者账号名或者密码错误。

```json
➜  devops git:(master) http -f PUT http://127.0.0.1:8080/api/1.0/asset/group/1/ name="阿里云"
HTTP/1.0 403 Forbidden
....

{
    "detail": "Authentication credentials were not provided."
}
```

> 填写正确的用户名和密码

```json
➜  devops git:(master) http -a admin:abc123456 -f PUT http://127.0.0.1:8080/api/1.0/asset/group/1/ name="AliYun"
HTTP/1.0 200 OK
.....

{
    "description": "阿里云服务器",
    "id": 1,
    "name": "AliYun",
    "parent": null
}
```

#### 3-3: 删除

> 删除需要使用DELETE方法

```
➜  devops git:(master) http -a admin:abc123456 -f DELETE http://127.0.0.1:8080/api/1.0/asset/group/40/
HTTP/1.0 204 No Content
Allow: GET, PUT, PATCH, DELETE, HEAD, OPTIONS
Content-Length: 0
Date: Tue, 27 Jun 2017 04:06:46 GMT
Server: WSGIServer/0.2 CPython/3.5.3
Vary: Accept, Cookie
X-Frame-Options: SAMEORIGIN
```

#### 3-5：创建

> 创建使用的是POST方法，需要传递`name`字段,`description`是选填字段。

```json
➜  devops git:(master) http -a admin:abc123456 -f POST http://127.0.0.1:8080/api/1.0/asset/group/create name="AWS" id=47 description="这个是描述内容"
HTTP/1.0 201 Created
Allow: POST, OPTIONS
....

{
    "description": "这个是描述内容",
    "id": 48,
    "name": "AWS",
    "parent": null
}
```



