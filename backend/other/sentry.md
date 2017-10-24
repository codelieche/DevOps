## Sentry基本使用

- `dsn`: 是`Data Source Name`的简称

```
'{PROTOCOL}://{PUBLIC_KEY}:{SECRET_KEY}@{HOST}/{PATH}{PROJECT_ID}'
PROTOCOL 通常会是 http 或者 https，HOST 为 Sentry 服务的主机名和端口，PATH 通常为空。
```

### SDKS Python

#### 1. 安装

```shell
pip install raven --upgrade
```

#### 2. 示例

```python
from raven import Client

client = Client('https://<key>:<secret>@sentry.io/<project>')

try:
    1 / 0
except ZeroDivisionError:
    client.captureException()
```

### Django中使用sentry

#### 1. 先添加到INSTALLED_APPS


```python
INSTALLED_APPS = (
    # ......
    'raven.contrib.django.raven_compat',
)
```

#### 2. 配置

```python
RAVEN_CONFIG = {
    'dsn': 'https://<key>:<secret>@sentry.io/<project>',
}
```

### 参考文档
- [sentry官网](https://sentry.io/)
- [sentry docs](https://docs.sentry.io/)
- [sentry在django中的使用](https://docs.sentry.io/clients/python/integrations/django/)
