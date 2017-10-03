## 项目相关api详情


### 获取项目列表
- url: `/api/1.0/project/list`
- 方法：`GET`
- 参数：`page`，指定第几页
- 返回结果：每页返回10条数据, 可以指定page

```json
{
    "count": 187,
    "next": "http://127.0.0.1:8080/api/1.0/project/list?page=2",
    "previous": null,
    "results": [
        {
            "id": 2,
            "name": "运维自动化平台",
            "name_en": "devops",
            "masters": [
                "user1"
            ],
            "jira_key": "DEVOPS",
            "description": null
        },
        {
            "id": 3,
            "name": "官网",
            "name_en": "codelieche",
            "masters": [
                "user2"
            ],
            "jira_key": "CODELIECHE",
            "description": null
        },
        // ...
    ]
}
```

### 获取所有项目
- url: `/api/1.0/project/all`
- 方法：`GET`
- 返回结果：返回所有项目列表【每个项目字段信息同上】

### 项目api
- url: `/api/1.0/project/:id`或`/api/1.0/project/:name_en`

#### 获取项目详情
- 方法：`GET`
- 返回结果：获取项目详情

```json
{
    "id": 201,
    "name": "git测试",
    "name_en": "gittest",
    "masters": [
        "user1"
    ],
    "developers": [
        "user2",
        "user3"
    ],
    "pms": [],
    "tests": [],
    "maintain": [],
    "develop_deployment": null,
    "test_deployment": null,
    "product_deployment": null,
    "code": {
        "project": "gittest",
        "version_control": "git",
        "host": "git.example.com",
        "product": "gittestprod",
        "group": "default",
        "address": "http://git.example.com/default/gittest.git"
    },
    "jira_key": "Gittest",
    "description": null
}
```

#### 修改项目信息
- 方法：`PUT`

- 参数说明

| 名称 | 类型 | 必须 | 描述 | 示例值 |
| --- | --- | --- | --- | --- |
| name_en | String | 是 | 项目中文名 | 自动化运维平台 |
| name | String | 是 | 项目英文名 | deveop |
| masters | Int | 是 | 项目负责人的用户id | 1,5 |
| jira_key | String | 否 | JIRA中的key，默认是name的大写 | DEVOPS |
| version_control | String | 否 | 代码版本管理方式 | svn 或 git |

### 创建项目
- url: `/api/1.0/project/create`
- 方法：`POST`
- 参数

| 名称 | 类型 | 必须 | 描述 | 示例值 |
| --- | --- | --- | --- | --- |
| name_en | String | 是 | 项目中文名 | 自动化运维平台 |
| name | String | 是 | 项目英文名 | deveop |
| masters | String | 是 | 项目负责人的用户username | user1 |
| develops | List | 否 | 项目开发者的username | user2 |
| pms | List | 否 | 项目产品经理的username | user2 |
| tests | List | 否 | 项目测试人员的username | user2 |
| maintain | List | 否 | 项目维护者的username | user2 |
| jira_key | String | 否 | JIRA中的key，默认是name的大写 | DEVOPS |
| version_control | String | 否 | 代码版本管理方式 | svn 或 git |


### 获取项目代码信息
- url: `/api/1.0/project/:id/code`
- 方法：`GET`
- 返回结果

```json
{
    "project": "gittest",
    "version_control": "git",
    "host": "git.example.com",
    "product": "gittestprod",
    "group": "ops",
    "address": "http://git.example.com/default/gittest.git"
}
```

### 修改项目代码信息
- url: `/api/1.0/project/:id/code`
- 方法：`PUT`
- 参数

| 名称 | 类型 | 必须 | 描述 | 示例值 |
| --- | --- | --- | --- | --- |
| version_control | String | 否 | 代码版本管理方式【默认git】 | svn 或 git |
| host | String | 否 | 代码服务器名 | git.example.com |
| grooup | String | 否 | gitlab中的分组 | default |
| product | String | 否 | svn正式仓库名 | svntest_product |


















