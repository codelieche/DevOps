## 云相关的api

### image api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | cloud/image/list | GET | 获取镜像列表 |
| 2 | cloud/image/:id | GET | 获取镜像详情 |

### Node api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | cloud/node/list | GET | 获取kubernetes的节点列表 |
| 2 | cloud/node/:name | GET | 获取节点详情 |

### Deployment api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | cloud/deployment/list | GET | 获取Deployment列表 |
| 2 | cloud/deployment/:name | GET | 获取Deployment详情 |
| 3 | cloud/deployment/create | POST | 创建Deployment |
| 4 | cloud/deployment/delete | POST | 删除Deployment【用POST方法哦！】 |
| 5 | cloud/data/deployment/create | POST | 创建数据库部署 |

### Pod api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | cloud/pod/list | GET | 获取Pod列表 |
| 2 | cloud/pod/:name | GET | 获取Pod详情 |

### other api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | cloud/vote/host | POST | 获取nginx负载均衡节点 |


