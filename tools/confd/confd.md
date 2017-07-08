## confd基本使用

> confd通过读取配置（支持etcd，consul，环境变量），通过go的模板，生成最终的配置文件。

### Template Resources
- 模版资源文件位置：`/etc/confd/conf.d`

#### 必须的字段
- `dest`: 目标文件
- `keys`: 键的数组
- `src`: 配置模版【模版存储在`/etc/confd/templates`下】

#### 可选的参数
- `gid`:（INT）拥有该文件中的GID，默认为有效gid
- `mode`: (String)该文件的许可模式
- `uid`: (INT)应该拥有该文件的UID
- `reload_cmd`: （String）重新加载配置的命令
- `check_cmd`: （String）检查配置的命令。使用{{`.src`}}引用渲染源模版
- `prefix`: （String）键的前缀

#### 示例
文件位置：`/etc/confd/conf.d/study.toml`

```
[template]
src = "study.tmpl"
dest = "/data/etcd/study.log"
keys = [
  "/study",
]
```

### Templates
- 模版文件定义了一个应用程序的配置模版，根据key值的变化，生成新的文件，默认位置：`/etc/confd/templates`


#### 示例
文件位置：`/etc/confd/templates/study.tmpl`

```
#这个是会变换的文件
{{range gets "/study/*"}}
   {{.Key}}:{{.Value}}
{{end}}
-----------------------
{{range getvs "/study/*"}}
  使用getvs取值：{{.}}
{{end}}
```

#### 执行confd
执行一次并退出：
```
confd -onetime -backend etcd -node http://localhost:2379
```

然后查看`/data/etcd/study.log`就可以看到更新的文件了。

```
➜  ~ etcdctl set /study/key1 "value1"
value1
➜  ~ etcdctl set /study/key2 "value2"
value2
➜  ~ etcdctl set /study/key3 "value3"
value3
➜  ~ confd -onetime -backend etcd -node http://localhost:2379
....
➜  ~ cat /data/etcd/study.log
#这个是会变换的文件

   /study/key1:value1

   /study/key2:value2

   /study/key3:value3

-----------------------

  使用getvs取值：value1

  使用getvs取值：value2

  使用getvs取值：value3
```  

每隔60秒刷新一次：

```
confd -interval 60 -backend etcd -node http://192.168.9.101:4001 -node http://192.168.9.102:4001
```