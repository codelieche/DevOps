## Elasticsearch APIs

参考文档：

- [X-Pack APIs](https://www.elastic.co/guide/en/elasticsearch/reference/current/xpack-api.html)
- [Security APIs](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api.html)

实现了user、role、role_mapping获取、创建/更新、删除API。

```python
# -*- coding:utf-8 -*-
"""
Elasticsearch相关的api
"""
import requests
from requests.auth import HTTPBasicAuth

class ElasticsearchApi:
    """
    Elasticsearch API Class
    """
    def __init__(self, url="http://127.0.0.1:9200", username="elastic", password=""):
        if url.endswith("/"):
            self.url = url[:-1]
        else:
            self.url = url
        self.username = username
        self.password = password
        self.auth = HTTPBasicAuth(self.username, self.password)
        self.session = requests.Session()
        self.session.auth = self.auth
        # 检查连接
        self.connect()

    def connect(self):
        result = self.check_authencated()
        if not result:
            # 简单粗暴报错
            raise requests.ConnectionError

    def check_authencated(self):
        """检查是否校验成功"""
        url = "{}/_xpack/security/_authenticate".format(self.url)
        response = self.session.get(url)
        # print(response)
        if response.ok:
            result = response.json()
            # print(result)
            if result["username"] == self.username:
                return True
            else:
                return False
        else:
            return False
        
    def create_or_update_user(self, username, passowrd, roles=None, full_name=None, email=None, metadata=None):
        """
        创建用户
        :param username: 用户名
        :param passowrd: 密码
        :param roles: 角色，需要传递数组
        :param full_name: 全名
        :param email: 用户邮箱
        :param metadata: 用户元数据，Dict类型
        :return: True or False
        """
        # 1、数据校验
        if not username or not passowrd:
            raise ValueError("用户名或者密码不可为空")

        # 2、构造请求数据
        # 2-1: 请求的url
        url = "{}/_xpack/security/user/{}".format(self.url, username)

        # 2-2：角色需要是数组，或者为空，传递过来的可能不是数组
        if not roles:
            roles = []
        else:
            if not isinstance(roles, list):
                roles = [roles]

        # 2-3：构造请求的data
        data = {
            "password": passowrd,
            "email": email,
            "full_name": full_name,
            "roles": roles,
            "metadata": metadata
        }

        # 3. 发起创建用户请求
        # 3-1: 发起请求
        response = self.session.post(url=url, json=data)
        # print(response, response.json())

        # 3-2：对结果进行判断
        if not response.ok:
            return False
        else:
            result = response.json()
            # 如果用户是新创建的，会返回：{'user': {'created': True}, 'created': True}
            # 如果用户已经存在，那么就是更新：{'user': {'created': False}, 'created': False}
            if "created" in result:
                # print("创建成功", result)
                if result["created"]:
                    print("成功创建elasticsearch用户：({})".format(username))
                return True
            else:
                # print("创建失败:", result)
                return False

    def get_user(self, username):
        """
        获取用户信息
        :param username: 用户名
        :return: 返回用户信息：{'username': "user", roles: ["xxx"], "full_name": "xxxx", "email": "user@xxx.com"}
        """
        # 1. 构造数据
        url = "{}_xpack/security/user/{}".format(self.url, username)

        # 2. 发起请求
        response = self.session.get(url=url)

        # 3. 处理响应
        if response.ok:
            # {'elastic': {'username': 'elastic', 'roles': ['superuser'], 'full_name': None, 'email': None,
            # 'metadata': {'_reserved': True}, 'enabled': True}}
            result = response.json()
            if username in result:
                return result[username]
            else:
                return None
        else:
            return None

    def delete_user(self, username):
        """
        删除用户
        :param username: 用户名
        :return: True or False
        """
        # 删除用户
        # 1. 构造url
        url = "{}_xpack/security/user/{}".format(self.url, username)

        # 2. 发起请求
        response = self.session.delete(url=url)

        # 3. 处理响应
        if response.ok:
            return True
        else:
            return False

    def get_role(self, name):
        """
        获取角色信息
        :param name: 角色名字
        :return: 角色信息或者False
        """
        # 1. 构造连接
        url = "{}/_xpack/security/role/{}".format(self.url, name)

        # 2. 发起请求
        response = self.session.get(url)

        # 3. 处理响应
        if response.ok:
            result = response.json()
            if name in result:
                return result[name]
            else:
                return None
        else:
            return None

    def create_or_update_role(self, role_name, indices_names, indices_privileges=None):
        """
        创建或者更新角色
        :param role_name: 角色名称
        :param indices_names: 索引名，注意是可以用正则的，比如：ops*
        :param indices_privileges: 默认是Read权限
        :return: Role Info or False
        # 简单粗暴，创建的角色，就识别一个正则的index,读写权限
        # 如果复杂的权限可去kibana中创建
        """
        # 1. 数据校验
        if not role_name:
            raise ValueError("请传入角色名称")
        if not indices_names:
            raise ValueError("请传入索引名")

        # 2. 构造数据
        # 2-1：url
        url = "{}/_xpack/security/role/{}".format(self.url, role_name)
        # 2-2: indices_name
        if not isinstance(indices_names, list):
            indices_names = [indices_names]

        # 2-3: indices_privileges
        if not indices_privileges:
            indices_privileges = ["read"]
        else:
            if not isinstance(indices_privileges, list):
                indices_privileges = [indices_privileges]

        # 2-4： 构造请求body数据
        data = {
            "cluster": [],
            "indices": [
                {
                    "names": indices_names,
                    "privileges": indices_privileges,
                },
            ],
            "applications": [
                {
                    "application": "kibana-.kibana",
                    "privileges": ["read"],
                    "resources": ["*"]
                }
            ]
        }

        # 3. 发起请求
        response = self.session.post(url=url, json=data)

        # 4. 处理响应
        if response.ok:
            result = response.json()
            # 创建：{'role': {'created': True}}
            # 更新：{'role': {'created': False}}
            if "role" in result:
                return True
            else:
                return False
        else:
            return False

    def delete_role(self, name):
        """删除角色"""
        # 1. 构造url
        url = "{}/_xpack/security/role/{}".format(self.url, name)

        # 2. 发起请求
        response = self.session.delete(url=url)

        # 3. 处理响应
        if response.ok:
            # 删除成功：response.json() is {'found': True}
            # 如果角色已经不存在会是404，同时返回的json会是：{'found': False}
            return True
        else:
            return False

    def get_all_role_mapping(self):
        """
        获取所有的角色映射
        :return: Dict，Key是角色名，Value是角色映射信息
        """
        # 1. 构造数据
        url = "{}/_xpack/security/role_mapping".format(self.url)

        # 2. 发起请求
        response = self.session.get(url=url)

        # 3. 处理响应
        if response.ok:
            return response.json()
        else:
            return {}

    def get_role_mapping(self, name):
        """
        获取角色映射
        :param name: 角色映射名
        :return: 角色映射信息
        """
        if not name:
            return False

        # 1. 构造数据
        url = "{}/_xpack/security/role_mapping/{}".format(self.url, name)

        # 2. 发起请求
        response = self.session.get(url=url)

        # 3. 处理响应
        if response.ok:
            result = response.json()
            if name in result:
                return result[name]
            else:
                return None
        else:
            return None

    def delete_role_mappimg(self, name):
        if not name:
            return False

        # 1. 构造数据
        url = "{}/_xpack/security/role_mapping/{}".format(self.url, name)

        # 2. 发起请求
        response = self.session.delete(url=url)

        # 3. 处理响应
        if response.ok:
            # {'found': True}
            return True
        else:
            # {'found': False}
            return False

    def create_or_update_role_mapping(self, name, roles, username):
        """
        创建或者更新角色映射
        :param name: 角色映射名称
        :param roles: 角色列表
        :param username: 用户名列表，其实是可以用正则的
        :return: True Or False
        """
        # 1. 校验数据
        if not name:
            raise ValueError("角色映射名字是必填的")

        if not roles:
            raise ValueError("请传入角色列表")

        # 2. 构造数据
        # 2-1：url
        url = "{}/_xpack/security/role_mapping/{}".format(self.url, name)

        # 2-2: roles
        if not roles:
            roles = []
        else:
            if not isinstance(roles, list):
                roles = [roles]

        # 2-3: username
        if not username:
            username = []
        else:
            if not isinstance(username, list):
                username = [username]

        # 2-4: 请求body数据
        data = {
            "roles": roles,
            "enabled": True,
            "rules": {
                "field": {
                    "username": username,
                }
            }
        }

        # 3. 发起请求
        response = self.session.post(url=url, json=data)

        # 4. 处理请求
        if response.ok:
            # 如果是创建：response.json() is {'role_mapping': {'created': True}}
            # 如果是更新：response.json() is {'role_mapping': {'created': False}}
            return True
        else:
            return False

```

