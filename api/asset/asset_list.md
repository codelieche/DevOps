### Asset API List

#### 1. Group api list
| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | asset/group/list | GET | 分组列表 |
| 2 | asset/group/create | POST | 创建分组 |
| 3 | asset/group/2 | GET | 获取id为2的分组详情 |
| 4 | asset/group/2 | PUT | 修改分组信息 |
| 5 | asset/group/2 | DELETE | 删除分组 |


#### 2. Category api list
| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | asset/category/list | GET | 分类列表 |
| 2 | asset/category/create | POST | 创建分类 |
| 3 | asset/category/2 | GET | 获取id为2的分类详情 |
| 4 | asset/category/2 | PUT | 修改分类信息 |
| 5 | asset/category/2 | DELETE | 删除分类 |

#### 3. IP api list
| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | asset/ip/list | GET | 获取IP列表（带分页功能） |
| 2 | asset/ip/all | GET | 获取IP列表（一次获取全部） |
| 3 | asset/ip/create | POST | 创建IP |
| 4 | asset/ip/2 | GET | 获取id为2的IP详情 |
| 5 | asset/ip/2 | PUT | 修改IP信息 |
| 6 | asset/ip/2 | DELETE | 删除IP |


> 由于Group和Category获取列表的时候，我们一般想获取到全部(一般分组和分类不会太多)，所以不需要加分页功能。  
但是IP对象比较多，获取列表页的时候，一次不用取出全部，加了分页功能的，默认一页只取10条数据。  
而`asset/ip/all`是一次取出全部的IP列表。

#### 4. Domain api list
| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | asset/domain/list | GET | 获取域名列表（带分页功能） |
| 2 | asset/domain/all | GET | 获取域名列表（一次获取全部） |
| 3 | asset/domain/create | POST | 创建域名 |
| 4 | asset/domain/2 | GET | 获取id为2的域名详情 |
| 5 | asset/domain/2 | PUT | 修改域名信息 |
| 6 | asset/domain/2 | DELETE | 删除域名 |

#### 5. DNS api list
| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | asset/dns/list | GET | 获取DNS列表（带分页功能） |
| 2 | asset/dns/create | POST | 创建DNS |
| 3 | asset/dns/2 | GET | 获取id为2的DNS详情 |
| 4 | asset/dns/2 | PUT | 修改DNS信息 |
| 5 | asset/dns/2 | DELETE | 删除DNS | 

#### 6. IDC api list
| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | asset/idc/list | GET | 获取IDC列表 |
| 2 | asset/idc/create | POST | 创建IDC |
| 3 | asset/idc/2 | GET | 获取id为2的IDC详情 |
| 4 | asset/idc/2 | PUT | 修改IDC信息 |
| 5 | asset/idc/2 | DELETE | 删除IDC |

 #### 7. Host api list
| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | asset/host/list | GET | 获取Host列表（带分页功能） |
| 2 | asset/host/all | GET | 获取Host列表（一次获取全部） |
| 3 | asset/host/create | POST | 创建Host |
| 4 | asset/host/2 | GET | 获取id为2的Host详情 |
| 5 | asset/host/2 | PUT | 修改Host信息 |
| 6 | asset/host/2/history | GET | 获取Host的历史记录信息 |
| 7 | asset/host/2 | DELETE | 删除Host |

#### 8. History api list
| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | asset/history/list | GET | 获取history列表 |
| 2 | asset/history/create | POST | 创建history |
| 3 | asset/history/2 | GET | 获取id为2的history详情 |
| 4 | asset/history/2 | PUT | 修改history信息 |
| 5 | asset/history/2 | DELETE | 删除history |








