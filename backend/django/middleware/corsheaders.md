## Django跨域访问
> 在我们写api的时候，很多时候是要支持跨域访问的。  
可以自己编写中间件，但是最快捷的方式是，使用django-cors-headers.

## django-cors-headers基本使用

### 安装

```
pip install django-cors-headers
```

### 设置

**1. 添加到apps中**

```
INSTALLED_APPS = (
    ...
    'corsheaders',
    ...
)
```

**2. 添加中间件**
```
MIDDLEWARE = [  # Or MIDDLEWARE_CLASSES on Django < 1.10
    ...
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    ...
]
```

**3. 添加配置**
> 快捷配置，测试环境的话用下面配置即可。

```python
# 跨域访问
CORS_ORIGIN_ALLOW_ALL = True
CORS_URLS_REGEX = r'^/api/.*$'
CORS_ALLOW_CREDENTIALS = True
```

> 正式环境还是要指定域名，而不是`CORS_ORIGIN_ALLOW_ALL`.

```
CORS_ORIGIN_WHITELIST = (
    'codelieche.com',
    'app.example.com',
    'localhost:8000',
    '127.0.0.1:3000'
)
```
> 还可以指定允许的方法：

```
CORS_ALLOW_METHODS = (
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
)
```
> 设置允许的HEADERS

```
CORS_ALLOW_HEADERS = (
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
)
```

### 参考文档
- [django-cors-headers](https://github.com/ottoyiu/django-cors-headers/)

