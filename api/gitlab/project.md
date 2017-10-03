## gitlab项目相关api

### 获取gitlab中的分组列表
- url: `/api/1.0/gitlab/group/list`
- 方法：`GET`
- 返回结果：

```json
[ 
    {
        "id": 5,
        "path": "ops",
        "name": " 运维开发组"
    },
    {
        "id": 55,
        "path": "bigdata",
        "name": " 大数据"
    },
    {
        "id": 71,
        "path": "default",
        "name": "default"
    },
    {
        "id": 76,
        "path": "test",
        "name": "test"
    }
]
```

### 获取项目的提交记录列表
- url: `/api/1.0/gitlab/:name_en/commits`
- 方法：`GET`
- 参数

|
名称 | 类型 | 必须 | 描述 | 示例值 |
| --- | --- | --- | --- | --- |
| branch | String | 否 | 项目的分支 | 默认：develop |
| count | String | 否 | 获取提交记录条数 | 默认50 |

- 返回结果：

```json
{
    "url": "http://git.example.com/ops/gittest",
    "data": [
        {
            "id": "587ac64b82f63a7cd118a9efe701177e15579e7e",
            "short_id": "587ac64b",
            "title": "合并分支 'hotfix-2' 到 'develop'",
            "committer_name": "Administrator",
            "committer_email": "admin@example.com",
            "committed_date": "2017-09-24T21:09:40.000+08:00",
            "created_at": "2017-09-24T21:09:40.000+08:00",
            "message": "合并分支 'hotfix-2' 到 'develop'"
        },
        {
            "id": "d0d7f3e46f00991baf633babdddc99ccfc8e7e4d",
            "short_id": "d0d7f3e4",
            "title": "更新 phpinfo.php",
            "committer_name": "Administrator",
            "committer_email": "admin@example.com",
            "committed_date": "2017-09-24T20:14:18.000+08:00",
            "created_at": "2017-09-24T20:14:18.000+08:00",
            "message": "更新 phpinfo.php"
        }
    ],
    "masters": [
        "user1"
    ]
}
```