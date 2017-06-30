### Account Api

> api前缀：`http://127.0.0.1:8080/api/1.0/`

#### account api list

| ID | API列表 | 描述 |
| --- | --- | --- |
| 1 | account/login/ | 账号登陆 |
| 2 | account/logout | 退出登陆 |

#### 1. 账号登陆

* url: `account/login/`
* method: `POST`

##### 请求参数

| 名称 | 类型 | 是否必须 | 示例值 | 描述 |
| --- | --- | --- | --- | --- |
| username | String | 必须 | admin, admin@codelieche.com | 登陆账号名【推荐】、或者手机号、邮箱 |
| password | String | 必须 | password | 账号密码 |

##### 响应参数

| 名称 | 类型 | 示例值 | 描述 |
| --- | --- | --- | --- |
| status | String | success,failure,error | 登陆是否成功【success是成功】 |
| message | String | 登陆成功,账号密码不正确 | 响应消息内容 |

##### 请求示例

* 请求：

```
✗ http POST http://127.0.0.1:8080/api/1.0/account/login/ username=admin password=123456
HTTP/1.0 200 OK
Allow: POST, OPTIONS
```

* 结果：

```json
{
    "message": "登陆成功",
    "status": "success"
}
```

#### 2. 退出登陆

* url: `account/logout/`
* method: `GET`

##### 响应参数

| 名称 | 类型 | 示例值 | 描述 |
| --- | --- | --- | --- |
| status | String | success | 退出登陆是否成功【一般都是success】 |
| next | String | / | 下一步跳转的url |

###### 请求示例

* 请求：`http GET http://127.0.0.1:8080/api/1.0/account/logout/`

* 结果

```json
{
    "next": "/",
    "status": "success"
}
```



