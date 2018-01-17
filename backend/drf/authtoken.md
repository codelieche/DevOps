## Django Rest Framework TokenAuthentication

### 1. 修改settings

**INSTALLED_APPS**

```python
INSTALLED_APPS = [
    ...
    'rest_framework.authtoken'
]
```

**REST_FRAMEWORK**

```python
# Django Rest Framework的配置
REST_FRAMEWORK = {
    # 设置分页
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
    'PAGE_SIZE': 10,
    'DEFAULT_RENDERER_CLASSES': (
        'rest_framework.renderers.JSONRenderer',
        # 为了调试，需要BrowsableAPIRenderer, 生产环境需要注释下面这行
        'rest_framework.renderers.BrowsableAPIRenderer',
    ),
    # 设置DatetimeField字段的格式
    'DATETIME_FORMAT': '%Y-%m-%d %H:%M:%S',
    # 用户认证
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    )
}
```

### 2. migrate

```
$ python manage.py migrate
```
执行migrate后会创建：`authtoken_token`的表，这个表有三个字段，key,created, user_id。

### 3. 给用户创建个Token

```python
from rest_framework.authtoken.models import Token
from account.models import User

u = User.object.get(username="admin")

token = Token.objects.create(user=u)
print(token.key)
# 或者使用
# Token.objects.get_or_create(user=u)
```

### 4. 配置api-auth-token

**文件位置：**`apps/account/urls/api.py`

```python
from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token

from account.views import account

app_name = "account"

# 前缀：/api/v1/account
urlpatterns = [
    path('api-auth-token', obtain_auth_token),
    # 账号登陆、登出api
    path('login/', account.LoginView.as_view(), name="login"),
]
```

**注意：**上面的路由配置是基于Django2.0的，和Django1.11有细微差异。


### 5. 使用Token

```
curl -H 'Authorization: Token f203461e26d8......b598b7641fdd' http://127.0.0.1:8080/api/v1/task/list
```

