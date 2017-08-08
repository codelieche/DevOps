## Django单点登录
> LDAP一般使用openldap或者Microsoft Active Directory。

依赖包: `pip install django-python3-ldap`.

```
django-python3-ldap==0.10.0
ldap3==2.2.3
```

### django-python3-ldap


#### 配置

**1. INSTALLED_APPS**

```python
INSTALLED_APPS = [
    # ....
    'rest_framework',
    # LDAP单点登录
    'django_python3_ldap',
    # ...
]
```

** 2. AUTHENTICATION_BACKENDS**

```python
# 注册用户系统使用哪个用户模型
# 不需要加入中间的models
AUTH_USER_MODEL = 'account.User'

# 使用自定义后台auth认证方法
AUTHENTICATION_BACKENDS = (
        'django_python3_ldap.auth.LDAPBackend',
        'account.auth.CustomBackend',
    )
```

**3. 配置LDAP**

```python
# LDAP配置
LDAP_AUTH_URL = 'ldap://codelieche.com:389'
LDAP_AUTH_USE_TLS = False
LDAP_AUTH_SEARCH_BASE = "OU=codelieche,DC=codelieche,DC=com"
LDAP_AUTH_OBJECT_CLASS = "person"

# 把LDAP服务器上的用户信息 添加到自己的Django拓展的User表中
# sAMAccountName 是LDAP原来用户名的字段
LDAP_AUTH_USER_FIELDS = {
    "username": "uid",
    "first_name": "givenName",
    "last_name": "sn",
    "mobile": "mobile",
    "email": "mail",
}
LDAP_AUTH_USER_LOOKUP_FIELDS = ("username",)
LDAP_AUTH_CLEAN_USER_DATA = "django_python3_ldap.utils.clean_user_data"
LDAP_AUTH_SYNC_USER_RELATIONS = "django_python3_ldap.utils.sync_user_relations"
LDAP_AUTH_FORMAT_SEARCH_FILTERS = "django_python3_ldap.utils.format_search_filters"
# OpenLDAP 和 Microsoft Active Directory配置有差异的，这里是Microsoft的AD配置
LDAP_AUTH_FORMAT_USERNAME = "django_python3_ldap.utils.format_username_active_directory"
# LDAP_AUTH_ACTIVE_DIRECTORY_DOMAIN = None
LDAP_AUTH_CONNECTION_USERNAME = None
LDAP_AUTH_CONNECTION_PASSWORD = None
```

### 参考文档
- [django-python3-ldap](https://github.com/etianen/django-python3-ldap)
