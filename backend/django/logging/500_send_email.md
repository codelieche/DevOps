### 服务器500错误的时候发送邮件

文件：`settings.py`  
发送邮件，需要`DEBUG = False`的情况下才会发送邮件。

```python

# 设置管理员邮箱
ADMINS = (
    ('UserName', 'xxxx@qq.com'),
)

# EMAIL设置
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

# 邮件发送配置
EMAIL_HOST = "smtp.mxhichina.com"
EMAIL_PORT = 25
EMAIL_HOST_USER = "admin@codelieche.com"
# 配置环境变量，设置成阿里云企业邮箱 发送邮件
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_PASSWORD', 'password')
# 开启安全连接
EMAIL_USE_TLS = False
EMAIL_FROM = "admin@codelieche.com"
# 邮件标题前缀
EMAIL_SUBJECT_PREFIX = '【OpsMind】'
DEFAULT_FROM_EMAIL = SERVER_EMAIL = EMAIL_HOST_USER

# logging日志配置
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(asctime)s %(funcName)s %(filename)s %(lineno)d: %(message)s'
        },
        'simple': {
            'format': '%(asctime)s %(filename)s %(lineno)d: %(message)s'
        },
    },
    'handlers': {
        # Debug = False 才会发送
        'mail_admins': {
            'level': 'ERROR',
            'class': 'django.utils.log.AdminEmailHandler',
            'include_html': True,
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
        },
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': os.path.join(BASE_DIR, '../logs/debug.log'),
        },
    },
    'loggers': {
        # 'django': {
        #     'handlers': ['file'],
        #     'level': 'INFO',
        #     'propagate': True,
        # },
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}
```

>当出现500错误的时候，就会发送邮件到管理员邮箱中。  
注意设置`include_html`为`True`这样邮件内容可视化更好些。