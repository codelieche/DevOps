## 项目部署相关api

### 获取项目部署信息
- url: `/api/1.0/project/205/deployment/:scenes`
- scenes的值：`develop`, `test`, `product`三个值
- 方法：`GET`
- 返回结果：

```json
{
    "id": 540,
    "project": 201,
    "scenes": "product",
    "server": "192.168.1.123",
    "server_db": 'gittestdb',
    "server_type": "physical",
    "databases": [],
    "jenkins_job": "gittestprod",
    "address_in": "gittest.example.com",
    "address_ex": "gittest.example.com"
}
```

### 修改项目部署信息
- url: `/api/1.0/project/205/deployment/:scenes`
- scenes的值：`develop`, `test`, `product`三个值
- 方法：`PUT`
- 参数说明

|
名称 | 类型 | 必须 | 描述 | 示例值 |
| --- | --- | --- | --- | --- |
| server_type | String | 是 | 部署服务器类型 | pod、docker、physical |
| server | String | 否 | 部署的服务器名 | gittestdev |
| server_db | String | 否 | 数据库服务器名 | gittestdb |
| address_in | String | 否 | 内网访问地址 | test.example.com |
| address_ex | String | 否 | 外网访问的地址 | test.example.com |
| jenkins_job | String | 否 | jenkins中job的名称(多个用`,`分割) | gittestdev |

