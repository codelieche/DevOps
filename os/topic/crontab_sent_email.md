## crontab产生大量的邮件文件

> 在生产环境计划任务调度的机器上面，发现inode被用完了。

```bash
[root@node01 tools]# df -i
Filesystem                        Inodes IUsed     IFree IUse% Mounted on
/dev/mapper/centos-root             2.4M  2.3M       67K    98% /
/dev/sda1                            61K   301       61K     1% /boot
#......
```

后面查询到是/var/spool/postfix/maildrop目录下产生了200W+文件。

#### 产生这些小文件的原因

> 系统执行计划任务的时候，会将脚本中的输出和警告信息，以邮件的形式发送给任务所有者。

#### 解决方式

> 在crontab的第一行加入`MAILTO=""`即可。记得重启计划任务。
>
> - Ubuntu: `service cron restart`
> - CentOS: `systemctl restart crond`

#### 问题复现

​	**注意事项：**是否开启了postfix, 关闭postfix才会产生小文件。测试机器是CentOS。

1. 第一步编写计划任务脚本

   - `/data/tools/test_crontab.sh`

   ```bash
   #!/bin/bash
   echo `date +"%F %T"` start!
   sleep 1
   which  python
   echo `date +"%F %T"` end!
   ```

2. 第二步加入计划任务

   ```bash
   [root@node01 tools]# ls /var/spool/postfix/maildrop/ | wc -l
   0
   [root@node01 tools]# crontab -e
   crontab: installing new crontab
   [root@node01 tools]# crontab -l
   * * * * * bash /data/tools/test_crontab.sh
   ```

   过了不久执行命令提示：`You have new mail in /var/spool/mail/root`

   ```
   [root@node01 mail]# tail /var/spool/mail/root
   X-Cron-Env: <PATH=/usr/bin:/bin>
   X-Cron-Env: <LOGNAME=root>
   X-Cron-Env: <USER=root>
   Message-Id: <20190324040303.0A799402DF54@node01.localdomain>
   Date: Sun, 24 Mar 2019 12:03:02 +0800 (CST)
   
   2019-03-24 12:03:02 start!
   /usr/bin/python
   2019-03-24 12:03:03 end!
   ```

   这是因为**开启了postfix**，所以邮件并未堆积在`/var/spool/postfix/maildrop/`

   - 关闭postfix【注意事项】

   ```bash
   [root@node01 mail]# service postfix stop
   Redirecting to /bin/systemctl stop postfix.service
   ```

   再过几分钟，进入下一步！

3. 第三步查看是否创建小文件, 以及查看文件内容

   ```bash
   [root@node01 mail]# ls /var/spool/postfix/maildrop/
   3CDD6604F980
   [root@node01 mail]# cat /var/spool/postfix/maildrop/3CDD6604F980
   T1553400421 249059Arewrite_context=localF
   CronDaemonSrootMNFrom: "(Cron Daemon)" <root>To: rootN=Subject: Cron <root@node01> bash /data/tools/test_crontab.sh N'Content-Type: text/plain; charset=UTF-8NAuto-Submitted: auto-generatedNPrecedence: bulkN X-Cron-Env: <XDG_SESSION_ID=174>N)X-Cron-Env: <XDG_RUNTIME_DIR=/run/user/0>NX-Cron-Env: <LANG=en_US.UTF-8>N-Cron-Env: <SHELL=/bin/sh>NX-Cron-Env: <HOME=/root>N X-Cron-Env: <PATH=/usr/bin:/bin>NX-Cron-Env: <LOGNAME=root>NX-Cron-Env: <USER=root>NN2019-03-24 12:07:01 start!N/usr/bin/pythonN2019-03-24 12:07:02 end!XRrootE
   ```

   **再次统计文件个数：**

   ```bash
   [root@node01 mail]# ls /var/spool/postfix/maildrop/ | wc -l
   5
   ```

4. 第四步加入`MAILTO=""`

   ```bash
   [root@node01 mail]# ls /var/spool/postfix/maildrop/ | wc -l
   9
   [root@node01 mail]# crontab -l
   MAILTO=""
   * * * * * bash /data/tools/test_crontab.sh
   [root@node01 mail]# systemctl restart crond
   ```

5. 第五步再次监控小文件是否增加

   过几分钟再次查看**无新文件产生**

   ```bash
   [root@node01 mail]# ls /var/spool/postfix/maildrop/ | wc -l
   9
   ```
