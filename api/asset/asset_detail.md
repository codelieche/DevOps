### Asset API Detail

#### 1. Group

###### 1-1. asset/group/list
- url: `http://127.0.0.1:8080/api/1.0/asset/group/list`
- 方法：`GET`
- 结果：

```json
[
    {
        "id": 1,
        "name": "AliYun",
        "parent": null,
        "description": "阿里云服务器",
        "children": []
    },
    {
        "id": 2,
        "name": "AWS",
        "parent": null,
        "description": "这个是描述内容",
        "children": []
    }
]
```

###### 1-2. asset/group/create
- url: `http://127.0.0.1:8080/api/1.0/asset/group/create/`
- 方法：`POST`【需要管理员权限】
- 参数说明：

| 名称 | 类型 | 必须 | 示例值 | 描述 |
| --- | --- | --- | --- | --- |
| name | String | 是 | aliyun、aws | 分组名称 |
| description | String | 否 | 随便描述一下 | 描述内容 |
| parent | Number | 否 | 1 | 父分组 |

- 示例:

```json
✗ http -a admin:123456 POST http://127.0.0.1:8080/api/1.0/asset/group/create/ name="阿里云-华南区" description="华南区·深圳" parent=1
HTTP/1.0 201 Created
Allow: POST, OPTIONS
......

{
    "children": [],
    "description": "华南区·深圳",
    "id": 3,
    "name": "阿里云-华南区",
    "parent": 1
}
```

###### 1-3. asset/group/3
- url: `http://127.0.0.1:8080/api/1.0/asset/group/49/`
- 方法: `GET`
- 示例：

```json
http GET http://127.0.0.1:8080/api/1.0/asset/group/3/
HTTP/1.0 200 OK
Allow: GET, PUT, PATCH, DELETE, HEAD, OPTIONS
.....

{
    "children": [],
    "description": "华南区·深圳",
    "id": 3,
    "name": "阿里云-华南区",
    "parent": 1
}
```

##### 1.4 group 更新
- url: `http://127.0.0.1:8080/api/1.0/asset/group/3`
- 方法: `PUT`【需要权限】
- 参数说明：同`asset/group/create`
- 示例：

```json
✗ http -a admin:123456 PUT http://127.0.0.1:8080/api/1.0/asset/group/3 name="AliYun-HuaNanQu" description="华南区·深圳" parent=1
HTTP/1.0 200 OK
Allow: GET, PUT, PATCH, DELETE, HEAD, OPTIONS
.....

{
    "children": [],
    "description": "华南区·深圳",
    "id": 3,
    "name": "AliYun-HuaNanQu",
    "parent": 1
}
```

##### 1.5 group 删除
- url: `http://127.0.0.1:8080/api/1.0/asset/group/3`
- 方法: `DELETE`【需要权限】
- 示例：

```json
http -a admin:123456 DELETE http://127.0.0.1:8080/api/1.0/asset/group/3
HTTP/1.0 204 No Content
Allow: GET, PUT, PATCH, DELETE, HEAD, OPTIONS
Content-Length: 0
Date: Sun, 02 Jul 2017 07:36:24 GMT
Server: WSGIServer/0.2 CPython/3.5.3
Vary: Accept, Cookie
X-Frame-Options: SAMEORIGIN
```
