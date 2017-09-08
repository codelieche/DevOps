## Gitlab分组相关api

### 参考文档
- [groups api](https://gitlab.com//help/api/groups.md)

### 封装的方法
- `__init__`: 初始化的时候需要传入分组的path，如果不存在是否创建(`need_create`)
- `get_group_id`: 通过`path`获取到分组的`id`
- `detail`: 获取分组的详情信息
- `create_project`: 在当前分组中创建项目，传递`name`或者`path`参数
- `projects_list`: 列出当前分组中的项目(在base中的list_projects是列出所有项目的)

### 代码

```python
import requests
from django.conf import settings


PRIVATE_TOKEN = settings.GITLAB_PRIVATE_TOKEN
gitlab_url = settings.GITLAB_URL

if gitlab_url.endswith('/'):
    gitlab_url = gitlab_url[:-1]
URL_BASE = '{}/api/v4'.format(gitlab_url)


class GroupApi:
    """
    Gitlab Group API
    """
    def __init__(self, path, need_create=False):
        """
        初始化Group api对象
        :param path: 分组的path
        :param need_create: 是否需要创建，当分组不存在的时候，就需要创建一下
        """
        self.path = path
        self.headers = {
            'PRIVATE-TOKEN': PRIVATE_TOKEN
        }
        self.api_url_base = URL_BASE
        self.group_id = None

        if need_create:
            # 需要创建新的分组，暂时不
            raise NameError("创建新的分组功能，暂时不开发")
        else:
            self.get_group_id()

    def get_group_id(self):
        # 1. 先搜索出所有的groups
        url = '{}/groups'.format(self.api_url_base)
        response = requests.get(url, headers=self.headers)
        results = response.json()

        # 2. 通过迭代列表，根据path的值来判断搜索到结果
        for group in results:
            print(group)
            if group['path'] == self.path:
                self.group_id = group['id']
                break
        # 3. 如果没搜到，就需要抛出异常了
        if not self.group_id:
            raise Exception("没有找到group：{}".format(self.path))

    def detail(self):
        url = '{}/groups/{}'.format(self.api_url_base, self.group_id)
        response = requests.get(url, headers=self.headers)
        return response.json()

    def create_project(self, name, path=None):
        """创建项目到当前分组中"""
        # 1. 默认要就设置path和name相等
        if path and not name:
            name = path
        elif name and not path:
            path = name
        url = '{}/projects'.format(self.api_url_base)
        # 2. 构造数据
        data = {
            'name': name,
            'path': path,
            # 如果不填写namespace_id就是用户的namespace
            'namespace_id': self.group_id
        }
        # 3. post创建项目
        response = requests.post(url, data=data, headers=self.headers)
        if response.ok:
            return response.json()
        else:
            return False

    def projects_list(self):
        url = '{}/groups/{}/projects'.format(self.api_url_base, self.group_id)
        params = {
            'simple': True
        }
        response = requests.get(url, headers=self.headers, params=params)
        results = response.json()
        return results
```