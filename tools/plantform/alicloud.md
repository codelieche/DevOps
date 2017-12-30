## 阿里云SDK的基本使用

### 参考文档
- [阿里云文档中心](https://www.alibabacloud.com/help/zh)
- [阿里云Python SDK文档](https://www.alibabacloud.com/help/zh/doc-detail/53090.htm)
- [Python SDK 列表](https://www.alibabacloud.com/help/zh/doc-detail/62188.htm)

### 基本使用

#### 安装
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

