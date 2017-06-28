## 使用自定义User

### 拓展django的AbstractUser
文件位置：`apps/account/models.py`,想要拓展什么字段，添加即可。

```python

from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.encoding import python_2_unicode_compatible

@python_2_unicode_compatible
class User(AbstractUser):
    """
    自定义的用户Model
    拓展了gender, nike_name, mobile, svn_password字段
    """
    GENDER_CHOICES = (
        ('male', '男'),
        ('female', '女'),
        ('secret', '保密'),
    )

    nike_name = models.CharField(max_length=40, blank=True, verbose_name="昵称")
    gender = models.CharField(max_length=6, choices=GENDER_CHOICES,
                              verbose_name="性别", default="secret")
    mobile = models.CharField(max_length=11, verbose_name="手机号", blank=True)
    svn_password = models.CharField(max_length=40, blank=True)

    def __str__(self):
        return self.username

    class Meta:
        verbose_name = "用户信息"
        verbose_name_plural = verbose_name
```


### 修改settings.py
> 配置用户模型：注册用户系统使用哪个用户模型。  
不需要加入中间的models：account.models.User，直接使用`account.User`即可。

```
AUTH_USER_MODEL = 'account.User'
```

## 自定义验证类
> 需要继承`django.contrib.auth.backends.ModelBackend`.  
文件位置：`apps/account/auth.py`

```python

from django.contrib.auth.backends import ModelBackend
from django.db.models import Q

from .models import User

class CustomBackend(ModelBackend):
    """
    自定义用户验证
    """

    def authenticate(self, username=None, password=None, **kwargs):
        try:
            # 用户有可能传入的是邮箱或者用户名或者手机号
            # 用Q来让查询条件实现或的功能
            user = User.objects.get(
                Q(username=username) | Q(email=username) | Q(mobile=username)
            )
            if user.check_password(password):
                return user
            else:
                return None
        except Exception as e:
            return None
```

### 设置自定义auth认证
> 编写了`CustomBackend`我们还需要在`settings.py`中设置`AUTHENTICATION_BACKENDS`。

```
AUTHENTICATION_BACKENDS = (
    'account.auth.CustomBackend',
)
```
