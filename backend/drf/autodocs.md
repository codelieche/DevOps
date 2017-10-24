## DRF自动文档

> 前后端分离，文档非常重要。自己写的文档，有一定的滞后性，而DRF提供了强大的自动文档功能。

项目url配置文件：

```python
from django.conf.urls import url, include
from django.contrib import admin
from rest_framework.documentation import include_docs_urls

urlpatterns = [
    url(r'^admin', admin.site.urls),
    url(r'^api/1.0/', include('devops.urls.api', namespace='api')),
    url(r'^docs/', include_docs_urls(title="DevOps API文档")),
]
```