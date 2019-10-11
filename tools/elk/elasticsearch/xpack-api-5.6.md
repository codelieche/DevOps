## xpack api基本使用

> 版本：5.6.4
>
> 安装：`./bin/elasticsearch-plugin install x-pack`

https://www.elastic.co/guide/en/elasticsearch/reference/5.6/xpack-api.html

安装xpack后，默认的账号密码为：`elastic : changeme`

### Security APIS



#### Authenticate API

- `curl -X GET "localhost:9200/_xpack/security/_authenticate?pretty"`

- 示例：

  ```bash
  [root@node01 5.6.4]# curl http://127.0.0.1:9200/_xpack/security/_authenticate?pretty -u elastic:changeme
  {
    "username" : "elastic",
    "roles" : [
      "superuser"
    ],
    "full_name" : null,
    "email" : null,
    "metadata" : {
      "_reserved" : true
    },
    "enabled" : true
  }
  ```

  如果账号密码错误，会输出401：

  ```bash
  {
    "error" : {
      ....},
    "status" : 401
  }
  ```

#### Change Password API

- 请求

  ```bash
  POST _xpack/security/user/elastic/_password
  {
    "password": "changeme"
  }
  ```

- 示例：

  ```bash
  [root@node01 5.6.4]# curl -X POST http://localhost:9200/_xpack/security/user/elastic/_password?pretty \
  > -u elastic:changeme -H 'Content-Type: application/json' \
  > -d '{"password": "newpassword"}'
  { }
  ```

  成功输出的是：`{ }`



#### Users Management APIs

- 创建用户：

  ```bash
  POST /_xpack/security/user/jacknich
  {
    "password" : "j@rV1s",
    "roles" : [ "admin", "other_role1" ],
    "full_name" : "Jack Nicholson",
    "email" : "jacknich@example.com",
    "metadata" : {
      "intelligence" : 7
    }
  }
  ```

  - 参数：
    - `password`: 密码【Required
    - `roles`: 角色【Required】
    - `full_name`、`email`、`metadata`：[选填]

- 获取用户：

  - 获取单个用户：`GET /_xpack/security/user/:name`
  - 获取多个用户：`GET /_xpack/security/user/:name,:name2`
  - 获取所有用户：`GET /_xpack/security/user`

- 修改用户密码：

  ```bash
  PUT /_xpack/security/user/jacknich/_password
  {
    "password" : "s3cr3t"
  }
  ```

- 开启、禁用或者删除用户

  - 开启：`PUT /_xpack/security/user/:name/_enable`
  - 禁用：`PUT /_xpack/security/user/:name/_disable`
  - 删除：`DELETE /_xpack/security/user/:name`

  

#### Role Management APIs

- 创建角色：

  ```bash
  POST /_xpack/security/role/my_admin_role
  {
    "cluster": ["all"],
    "indices": [
      {
        "names": [ "index1", "index2" ],
        "privileges": ["all"],
        "field_security" : { // optional
          "grant" : [ "title", "body" ]
        },
        "query": "{\"match\": {\"title\": \"foo\"}}" // optional
      }
    ],
    "run_as": [ "other_user" ], // optional
    "metadata" : { // optional
      "version" : 1
    }
  }
  ```

  成功的话，返回：

  ```json
  {
    "role": {
      "created": true 
    }
  }
  ```

- 查看Role：

  ```bash
  GET /_xpack/security/role/:role_name
  GET /_xpack/security/role/:role1,:role2
  GET /_xpack/security/role
  ```

- 删除Role：

  ```bash
  DELETE /_xpack/security/role/:role_name
  ```



#### Role Mapping APIs

- 创建Role Mapping：

  ```bash
  POST /_xpack/security/role_mapping/administrators
  {
    "roles": [ "user", "admin" ],
    "enabled": true, 
    "rules": {
       "field" : { "username" : [ "esadmin01", "esadmin02" ] }
    },
    "metadata" : { 
      "version" : 1
    }
  }
  ```

  成功的话返回：

  ```json
  {
    "role_mapping" : {
      "created" : true 
    }
  }
  ```

- 查看:

  ```bash
  GET /_xpack/security/role_mapping
  GET /_xpack/security/role_mapping/:role_mapping_name
  ```

- 删除Role Mapping

  ```bash
  DELETE /_xpack/security/role_mapping/:role_mapping_name
  ```





