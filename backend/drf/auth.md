## 用户认证

### Json Web Token

### djangorestframework-jwt的使用

#### 安装

```
pip install djangorestframework-jwt
```

#### 配置url
> 文件位置：`apps/account/urls/api.py`

```python
from django.conf.urls import url
from rest_framework_jwt.views import obtain_jwt_token

urlpatterns = [
    # 前缀是/api/1.0/account/
    # jwt token auth
    url(r'^token/?$', obtain_jwt_token, name='jwt_token'),
]
```

#### settings.py

```python
REST_FRAMEWORK = {
    # ....
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_jwt.authentication.JSONWebTokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ),
}
```

#### 简单使用

##### 获取token

- 使用curl

```bash
$ curl -X POST -d "username=admin&password=password123" http://localhost:8000/api/1.0/account/token/
```

```
$ curl -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"password123"}' http://localhost:8000/api/1.0/account/token/
```
返回结果：

```json
{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9......"}
```

- 使用httpie
```bash
http POST http://127.0.0.1:8000/api/1.0/account/token/ username=admin password=123456
HTTP/1.0 200 OK
Allow: POST, OPTIONS
Content-Length: 176
Content-Type: application/json
Date: Fri, 17 Nov 2017 08:03:34 GMT
Server: WSGIServer/0.2 CPython/3.5.3
Vary: Accept
X-Frame-Options: SAMEORIGIN

{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9....."
}
```

##### 使用token
> 注意JWT和token之间有个空格！

- 使用curl
```
curl -H "Authorization: JWT <your_token>" http://localhost:8000/api/1.0/account/group/1/
```

- 使用httpie
```bash
http :8000/api/1.0/account/group/1?format=json "Authorization: JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...."
HTTP/1.0 200 OK
Allow: GET, PUT, PATCH, DELETE, HEAD, OPTIONS
Content-Length: 54
Content-Type: application/json
Date: Fri, 17 Nov 2017 08:12:45 GMT
Server: WSGIServer/0.2 CPython/3.5.3
Vary: Accept
X-Frame-Options: SAMEORIGIN

{
    "id": 1,
    "name": "运维组",
    "user_set": [
        "admin"
    ]
}
```


### 参考文档
- [jwt.io](https://jwt.io/)
- [django-rest-framework-jwt](http://getblimp.github.io/django-rest-framework-jwt/)