## Elasticsearch 权限控制

> 环境：elasticsearch6.3+，默认安装后，开始做如下操作



### 设置密码: elasticsearch-setup-passwords

- 进入es的安装目录：`cd ~/elasticsearch/6.3.2/bin`
- 查看帮助：`./elasticsearch-setup-passwords -h`

```
➜  bin ./elasticsearch-setup-passwords -h
Sets the passwords for reserved users

Commands
--------
auto - Uses randomly generated passwords
interactive - Uses passwords entered by a user

Non-option arguments:
command              

Option         Description        
------         -----------        
-h, --help     show help          
-s, --silent   show minimal output
-v, --verbose  show verbose output
```

- 自动修改密码：`./elasticsearch-setup-passwords auto`

**遇到的问题：**

```
It doesn't look like the X-Pack security feature is available on this Elasticsearch node.

Please check if you have installed a license that allows access to X-Pack Security feature.

```

**解决方式：**再es和kibana的配置文件中加入：`xpack.security.enabled: false`

再次执行命令

