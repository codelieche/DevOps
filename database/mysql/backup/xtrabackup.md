## xtrabackup的基本使用

### 安装

#### Debain/Ubuntu安装2.4版本

```bash
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
# 查看文件
/etc/apt/sources.list.d/percona-release.list

# 更新
sudo apt-get update
# 安装
sudo apt-get install percona-xtrabackup-24
```

- 卸载

  ```bash
  sudo apt-get remove percona-xtrabackup-24
  ```

- 查看

  ```bash
  test@localhost:~$ which xtrabackup
  /usr/bin/xtrabackup
  ```

### 常用参数

- `—user=name`: 数据库用户名
- `—password=name`: 数据库账号密码
- `—defaults-file=name`: 默认是`/etc/my.cnf`MySQL的配置【会从中读取datadir的数据拷贝至指定备份目录】
- `—incremetal-basedir=name`: 全量备份的目录，增量备份的时候会用到
- `—incremetal name`: 增量备份保存目录

### 基本使用

#### 全量备份

```bash
innobackupex --defaults-file=/etc/my.cnf --user=root --password="xxxxx" --backup /root/backup
```

输出日志：

```
190704 11:39:03 Executing UNLOCK BINLOG
190704 11:39:03 Executing UNLOCK TABLES
190704 11:39:03 All tables unlocked
190704 11:39:03 Backup created in directory '/root/backup/2019-07-04_11-38-33/'
190704 11:39:03 [00] Writing /root/backup/2019-07-04_11-38-33/backup-my.cnf
190704 11:39:03 [00]        ...done
190704 11:39:03 [00] Writing /root/backup/2019-07-04_11-38-33/xtrabackup_info
190704 11:39:03 [00]        ...done
xtrabackup: Transaction log of lsn (1386979555) to (1386979555) was copied.
190704 11:39:04 completed OK!
```

查看目录：

```
root@546c948f8d-qqd5f:~/backup# tree /root/backup/ -L 2
/root/backup/
`-- 2019-07-04_11-38-33
    |-- 004
    |-- backup-my.cnf
    |-- codelieche
    |-- ibdata1
    |-- mysql
    |-- performance_schema
    |-- test
    |-- xtrabackup_checkpoints
    |-- xtrabackup_info
    `-- xtrabackup_logfile
```



### 删除数据表

```sql
mysql> SHOW TABLES;
+----------------------+
| Tables_in_codelieche |
+----------------------+
| users                |
+----------------------+
1 row in set (0.00 sec)

mysql> SELECT * FROM users;
+----+-------+-----+----------------------+
| id | name  | age | email                |
+----+-------+-----+----------------------+
|  1 | Tome  |  18 | tome@example.com     |
|  2 | Jim   |  19 | jim@example.com      |
|  4 | Tome2 |  18 | tome2@codelieche.com |
|  5 | Jim2  |  19 | jim2@example.com     |
+----+-------+-----+----------------------+
4 rows in set (0.00 sec)

mysql> DROP TABLE users;
Query OK, 0 rows affected (0.07 sec)

mysql> SHOW TABLES;
Empty set (0.00 sec)
```



### 恢复数据

#### 恢复测试步骤一

- 不关闭原来的mysql
- 修改mysql的配置，把mysqld的datadir改成：/var/lib/mysql2
- 执行恢复命令
- 修改/var/lib/mysql2目录的权限
- 重启mysql，再次查看

- **从全备中恢复数据**

```
innobackupex --defaults-file=/etc/my.cnf --user=root --password=xxxx --apply-log /root/backup/2019-07-04_11-38-33/
innobackupex --defaults-file=/etc/my.cnf --user=root --password=xxxx --copy-back /root/backup/2019-07-04_11-38-33/
```

- 执行其他命令

  ```bash
  # 修改目录权限
  chown -R mysql. /var/lib/mysql2
  
  # 重启mysql
  service mysql restart
  ```

- 再次查看数据

  ```sql
  mysql> use codelieche;
  Database changed
  
  mysql> show tables;
  +----------------------+
  | Tables_in_codelieche |
  +----------------------+
  | users                |
  +----------------------+
  1 row in set (0.00 sec)
  
  mysql> select * from users;
  +----+-------+-----+----------------------+
  | id | name  | age | email                |
  +----+-------+-----+----------------------+
  |  1 | Tome  |  18 | tome@example.com     |
  |  2 | Jim   |  19 | jim@example.com      |
  |  4 | Tome2 |  18 | tome2@codelieche.com |
  |  5 | Jim2  |  19 | jim2@example.com     |
  +----+-------+-----+----------------------+
  4 rows in set (0.00 sec)
  ```

  数据恢复成功！

  **注意**： 我这个测试实验我选择的是修改datadir的目录。



#### 恢复数据步骤二【推荐】

当然也可以不修改`/var/my.cnf`的配置，执行：

- 关闭数据库：`service mysql stop`

- 移动老的数据库文件：`mv /var/lib/mysql /var/lib/mysql.old`
- 执行恢复命令
- 修改目录权限：`chown -R mysql. /var/lib/mysql`
- 启动mysqld：`service mysql start`

