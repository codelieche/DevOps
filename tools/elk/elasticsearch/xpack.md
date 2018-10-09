## xpack的使用

> 环境：elasticsearch 6.4  
>
> X-Pack是一种Elastic Stack扩展，可提供安全性，警报，监控，报告，机器学习和许多其他功能。默认情况下，安装Elasticsearch 6.3+时会安装X-Pack。

### 参考文档

- [setup-xpack](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-xpack.html)
- [elasticsearch-certutil](https://www.elastic.co/guide/en/elasticsearch/reference/current/certutil.html)



#### elasticsearch-certutil

- elasticsearch-certutil ca

  > 该`ca`模式生成新的证书颁发机构（CA）。默认情况下，它会生成一个PKCS＃12输出文件(`elastic-stack-ca.p12`)，该文件包含CA证书和CA的私钥。如果指定`--pem`参数，该命令将生成一个zip文件，其中包含PEM格式的证书和私钥。
  >
  > 随后可以将这些文件用作`cert`命令模式的输入。



```
$ bin/elasticsearch-certutil ca --pem
# 生成elastic-stack-ca.zip文件

➜  elk tree
.
├── ca
│   ├── ca.crt
│   └── ca.key
├── elastic-stack-ca.p12
└── elastic-stack-ca.zip

1 directory, 4 files
```

- Elasticsearch-certutil cert

  > 该`cert`模式生成X.509证书和私钥。默认情况下，它会生成单个证书和密钥，以便在单个实例上使用。
  >
  > 要为多个实例生成证书和密钥，请指定 `--multiple`参数，该参数会提示您输入有关每个实例的详细信息。或者，您可以使用该`--in`参数指定包含有关实例的详细信息的YAML文件

此命令生成的所有证书都由CA签名。您可以为自己的CA提供`--ca`或`--ca-cert`参数。否则，该命令会自动为您生成新的CA.

默认情况下，该`cert`模式生成一个PKCS＃12输出文件，该文件包含实例证书，实例私钥和CA证书。如果指定`--pem`参数，该命令将生成PEM格式的证书和密钥，并将它们打包为zip文件。如果指定了`--keep-ca-key`，`--multiple`或`--in`参数，所述命令生成包含所生成的证书和密钥的zip文件。



```
bin/elasticsearch-certutil cert --ca-cert /data/certs/elk/ca/ca.crt --ca-key /data/certs/elk/ca/ca.key --pem
```

Elasticsearch.yml: 注意需要读取ce文件的权限

```
xpack.ssl.key: /data/certs/elk/es/elasticsearch.key 
xpack.ssl.certificate: /data/certs/elk/es/elasticsearch.crt 
xpack.ssl.certificate_authorities: /data/certs/elk/ca/ca.crt
xpack.security.transport.ssl.enabled: true
```



