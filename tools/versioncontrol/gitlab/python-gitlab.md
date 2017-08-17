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

```
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


### 参考文档
- [python-gitlab docs](https://python-gitlab.readthedocs.io/)