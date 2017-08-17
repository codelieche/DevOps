## python-gitlab基本使用

### 基本使用

#### 获取所有项目

```python
import gitlab

# 默认使用v3版本的api
gl = gitlab.Gitlab(url='http://gitlab.codelieche.com', private_token='PRIVATE_TOKEN', api_version=4)
gl.auth()

# 获取所有的项目信息
projects = gl.projects.list()
for p in projects:
    print(p)
```

#### 获取项目分支的提交记录

```python
project_id = 1
p = gl.projects.get(id=project_id)
commits = p.commits.list(ref_name=branch)
for commit in commits:
    # 倒序排列，最新的在最前面的
    # 打印出commit的ID、提交者、提交者邮箱、提交时间(unicode)、提交消息
    print(commit.id, commit.committer_name, commit.committed_date, commit.message)
    # 查看commit的diff
    diff_list = commit.diff()
    for diff in diff_list:
        print(diff['new_path'], diff['diff'])
```

#### 获取项目分支

```python
def get_project_branches(project_id):
    # 获取项目的所有分支
    # branches = gl.project_branches.list(project_id=project_id)
    p = gl.projects.get(id=project_id)
    branches = p.branches.list()
    for branch in branches:
        print(branch.name, branch.project_id)
```

#### 创建新的分支

```python
def create_new_branch(project_id, new_branch_name, source_branch_ref):
    """
    创建新的分支
    :param project_id: 项目的id
    :param new_branch_name: 新的分支名称
    :param source_branch_ref: 新分支从哪来【可以是其它分支，也可以是其它的commit的id，甚至tag】
    :return:
    """
    branch = gl.project_branches.create({
        'branch': new_branch_name,
        'ref': source_branch_ref
    }, project_id=project_id)
    print(branch.name, branch.project_id)
```



### 参考文档
- [python-gitlab docs](https://python-gitlab.readthedocs.io/)