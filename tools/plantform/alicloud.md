## 阿里云SDK的基本使用

### 参考文档
- [api.aliyun.com](https://api.aliyun.com/)
- [阿里云文档中心](https://www.alibabacloud.com/help/zh)
- [阿里云开发指南--API文档](https://help.aliyun.com/document_detail/29739.html)
- [阿里云开发者工具包(SDK)](https://develop.aliyun.com/tools/sdk?#/python)
- [阿里云Python SDK文档](https://www.alibabacloud.com/help/zh/doc-detail/53090.htm)
- [Python SDK 列表](https://www.alibabacloud.com/help/zh/doc-detail/62188.htm)
- 会用到的其它帮助文章
  1. [创建访问密钥](https://www.alibabacloud.com/help/zh/doc-detail/28647.htm)
  2. [阿里云地域和可用区域](https://www.alibabacloud.com/help/zh/doc-detail/40654.htm)

### 安装
> 无论您选择哪种方式安装 SDK 或需要使用哪个云产品的 SDK，都必须安装阿里云 SDK 核心库（aliyun-python-sdk-core）.  
注意python3的是：`aliyun-python-sdk-core-v3`

通过pip安装：

```shell
pip install aliyun-python-sdk-core # 安装阿里云SDK核心库
pip install aliyun-python-sdk-core-v3 # python3.x用这个命令
```

#### Python SDK List

产品SDK | PIP安装命令
--- | ---
SDK核心库 | pip install aliyun-python-sdk-core
云服务器 | pip install aliyun-python-sdk-ecs
对象存储 OSS | pip install oss2
CDN | pip install aliyun-python-sdk-cdn
阿里云关系型数据库 | pip install aliyun-python-sdk-rds
云监控 | pip install aliyun-python-sdk-cms
视频直播 | pip install aliyun-python-sdk-live
域名 | pip install aliyun-python-sdk-domain
E-MapReduce | pip install aliyun-python-sdk-emr
密钥管理服务 | pip install aliyun-python-sdk-kms
负载均衡 | pip install aliyun-python-sdk-slb
消息服务 | 从PyPI上获取安装包	-
专有网络 | pip install aliyun-python-sdk-vpc
访问控制 RAM | pip install aliyun-python-sdk-ram
安全令牌 STS | pip install aliyun-python-sdk-sts


#### 安装ecs和domian的sdk
```shell
pip install aliyun-python-sdk-core-v3
pip install aliyun-python-sdk-ecs
pip install aliyun-python-sdk-domain
```

### 基本使用
**具体api的使用可以去https://api.aliyun.com查看相关语言的Demo。**

#### 创建Access Key
**注意：**推荐使用子账号分配不同的权限。在管理控制台，鼠标移到用户名的导航栏处，会出现`accesskeys`的导航。  
进入Access Key管理界面 >>> 右侧的创建Access Key >>> 发送短信，成功创建Key。

>  Access Key ID和Access Key Secret是您访问阿里云API的密钥，具有该账户完全的权限，请您妥善保管。


### 示例：获取ECS某个区域的实例

```python
import os
import sys
import json

from aliyunsdkcore.client import AcsClient
from aliyunsdkecs.request.v20140526 import DescribeInstancesRequest


aliyun_key_id = os.environ.get('ALIYUN_KEY_ID', '')
aliyun_key_secret = os.environ.get('ALIYUN_KEY_SECRET', '')

if not aliyun_key_id or not aliyun_key_secret:
    print("Access Key的id或者secret为空，程序退出")
    sys.exit(0)
    

def get_region_ecs_instance_info(access_key_id, access_key_secret, region_id):
    """
    获取区域的ECS实例信息
    :param access_key_id: 账号的AccessKey ID
    :param access_key_secret: 账号的访问秘钥
    :param region_id: 云服务器所属的地域ID
    :return: 区域ecs信息的实例列表
    """
    # 第1步：连接
    client = AcsClient(access_key_id, access_key_secret, region_id)

    # 第2步：构造请求
    page_number = 0
    request = DescribeInstancesRequest.DescribeInstancesRequest()
    request.set_accept_format('json')
    request.set_PageSize(10)

    next_flag = True
    instance_list = []

    while next_flag:
        page_number += 1
        request.set_PageNumber(page_number)

        # 第3步：获取当前页的响应数据
        response_bytes = client.do_action_with_exception(request)
        response = json.loads(str(response_bytes, encoding='utf-8'))
        # print(type(response))
        # print(response)
        total_count = response['TotalCount']
        print("当前区域{0}总共获取到了{1}条数据".format(region_id, total_count))
        if total_count == 10:
            next_flag = True
        else:
            # 如果当前取到的条数是10， 就表示可能还有下一页
            next_flag = False
        # 通过看TotalCount查看实例个数
        # {"PageNumber":1,"TotalCount":1,"PageSize":10,"RequestId":"541BA7B7-2769-433E-B631-C7798ECC8599",
        # "Instances":{"Instance":[{"...."ExpiredTime":"2020-06-10T16:00Z"}]}}'

        # 当前页的实例列表
        # 把当前响应的实例加入到instance_list中
        if total_count > 0:
            instance_list.extend(response['Instances']['Instance'])

    # 第4步：返回实例列表
    return instance_list
```

### 示例：获取账号中的域名列表
> 获取域名列表

```python
import os
import sys
import json

from aliyunsdkcore.client import AcsClient
from aliyunsdkdomain.request.v20160511 import QueryDomainListRequest

aliyun_key_id = os.environ.get('ALIYUN_KEY_ID', '')
aliyun_key_secret = os.environ.get('ALIYUN_KEY_SECRET', '')

if not aliyun_key_id or not aliyun_key_secret:
    print("Access Key的id或者secret为空，程序退出")
    sys.exit(0)
    
def get_domian_list():
    # 第1步：创建Access Key的连接
    client = AcsClient(aliyun_key_id, aliyun_key_secret)

    # 第2步：构造请求
    request = QueryDomainListRequest.QueryDomainListRequest()
    request.set_PageSize(1000)
    request.set_accept_format('json')
    request.set_PageNum(1)

    # 第3步：发起请求，获取到二进制数据
    response_bytes = client.do_action_with_exception(request)
    response = json.loads(str(response_bytes, encoding='utf-8'))

    # 第4步：提取域名列表
    domian_list = response['Data']['Domain']
    print(domian_list)

    for domain in domian_list:
        print(domain['DomainName'].ljust(20), '\t:', domain['RegDate'] ,'====>', domain['DeadDate'])

    # 第5步：返回域名数据
    return domian_list
```


