> crontab命令常见于Unix和类Unix的操作系统之中，用于设置周期性被执行的指令。该命令从标准输入设备读取指令，并将其存放于“crontab”文件中，以供之后读取和执行。

## 基本使用
1. `crontab -e` : 编辑执行任务
2. `crontab -l` ：列出当前用户的crontab
3. `crontab -r` ：删除当前用户的作业任务

## 时间参数说明
`eg`:每隔5分钟说hello：`*/5 * * * * say hello`;

```
The time and date fields are:
field          allowed values
-----          --------------
minute         0-59
hour           0-23
day of month   0-31
month          0-12 (or names, see below)
day of week    0-7 (0 or 7 is Sun, or use names)
```

crontab文件的格式 | M H D m d cmd. 
------  | -----
M:  | 分钟（0-59）
H： | 小时（0-23）
D： | 天（1-31）
m:  | 月（1-12）
d:  | 一星期内的天（0~6，0为星期天）
cmd:  |  要执行的命令

## 示例
**每晚的01:30重启nginx:**  
`30 1 * * * /etc/init.d/nginx restart`

**每月5、15、25日的2 : 45重启mysql**  
`45 2 5,15,25 * * /etc/init.d/mysql restart`

**每周二、周日的2 : 30重启nginx:**  
`30 2 * * 2,0 /etc/init.d/nginx restart`

**每天20 : 00至23 : 00之间每隔30分钟重启nginx:**  
`0,30 20-23 * * * /etc/init.d/nginx restart`

**每隔五分钟，运行一次run.sh脚本:**
`*/5 * * * * /usr/local/run.sh`