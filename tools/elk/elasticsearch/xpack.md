## xpack的使用

> 环境：elasticsearch 6.4  
>
> X-Pack是一种Elastic Stack扩展，可提供安全性，警报，监控，报告，机器学习和许多其他功能。默认情况下，安装Elasticsearch 6.3+时会安装X-Pack。

### 参考文档

- [setup-xpack](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-xpack.html)
- [elasticsearch-certutil](https://www.elastic.co/guide/en/elasticsearch/reference/current/certutil.html)

先开启试用，会有30天的试用期限。

```
curl -H "Content-Type:application/json" -XPOST  http://localhost:9200/_xpack/license/start_trial?acknowledge=true
```

或者去kibana中点击试用：`Management >> Elasticsearch >> License Management >> 开启试用`

#### 1: 生成证书文件

先进入elasticsarch的安装目录：比如：`/usr/share/elasticsearch`

**如果集群由多台机器，需要把证书复制到相应的位置**

```bash
# 先进入elasticsearch的目录
cd /usr/share/elasticsearch
./bin/elasticsearch-certutil ca --ca-dn "CN=ELastic Study" --out ./config/certs/elastic-stack-ca.p12
# 回车，密码设置为空
./bin/elasticsearch-certutil cert -ca ./config/certs/elastic-stack-ca.p12 --out ./config/certs/elastic-certificates.p12
# 修改权限
chmod 755 -R ./config/certs
```

#### 2：修改配置文件

- **注意**：证书文件是需要放在配置目录中，比如：`/etc/elasticsearch`
- **注意**：权限的控制，证书的权限，如果出错，注意看es的日志

```
#添加如下代码打开x-pack安全验证
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true

xpack.security.transport.ssl.verification_mode: certificate 
xpack.security.transport.ssl.keystore.path: certs/elastic-certificates.p12 
xpack.security.transport.ssl.truststore.path: certs/elastic-certificates.p12
```

出现权限问题会报：

```bash
java.security.AccessControlException: access denied ("java.io.FilePermission" "/etc/elasticsearch/certs/elastic-certificates.p12" "read")
```

### 3. 生成账号密码

```
$ ./bin/elasticsearch-setup-passwords auto
Initiating the setup of passwords for reserved users elastic,apm_system,kibana,logstash_system,beats_system,remote_monitoring_user.
The passwords will be randomly generated and printed to the console.
Please confirm that you would like to continue [y/N]y


Changed password for user apm_system
PASSWORD apm_system = xxxxx

Changed password for user kibana
PASSWORD kibana = xxxxx

Changed password for user logstash_system
PASSWORD logstash_system = xxxxx

Changed password for user beats_system
PASSWORD beats_system = xxxxx

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = xxxxx

Changed password for user elastic
PASSWORD elastic = xxxxx
```

#### 4. 配置LDAP登录

```yml
xpack:
  security:
    authc:
      realms:
        active_directory:
          type: active_directory
          order: 1
          domain_name: codelieche.com
          url: "ldap://192.168.1.123:389"
          # bind_dn: admin@codelieche.com
          # bind_password: ThisIsPassword
```

#### 5. 在kibana中给ldap用户创建个readonly的组和映射关系

```bash
POST _xpack/security/role_mapping/ldap_user_readonly?pretty
{
  "roles": [ "readonly" ],
 "enabled": true,
   "rules": {
     "any": [
       {
         "field": {
           "username": "*"
         }
       }
     ]
   }
}
```

- 查看角色映射关系：`GET _xpack/security/role_mapping`
- 查看某个映射：`GET _xpack/security/role_mapping/ldap_user_admin?pretty`
- 删除某个映射：`DELETE _xpack/security/role_mapping/ldap_user_admin`

> 配置了readonly的角色，登录kibana就可以查看相关信息了。

