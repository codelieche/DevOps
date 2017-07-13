## 禁止Django的CSRF验证

> 当我们没取消CSRF TOKEN的验证，会报403错误。  
Django REST Framework会返回错误。

```
{
    "detail": "Authentication credentials were not provided."
}
```

### 编写中间件
文件：`apps/utils/middlewares.py`.  
继承了`MiddlewareMixin`这个类，Django以前的版本编写中间件有差异。  
同时取消CSRF验证，只对`/api`开头的路由有效，其它的还是不取消验证。

```python
from django.utils.deprecation import MiddlewareMixin

class ApiDisableCSRF(MiddlewareMixin):
    """API的请求都取消CSRF验证"""

    def is_api_request(self, request):
        """判断是否是qpi的请求"""
        path = request.path.lower()
        return path.startswith('/api/')

    def process_request(self, request):
        if self.is_api_request(request):
            # 给request设置属性，不要检验csrf token
            setattr(request, '_dont_enforce_csrf_checks', True)
```

我们查看MiddlewareMixin的定义：

```python
class MiddlewareMixin(object):
    def __init__(self, get_response=None):
        self.get_response = get_response
        super(MiddlewareMixin, self).__init__()

    def __call__(self, request):
        response = None
        if hasattr(self, 'process_request'):
            response = self.process_request(request)
        if not response:
            response = self.get_response(request)
        if hasattr(self, 'process_response'):
            response = self.process_response(request, response)
        return response
```
当中间件被调用`__call__`方法的时候，有`process_request`属性，就会调用这个方法。

### 添加中间件到settings.py中

```
MIDDLEWARE = [
    ......
    # 添加自定义中间件，如果是api访问用户的，就不对csrf校验
    'utils.middlewares.ApiDisableCSRF',
]
```

## 开启跨域访问api
> 除了编写中间件来开启跨域访问，也可以使用`django-cors-headers`(具体可以参考相关文档).

### 在前端使用fetch访问api
```js
fetchData = () => {
    var url = 'http://127.0.0.1:8080/api/1.0/asset/group/list';
    fetch(url)
      .then(response => response.json())
        .then(responseData => {
            console.log('=========');
            console.log(responseData);
        })
          .catch(err => {
              console.log(err);
          });
}
fetchData();
```
打开浏览器调试工具可以查看到，如下错误：
```
Fetch API cannot load http://127.0.0.1:8080/api/1.0/asset/group/list. 
No 'Access-Control-Allow-Origin' header is present on the requested resource. 
Origin 'http://localhost:3000' is therefore not allowed access. 
If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.
```
### 编写中间件

```python
class ApiDisableCORS(MiddlewareMixin):
    """API的请求都取消CSRF验证"""

    def is_api_request(self, request):
        """判断是否是qpi的请求"""
        path = request.path.lower()
        return path.startswith('/api/')

    def process_response(self, request, response):
        if self.is_api_request(request):
            # 给api的请求取消CORS
            response["Access-Control-Allow-Origin"] = "*"
        return response
```
然后把这个中间件添加到settings.py中。  
使用`*`是为了api的测试，正式环境不推荐使用通配符。

### 取消CSRF和CORS

```python
from django.utils.deprecation import MiddlewareMixin

class ApiDisableCSRFAndCORS(MiddlewareMixin):
    """API的请求都取消CSRF验证"""

    def is_api_request(self, request):
        """判断是否是qpi的请求"""
        path = request.path.lower()
        return path.startswith('/api/')

    def process_request(self, request):
        if self.is_api_request(request):
            # 给request设置属性，不要检验csrf token
            setattr(request, '_dont_enforce_csrf_checks', True)

    def process_response(self, request, response):
        if self.is_api_request(request):
            # 给api的请求取消CORS
            response["Access-Control-Allow-Origin"] = "*"
        return response
```
再次在浏览器中，使用fetch获取数据就不会报错了。