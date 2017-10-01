## 工作流相关api

### Step api List
> 审批步骤基础模块

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | flow/step/create | POST | 添加审批步骤 |
| 2 | flow/step/:id | GET | 获取step信息 |
| 3 | flow/step/:id | PUT | 修改step的信息 |
| 4 | flow/step/:id | DELETE | 删除step |
| 5 | flow/step/list | GET | 获取step的列表 |


### GitFlow api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | flow/job/gitjob | PUT | 修改Git代码提交工作的配置 |
| 2 | flow/job/gitjob | GET | 获取Git代码提交工作的详情 |
| 3 | flow/gitflow/create | POST | 创建gitflow工作流 |
| 4 | flow/gitflow/:id | GET | 获取gitflow的详情 |
| 5 | flow/gitflow/:id | DELETE | 删除gitflow |
| 6 | flow/gitflow/list | GET | 获取gitflow的列表 |
| 7 | flow/gitflow/approve/:id | GET | 获取gitflow的审批的详情 |
| 8 | flow/gitflow/approve/:id | PUT | 修改gitflow的审批状态 |

### SvnFlow api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | flow/job/svnjob | PUT | 修改svn代码提交工作的配置 |
| 2 | flow/job/svnjob | GET | 获取svn代码提交工作的详情 |
| 3 | flow/svnflow/create | POST | 创建svnflow工作流 |
| 4 | flow/svnflow/:id | GET | 获取svnflow的详情 |
| 5 | flow/svnflow/:id | DELETE | 删除svnflow |
| 6 | flow/svnflow/list | GET | 获取svnflow的列表 |
| 7 | flow/svnflow/approve/:id | GET | 获取svnflow的审批的详情 |
| 8 | flow/svnflow/approve/:id | PUT | 修改svnflow的审批状态 |

### ProjectFlow api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | flow/job/projectjob | PUT | 修改创建项目工作相关配置 |
| 2 | flow/job/projectjob | GET | 获取项目创建工作的详情 |
| 3 | flow/projectflow/create | POST | 创建projectflow工作流 |
| 4 | flow/projectflow/:id | GET | 获取projectflow的详情 |
| 5 | flow/projectflow/:id | DELETE | 删除projectflow |
| 6 | flow/projectflow/list | GET | 获取projectflow的列表 |
| 7 | flow/projectflow/approve/:id | GET | 获取projectflow的审批的详情 |
| 8 | flow/projectflow/approve/:id | PUT | 修改projectflow的审批状态 |


### BugFix Flow api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | flow/job/hotfix | PUT | 修改Bug修复工作相关配置 |
| 2 | flow/job/hotfix | GET | 获取Bug修复工作的详情 |
| 3 | flow/hotfix/create | POST | 创建hotfix工作流 |
| 4 | flow/hotfix/:id | GET | 获取hotfix的详情 |
| 5 | flow/hotfix/:id | DELETE | 删除hotfix Flow |
| 6 | flow/hotfix/list | GET | 获取hotfix Flow的列表 |
| 7 | flow/hotfix/approve/:id | GET | 获取hotfix的审批的详情 |
| 8 | flow/hotfix/approve/:id | PUT | 修改hotfix的审批状态 |


























































