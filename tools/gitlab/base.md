## Gitlab 基本api

文件位置：`apps/utils/gitlab/base.py`


```python
# -*- coding:utf-8 -*-
import requests
from django.conf import settings

PRIVATE_TOKEN = settings.GITLAB_PRIVATE_TOKEN
gitlab_url = settings.GITLAB_URL

if gitlab_url.endswith('/'):
    gitlab_url = gitlab_url[:-1]
URL_BASE = '{}/api/v4'.format(gitlab_url)


class GitlabBaseApi:
    """Gitlab 基础api"""
    def __init__(self):
        self.headers = {
            'PRIVATE-TOKEN': PRIVATE_TOKEN
        }
        self.api_url_base = URL_BASE

    def list_groups(self, search='', extract_conf=True):
        """列出所有分组"""
        url = '{}/groups'.format(self.api_url_base)
        params = {'search': search}

        response = requests.get(url, params=params, headers=self.headers)
        if response.ok:
            result = response.json()
            if extract_conf:
                # 排除是conf的分组
                for group in result:
                    if group['path'] == 'conf':
                        result.remove(group)
                        break
            return result

        else:
            return []

    def list_projects(self, search='', page=1, simple=True):
        """列出项目"""
        url = '{}/projects'.format(self.api_url_base)
        params = {
            'page': page,
            'search': search,
            'simple': simple
        }
        response = requests.get(url, params=params, headers=self.headers)
        if response.ok:
            return response.json()
        else:
            return []

    def list_users(self, search='', page=1, per_page=20):
        """列出项目"""
        url = '{}/users'.format(self.api_url_base)
        params = {
            'page': page,
            'search': search,
            'per_page': per_page
        }
        response = requests.get(url, params=params, headers=self.headers)
        if response.ok:
            return response.json()
        else:
            return []
```



