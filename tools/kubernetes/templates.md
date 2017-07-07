## confd模版编写
> confd的模版是go模版，然后通过模版来生成配置文件。


### 模版函数

#### base

Alias for the path.Base function.

```
{{with get "/key"}}
    key: {{base .Key}}
    value: {{.Value}}
{{end}}
```
**注意：**Key和Value首字母大写的

#### exists
检查键是否存在，如果不存在返回false

```
{{if exists "/key"}}
    value: {{getv "/key"}}
{{end}}
```

#### get
获取key的键值对，如果没有会返回一个错误：

```
{{with get "/key"}}
    key: {{.Key}}
    value: {{.Value}}
{{end}}
```

#### gets
当匹配key的参数，返回所有的键值对，没匹配到key则报错：

```
{{range gets "/study/*"}}
    key: {{.Key}}
    value: {{.Value}}
{{end}}
```

#### getv
获取key的值(字符串),没找到会报错：

```
value: {{getv "/key"}}
```
可以设置了默认值
```
value: {{getv "/key" "default"}}
```

#### getvs
返回匹配到的key的所有值,注意gets是返回键值对：

```
{{range getvs "/*"}}
    value: {{.}}
{{end}}
```

#### getenv
获取系统环境变量的值，可以设置个默认值。

```
export HOSTNAME=`testhost`
```

```
hostname: {{getenv "HOSTNAME"}}
```
设置个默认值：
```
mysqldb: {{getenv "MYSQL_DB", "study"}}
```

#### datetime

```
# confd创建时间：{{datetime}}
```

#### split
`strings.Split`:拆分字符串，并返回列表：

```
{{ $url := split (getv "/study/service") ":" }}
    host: {{index $url 0}}
    port: {{index $url 1}}
```

#### toUpper
返回大写的字符串：`key: {{toUpper "value"}}`

#### toLower
返回小写的字符串：`key: {{toLower "value"}}`

#### json
返回一个json对象。

```
etcdctl set /study/hosts/codelieche '{"domain": "codelieche.com", "ip": "192.168.1.101"}'
etcdctl set /study/hosts/codelieche2 '{"domain": "www.codelieche.com", "ip": "192.168.1.101"}'

```

```
{{range gets "/study/hosts/*"}}
{{$data := json .Value}}
  domain: {{$data.domain}}
  ip: {{$data.ip}}
{{end}}
```


