## 项目相关API

### Project API List

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | project/list | GET | 获取项目列表 |
| 2 | project/all | GET | 获取所有项目列表 |
| 3 | project/:id | GET | 获取项目详情(根据ID) |
| 4 | project/:id | PUT | 修改项目信息 |
| 5 | project/:id | DELETE | 删除项目(预留接口，标记删除) |
| 6 | project/:name_en | GET | 获取项目详情(根据name_en) |
| 7 | project/:id/history | GET | 获取项目历史记录 |
| 8 | project/:id/code | GET | 获取项目代码相关信息 |
| 9 | project/:id/code | PUT | 修改项目代码相关信息 |
| 10 | project/:id/deployment/:scenes | GET | 获取项目部署信息(3个场景:develop,test,product) |
| 11 | project/:id/deployment/:scenes | PUT | 修改项目部署信息|

### Gitlab Project API

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | gitlab/group/list | GET | 获取gitlab中分组的列表 |
| 2 | gitlab/:name_en/commits | GET | 获取项目代码提交记录 |



















