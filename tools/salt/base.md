## Salt基本使用

### 常用命令
- `salt "*" test.ping`: 测试节点是否能通
- `salt "192.168.1.123" cmd.run "uname -a"`: 远程执行`uname -a`命令



### 通过salt操作windows dnscmd
#### 删除域名解析：
```
salt "192.168.1.1" cmd.run "dnscmd /Recorddelete codelieche.com hello A /f"
```
返回结果：
> Deleted A record(s) at codelieche.com  
Command completed successfully.


#### 添加域名解析：
```
salt "192.168.5.116" cmd.run "dnscmd /RecordAdd codelieche.com hello A 192.168.1.123
```

返回结果：

> Add A Record for hello.codelieche.com at codelieche.com  
Command completed successfully.

**注意:**
- 传参的时候，开始是顶级域名，比如：`codelieche.com`
- 然后传的`hello`是二级域名
- 二级域名 + `.` + 顶级域名就是要解析的域名: `hello.codelieche.com`





