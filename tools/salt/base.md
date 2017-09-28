## Salt基本使用

### 常用命令
- `salt "*" test.ping`: 测试节点是否能通
- `salt "192.168.1.123" cmd.run "uname -a"`: 远程执行`uname -a`命令



### 通过salt操作windows dnscmd
- 删除域名解析：`salt "192.168.1.1" cmd.run "dnscmd /Recorddelete domain.com sub.domain.com A /f"`
- 添加域名解析：`salt "192.168.5.116" cmd.run "dnscmd /RecordAdd domain.com sub.domain.com A 192.168.1.123`


