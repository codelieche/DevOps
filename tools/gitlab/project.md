## Gitlab Project Api


### 参考文档
- [Projects api](https://gitlab.com//help/api/projects.md)
- [Branches api](https://gitlab.com//help/api/branches.md)

### 方法说明
- `__init__`: 初始化，需要传递group的path和项目的name，如果是新项目需要创建(设置`need_create`设置为`True`)

### Code

```python
import requests
from django.conf import settings
from .group import GroupApi


PRIVATE_TOKEN = settings.GITLAB_PRIVATE_TOKEN
gitlab_url = settings.GITLAB_URL

if gitlab_url.endswith('/'):
    gitlab_url = gitlab_url[:-1]
URL_BASE = '{}/api/v4'.format(gitlab_url)


class ProjectApi(object):

    def __init__(self, group, name, need_create=False):
        """
        Gitlab项目api初始化
        :param group: 项目所在的组
        :param name: 项目名,其实是项目的path，name可以是中文的
        :param need_create: 是否需要创建 默认是False
        """
        self.headers = {
            'PRIVATE-TOKEN': PRIVATE_TOKEN
        }
        self.api_url_base = URL_BASE
        self.group = group
        self.name = name
        self.project_id = None
        if need_create:
            # 运行创建项目
            g = GroupApi(path=self.group)
            project = g.create_project(name=self.name)
            if project:
                self.project_id = project['id']
            else:
                raise Exception("创建项目失败")
        else:
            # 项目存在的，搜索并获取到项目的id
            self.get_project_id()

    def get_project_id(self):
        """
        通过self.group, self.name获取到项目
        """
        # 先根据name搜索，然后再根据path_with_namespace过滤
        # 1. 搜索获取列表
        url = '{}/projects'.format(self.api_url_base)
        page = 1
        while page:
            parames = {
                'search': self.name,
                'simple': True,
                'page': page
            }
            response = requests.get(url, params=parames, headers=self.headers)
            page = response.headers['X-Next-Page']
            project_list = response.json()
            path_with_namespace = '{}/{}'.format(self.group, self.name)
            for project in project_list:
                if project['path_with_namespace'] == path_with_namespace:
                    self.project_id = project['id']
                    page = None
                    break
        # 表示没找到project_id
        if not self.project_id:
            raise NameError("没找到这个项目哦")

    def detail(self):
        url = '{}/projects/{}'.format(self.api_url_base, self.project_id)
        response = requests.get(url, headers=self.headers)
        if response.ok:
            return response.json()
        else:
            return False

    def create_file(self, file_path, content, branch, commit_message=None):
        url = '{}/projects/{}/repository/files/{}'.format(
            self.api_url_base, self.project_id, file_path
        )
        if not commit_message:
            commit_message = 'Add {}'.format(file_path)
        data = {
            'file_path': file_path,
            'content': content,
            'branch': branch,
            'commit_message': commit_message
        }

        response = requests.post(url, data=data, headers=self.headers)
        if response.status_code == 201:
            return True
        else:
            return False

    def set_defaul_branch(self, branch='develop'):
        """设置默认的分支"""
        # 通过put修改默认的分支
        url = '{}/projects/{}'.format(self.api_url_base, self.project_id)
        data = {
            'default_branch': branch
        }
        response = requests.put(url, data=data, headers=self.headers)
        result = response.json()
        if result.get('default_branch') == branch:
            return True
        else:
            return False

    def protect(self, branch, developers_can_push=False, developers_can_merge=False):
        """
        保护分支
        :param branch: 分支名称
        :param developers_can_push: 开发者能推送，默认False
        :param developers_can_merge: 开发者能合并，默认False
        :return: True / False
        """
        url = '{}/projects/{}/repository/branches/{}/protect'.format(
            self.api_url_base, self.project_id, branch
        )
        # 构造数据
        data = {
            'developers_can_push': developers_can_push,
            'developers_can_merge': developers_can_merge
        }
        response = requests.put(url, data=data, header=self.headers)
        result = response.json()
        if result.get('name') == branch and result.get('protected'):
            return True
        else:
            return False

    def set_master_disabel_push(self):
        """设置master分支都不能推送"""
        # 这个功能是要9.5的gitlab才能处理，暂时准备好位置，后面升级了gitlab后再修改
        url = '{}/projects/{}/protected_branches'.format(self.api_url_base, self.project_id)
        # 权限是0->No Access、30->Developer、40->Master
        data = {
            'name': 'master',
            'push_access_level': '0',
            'merge_access_level': '40'
        }
        # response = requests.post(url, data=data, headers=self.headers)
        # if response.ok:
        #     return True
        # else:
        #     return False

    def create_branch(self, branch, ref):
        """
        创建新的分支
        :param branch: 新的分支名
        :param ref: 新的分支从哪里来，branch or commit SHA
        :return: True or False
        """
        url = '{}/projects/{}/repository/branches'.format(self.api_url_base, self.project_id)
        data = {
            'branch': branch,
            'ref': ref
        }
        response = requests.post(url, data=data, headers=self.headers)
        result = response.json()
        if result.get('name') == branch:
            return True
        else:
            return False

    def get_branch(self, branch):
        """获取分支"""
        url = '{}/projects/{}/repository/branches/{}'.format(
            self.api_url_base, self.project_id, branch
        )
        response = requests.get(url, headers=self.headers)
        result = response.json()
        return result

    def branch_list(self):
        url = '{}/projects/{}/repository/branches'.format(self.api_url_base, self.project_id)
        response = requests.get(url, headers=self.headers)
        result = response.json()
        return result

    def branch_delete(self, branch):
        url = '{}/projects/{}/repository/branches/{}'.format(
            self.api_url_base, self.project_id, branch
        )
        response = requests.delete(url, headers=self.headers)
        if response.ok:
            return True
        else:
            return False

    def create_mergerequest(self, soure_branch, target_branch, title, description=''):
        """创建合并请求"""
        url = '{}/projects/{}/merge_requests'.format(
            self.api_url_base, self.project_id
        )
        data = {
            'source_branch': soure_branch,
            'target_branch': target_branch,
            'title': title,
            'description': description
        }
        response = requests.post(url, data=data, headers=self.headers)
        if response.ok:
            return True
        else:
            return False

    def mergerequests_list(self):
        url = '{}/projects/{}/merge_requests'.format(self.api_url_base, self.project_id)
        response = requests.get(url, headers=self.headers)
        if response.ok:
            result = response.json()
            return result
        else:
            return []

    def mergerequest_delete(self, merge_request_id):
        url = '{}/projects/{}/merge_requests/{}'.format(self.api_url_base, self.project_id,
                                                        merge_request_id)
        response = requests.delete(url, headers=self.headers)
        if response.ok:
            return True
        else:
            return False

    def mergerequest_accept(self, merge_request_iid):
        """
        创建了合并请求后，接受合并
        注意：创建mergerequest有个id，还有个iid
        """
        url = '{}/projects/{}/merge_requests/{}/merge'.format(
            self.api_url_base, self.project_id, merge_request_iid)
        response = requests.put(url, headers=self.headers)
        if response.ok:
            return True
        else:
            return False

    def users_list(self):
        """获取项目的用户列表"""
        url = '{}/projects/{}/users'.format(self.api_url_base, self.project_id)
        response = requests.get(url, headers=self.headers)
        if response.ok:
            return response.json()
        else:
            return []

    def members_list(self):
        """列出项目的所有成员"""
        url = '{}/projects/{}/members'.format(self.api_url_base, self.project_id)
        response = requests.get(url, headers=self.headers)
        if response.ok:
            return response.json()
        else:
            return []

    def members_add(self, user, access_level, expires_at=None, is_update=False):
        """
        添加项目成员
        level：10->Guest; 20->Reporter; 30->Developer; 40->Master; 50->Owner
        :param user: 用户名，传递的时候需要是用户名
        :param access_level: 项目权限:10-50,
        :param expires_at: 到期时间，默认不填写
        :param is_update: 有时候需要更新一下用户权限，就需要这个
        :return:
        """
        url = '{}/projects/{}/members'.format(self.api_url_base, self.project_id)
        if access_level not in range(10, 51, 10):
            raise ValueError("传入的access_level值不对")

        # 传入的user需要是字符，如果是存数字就当做是user_id
        if user.isdigit():
            user_id = user
        else:
            user_id = self.get_user_id(username=user)

        if not user_id:
            raise ValueError("用户没找到？？？")

        data = {
            'user_id': user_id,
            'access_level': access_level,
        }
        if is_update:
            # 如果是更新，url后面需要加上user_id, 请求方法是PUT
            url = '{}/{}'.format(url, user_id)
            response = requests.put(url, data=data, headers=self.headers)
        else:
            response = requests.post(url, data=data, headers=self.headers)
        if response.ok:
            return True
        else:
            return False

    def get_user_id(self, username):
        """通过user的名字获取到namespace的id"""
        url = '{}/users'.format(self.api_url_base)
        response = requests.get(url, params={'search': username}, headers=self.headers)
        if response.ok:
            result = response.json()
            for user in result:
                if user['username'] == username:
                    return user['id']
            # 跳出循环了
            return None
        else:
            return None

    def members_remove(self, user):
        """
        移除项目成员
        :param user: 用户名，传递的时候需要是用户名
        """
        # 传入的user需要是字符，如果是存数字就当做是user_id
        if user.isdigit():
            user_id = user
        else:
            user_id = self.get_user_id(username=user)

        if not user_id:
            raise ValueError("用户没找到？？？")

        url = '{}/projects/{}/members/{}'.format(
            self.api_url_base, self.project_id, user_id)

        response = requests.delete(url, headers=self.headers)
        if response.ok:
            return True
        else:
            return False

    def commits_list(self, branch='develop', page=1, per_page=20):
        url = '{}/projects/{}/repository/commits'.format(self.api_url_base, self.project_id)
        params = {
            'ref_name': branch,
            'page': page,
            'per_page': per_page
        }
        response = requests.get(url, params=params, headers=self.headers)
        if response.ok:
            return response.json()
        else:
            return []
```