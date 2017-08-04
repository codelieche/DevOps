## 给View添加mixin

### 方式一： 直接在View类中添加装饰器

```python
from django.views.generic import View
from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt

@method_decorator(login_required(login_url='/user/login/'), 'dispatch')
class IndexView(View):
    def get(self, request):
        return render(request, 'index.html', {})
```

### 方式二：让子类继承一个类

> 注意事项： mixin类需要继承object，否则报错

```python
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required

class CsrfExemptMixin(object):
    """取消CSRF_TOKEN的验证"""

    @method_decorator(csrf_exempt)
    def dispatch(self, request, *args, **kwargs):
        return super(CsrfExemptMixin, self).dispatch(request, *args, **kwargs)

class LoginRequiredMixin(object):
    """View类提供需要登陆才能访问的控制"""

    @method_decorator(login_required(login_url='/user/login/'))
    def dispatch(self, request, *args, **kwargs):
        return super(LoginRequiredMixin, self).dispatch(request, *args, **kwargs)

class LoginAndCsrfExemptMixin(object):
    """
    取消CSRF_TOKEN和Login的验证Mixin
    """

    @method_decorator(csrf_exempt)
    @method_decorator(login_required(login_url='/user/login/'))
    def dispatch(self, request, *args, **kwargs):
        return super(LoginAndCsrfExemptMixin, self).dispatch(request, *args, **kwargs)
```

#### 使用自定的Mixin类

然后在需要使用`@csrf_exempt` 或者 `@login_required`装饰的类，继承这些类

```python
class IndexView(LoginRequiredMixin, View):

    def get(self, request):
        return render(request, 'index.html', {})

# 用户登陆，取消csrf验证功能
class LoginView(CsrfExemptMixin, View):
    """用户登录/注册View"""
    def get(self, request):
        return render(request, 'account/login.html', {})

    def post(self, request):
        username = request.POST.get('username', '')
        password = request.POST.get('password', '')
        user = authenticate(username=username, password=password)
        if user is not None:
            login(request, user)
            # 登录后 跳转到next_url
            next_url = request.GET.get('next', '/')
            return redirect(next_url)
        else:
            return render(request, 'account/login.html', {'info': "用户名或者密码错误"})
```



