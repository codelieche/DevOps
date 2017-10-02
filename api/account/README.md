## account api

> 主要是用户登陆登出，用户分组方面的api。  
api前缀：`http://127.0.0.1:8080/api/1.0/`

#### Account Api List

| ID | API列表 | 方法|  描述 |
| --- | --- | --- | --- |
| 1 | account/login/ | POST | 账号登陆 |
| 2 | account/logout | GET | 退出登陆 |
| 3 | account/user/list | GET | 获取项目所有列表 |
| 4 | account/user/projects | GET | 获取用户项目列表 |
| 5 | account/message/create | POST | 发送站内用户消息 |
| 6 | account/message/list | GET | 获取用户消息列表 |
| 7 | account/message/:id | GET | 获取用户消息详情 |
| 8 | account/group/create | POST | 创建用户组 |
| 9 | account/group/:id | GET | 获取用户组详情 |
| 10 | account/group/:id/editor | PUT | 修改用户组信息 |

