### mysqlbinlog命令的使用



#### 参数

- `—base64-output=name`: binlog输出语句的base64解码，分为三类
  - `auto` :【默认】仅打印base64编码需要的信息，如：row-based事件和时间的描述信息
  - `never`: 仅适用于不是`row-based`的事件
  - `decode-rows`: 配合`---verbose`选项一起使用解码行事件到带注释的伪SQL语句
- `—bind-address=name`: 要绑定的IP地址
- `—character-sets-dir=name`: 指定字符集的路径
- `—set-charset=name`: 将`SET NAMES character_set`添加到输出中，用于改变binlog的字符集
- `-d, —database=name`: 列出数据库的名称【仅限binlog文件存储在本地】
- `—rewrite-db=name`: 将binlog中的事件信息重定向到新的数据库

##### 调试相关参数

- `-#, —debug[=#]`:  非调试版本，获取调试信息并退出
- `—debug-check`: 非调试版本，获取调试信息并退出
- `—debug-info`: 非调试版本，获取调试信息并退出
- `—default-auth=name`: 默认使用的客户端认证插件



##### 常用选项

- `—start-datetime=name`: binlog文件读取的起始事件点，可接受datetime和timestamp类型
- `—stop-datetime=name`: binlog文件的结束的时间点
- `-j, —start-position=#`: 读取binlog文件的位置信息
- `—stop-position=#`: binlog文件的结束的位置信息
- `-v, —verbose`: 重新构建**伪SQL**语句的行信息输出，`-v` 会增加列类型的注释信息
- `-V, —version`: mysqlbinlog的版本信息



#### 查看binlog

```bash
mysqlbinlog --base64-output=decode-rows -v ./binlog.000002 --database=codelieche > ~/codelieche_binlog.txt
```

**导出日志内容完成后，用文本编辑器打开codelieche_binlog.txt文件，查找相关的语句。**

##### 查看日志说明

> 二进制日志的每个条目都以两行注释（以#开头的行）开始。
>
> - 第一行注释的号码是位置号，在at后面，可用来指定恢复到哪一点
> - 第二行则记录了语句执行的时间及其他信息
> - 条目以`/*!*/`结尾

#### CREATE语句

```
# at 496
#190702 10:47:45 server id 1  end_log_pos 829 CRC32 0x23449430 	Query	thread_id=23	exec_time=0	error_code=0	Xid = 3526
use `codelieche`/*!*/;
SET TIMESTAMP=1562035665/*!*/;
/*!80013 SET @@session.sql_require_primary_key=0*//*!*/;
CREATE TABLE users ( `id` INT PRIMARY KEY AUTO_INCREMENT, `name` VARCHAR(40) NOT NULL COMMENT "username", `age` INT UNSIGNED NOT NULL COMMENT "UserAge", `email` VARCHAR(100) COMMENT "UserEmail") ENGINE = INNODB COMMENT = "UsersTable"
/*!*/;
# at 829
```

通过上面前2行的数据可得到以下信息：

- 条目位置号: `496`

- 时间和日期：`190702 10:47:45`

- 下一条目的位置号：`820`   end_log_pos 829

  > 位置号不是简单的递增的，它记录的是条目在日志中的位置。

所以我们想恢复创建表的语句，可使用：

```bash
mysqlbinlog --database=codelieche --start-position=496 --stop-position=829 \
  ./binlog.000002 | mysql --user=root --password
```



#### INSERT语句

```
BEGIN
/*!*/;
# at 989
#190702 10:48:13 server id 1  end_log_pos 1056 CRC32 0x8d4cf1d2 	Table_map: `codelieche`.`users` mapped to number 204
# at 1056
#190702 10:48:13 server id 1  end_log_pos 1253 CRC32 0x79b28e16 	Write_rows: table id 204 flags: STMT_END_F
### INSERT INTO `codelieche`.`users`
### SET
###   @1=1
###   @2='Tome'
###   @3=18
###   @4='tome@example.com'
### INSERT INTO `codelieche`.`users`
### SET
###   @1=2
###   @2='Jim'
###   @3=19
###   @4='jim@example.com'
### INSERT INTO `codelieche`.`users`
### SET
###   @1=3
###   @2='admin'
###   @3=26
###   @4='admin@example.com'
### INSERT INTO `codelieche`.`users`
### SET
###   @1=4
###   @2='Tome2'
###   @3=18
###   @4='tome2@example.com'
### INSERT INTO `codelieche`.`users`
### SET
###   @1=5
###   @2='Jim2'
###   @3=19
###   @4='jim2@example.com'
# at 1253
#190702 10:48:13 server id 1  end_log_pos 1284 CRC32 0x45070d66 	Xid = 3529
COMMIT/*!*/;
```

> **BEGIN**和**COMMIT**是事务开始和结束的标志。
>
> 其中，COMMIT会把该范围中的语句提交，而一旦提交，就不能回滚或撤销了。

想恢复插入语句及后面的所有操作，可执行：

```bash
mysqlbinlog --database=codelieche --start-position=989 \
  ./binlog.000002 | mysql --user=root --password
```



#### UPDATE语句

```
# at 1453
#190702 10:48:21 server id 1  end_log_pos 1520 CRC32 0xddf7d365 	Table_map: `codelieche`.`users` mapped to number 204
# at 1520
#190702 10:48:21 server id 1  end_log_pos 1627 CRC32 0xa6776cf7 	Update_rows: table id 204 flags: STMT_END_F
### UPDATE `codelieche`.`users`
### WHERE
###   @1=4
###   @2='Tome2'
###   @3=18
###   @4='tome2@example.com'
### SET
###   @1=4
###   @2='Tome2'
###   @3=18
###   @4='tome2@codelieche.com'
# at 1627
#190702 10:48:21 server id 1  end_log_pos 1658 CRC32 0xcb40fd51 	Xid = 3530
COMMIT/*!*/;
```

#### DELETE语句

```
# at 1885
#190702 10:48:28 server id 1  end_log_pos 1954 CRC32 0x653b1fb5 	Delete_rows: table id 204 flags: STMT_END_F
### DELETE FROM `codelieche`.`users`
### WHERE
###   @1=3
###   @2='admin'
###   @3=26
###   @4='admin@example.com'
# at 1954
#190702 10:48:28 server id 1  end_log_pos 1985 CRC32 0x11ef793a 	Xid = 3531
COMMIT/*!*/;
```



----



- Codelieche_binlog.txt文件内容

```
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=1*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#190702 10:43:49 server id 1  end_log_pos 124 CRC32 0xe463a9b6 	Start: binlog v 4, server v 8.0.16 created 190702 10:43:49
# at 124
#190702 10:43:49 server id 1  end_log_pos 155 CRC32 0x59ab2e24 	Previous-GTIDs
# [empty]
# at 155
#190702 10:44:26 server id 1  end_log_pos 234 CRC32 0x5cc4c184 	Anonymous_GTID	last_committed=0	sequence_number=1	rbr_only=no	original_committed_timestamp=1562035466624515	immediate_commit_timestamp=1562035466624515	transaction_length=262
# original_commit_timestamp=1562035466624515 (2019-07-02 10:44:26.624515 CST)
# immediate_commit_timestamp=1562035466624515 (2019-07-02 10:44:26.624515 CST)
/*!80001 SET @@session.original_commit_timestamp=1562035466624515*//*!*/;
/*!80014 SET @@session.original_server_version=80016*//*!*/;
/*!80014 SET @@session.immediate_server_version=80016*//*!*/;
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 234
#190702 10:44:26 server id 1  end_log_pos 417 CRC32 0x815bc1e2 	Query	thread_id=23	exec_time=0	error_code=0	Xid = 3513
SET TIMESTAMP=1562035466/*!*/;
SET @@session.pseudo_thread_id=23/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=0, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=1168113696/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C latin1 *//*!*/;
SET @@session.character_set_client=8,@@session.collation_connection=8,@@session.collation_server=224/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
/*!80011 SET @@session.default_collation_for_utf8mb4=255*//*!*/;
CREATE DATABASE codelieche DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
/*!*/;
# at 417
#190702 10:47:45 server id 1  end_log_pos 496 CRC32 0xd6405968 	Anonymous_GTID	last_committed=1	sequence_number=2	rbr_only=no	original_committed_timestamp=1562035665309031	immediate_commit_timestamp=1562035665309031	transaction_length=412
# original_commit_timestamp=1562035665309031 (2019-07-02 10:47:45.309031 CST)
# immediate_commit_timestamp=1562035665309031 (2019-07-02 10:47:45.309031 CST)
/*!80001 SET @@session.original_commit_timestamp=1562035665309031*//*!*/;
/*!80014 SET @@session.original_server_version=80016*//*!*/;
/*!80014 SET @@session.immediate_server_version=80016*//*!*/;
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 496
#190702 10:47:45 server id 1  end_log_pos 829 CRC32 0x23449430 	Query	thread_id=23	exec_time=0	error_code=0	Xid = 3526
use `codelieche`/*!*/;
SET TIMESTAMP=1562035665/*!*/;
/*!80013 SET @@session.sql_require_primary_key=0*//*!*/;
CREATE TABLE users ( `id` INT PRIMARY KEY AUTO_INCREMENT, `name` VARCHAR(40) NOT NULL COMMENT "username", `age` INT UNSIGNED NOT NULL COMMENT "UserAge", `email` VARCHAR(100) COMMENT "UserEmail") ENGINE = INNODB COMMENT = "UsersTable"
/*!*/;
# at 829
#190702 10:48:13 server id 1  end_log_pos 908 CRC32 0x8568d603 	Anonymous_GTID	last_committed=2	sequence_number=3	rbr_only=yes	original_committed_timestamp=1562035693950523	immediate_commit_timestamp=1562035693950523	transaction_length=455
/*!50718 SET TRANSACTION ISOLATION LEVEL READ COMMITTED*//*!*/;
# original_commit_timestamp=1562035693950523 (2019-07-02 10:48:13.950523 CST)
# immediate_commit_timestamp=1562035693950523 (2019-07-02 10:48:13.950523 CST)
/*!80001 SET @@session.original_commit_timestamp=1562035693950523*//*!*/;
/*!80014 SET @@session.original_server_version=80016*//*!*/;
/*!80014 SET @@session.immediate_server_version=80016*//*!*/;
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 908
#190702 10:48:13 server id 1  end_log_pos 989 CRC32 0x59c40e6b 	Query	thread_id=23	exec_time=0	error_code=0
SET TIMESTAMP=1562035693/*!*/;
BEGIN
/*!*/;
# at 989
#190702 10:48:13 server id 1  end_log_pos 1056 CRC32 0x8d4cf1d2 	Table_map: `codelieche`.`users` mapped to number 204
# at 1056
#190702 10:48:13 server id 1  end_log_pos 1253 CRC32 0x79b28e16 	Write_rows: table id 204 flags: STMT_END_F
### INSERT INTO `codelieche`.`users`
### SET
###   @1=1
###   @2='Tome'
###   @3=18
###   @4='tome@example.com'
### INSERT INTO `codelieche`.`users`
### SET
###   @1=2
###   @2='Jim'
###   @3=19
###   @4='jim@example.com'
### INSERT INTO `codelieche`.`users`
### SET
###   @1=3
###   @2='admin'
###   @3=26
###   @4='admin@example.com'
### INSERT INTO `codelieche`.`users`
### SET
###   @1=4
###   @2='Tome2'
###   @3=18
###   @4='tome2@example.com'
### INSERT INTO `codelieche`.`users`
### SET
###   @1=5
###   @2='Jim2'
###   @3=19
###   @4='jim2@example.com'
# at 1253
#190702 10:48:13 server id 1  end_log_pos 1284 CRC32 0x45070d66 	Xid = 3529
COMMIT/*!*/;
# at 1284
#190702 10:48:21 server id 1  end_log_pos 1363 CRC32 0xc06e8cbb 	Anonymous_GTID	last_committed=3	sequence_number=4	rbr_only=yes	original_committed_timestamp=1562035701454637	immediate_commit_timestamp=1562035701454637	transaction_length=374
/*!50718 SET TRANSACTION ISOLATION LEVEL READ COMMITTED*//*!*/;
# original_commit_timestamp=1562035701454637 (2019-07-02 10:48:21.454637 CST)
# immediate_commit_timestamp=1562035701454637 (2019-07-02 10:48:21.454637 CST)
/*!80001 SET @@session.original_commit_timestamp=1562035701454637*//*!*/;
/*!80014 SET @@session.original_server_version=80016*//*!*/;
/*!80014 SET @@session.immediate_server_version=80016*//*!*/;
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 1363
#190702 10:48:21 server id 1  end_log_pos 1453 CRC32 0x54614509 	Query	thread_id=23	exec_time=0	error_code=0
SET TIMESTAMP=1562035701/*!*/;
BEGIN
/*!*/;
# at 1453
#190702 10:48:21 server id 1  end_log_pos 1520 CRC32 0xddf7d365 	Table_map: `codelieche`.`users` mapped to number 204
# at 1520
#190702 10:48:21 server id 1  end_log_pos 1627 CRC32 0xa6776cf7 	Update_rows: table id 204 flags: STMT_END_F
### UPDATE `codelieche`.`users`
### WHERE
###   @1=4
###   @2='Tome2'
###   @3=18
###   @4='tome2@example.com'
### SET
###   @1=4
###   @2='Tome2'
###   @3=18
###   @4='tome2@codelieche.com'
# at 1627
#190702 10:48:21 server id 1  end_log_pos 1658 CRC32 0xcb40fd51 	Xid = 3530
COMMIT/*!*/;
# at 1658
#190702 10:48:28 server id 1  end_log_pos 1737 CRC32 0x5c79a568 	Anonymous_GTID	last_committed=4	sequence_number=5	rbr_only=yes	original_committed_timestamp=1562035708287145	immediate_commit_timestamp=1562035708287145	transaction_length=327
/*!50718 SET TRANSACTION ISOLATION LEVEL READ COMMITTED*//*!*/;
# original_commit_timestamp=1562035708287145 (2019-07-02 10:48:28.287145 CST)
# immediate_commit_timestamp=1562035708287145 (2019-07-02 10:48:28.287145 CST)
/*!80001 SET @@session.original_commit_timestamp=1562035708287145*//*!*/;
/*!80014 SET @@session.original_server_version=80016*//*!*/;
/*!80014 SET @@session.immediate_server_version=80016*//*!*/;
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 1737
#190702 10:48:28 server id 1  end_log_pos 1818 CRC32 0x8e65969b 	Query	thread_id=23	exec_time=0	error_code=0
SET TIMESTAMP=1562035708/*!*/;
BEGIN
/*!*/;
# at 1818
#190702 10:48:28 server id 1  end_log_pos 1885 CRC32 0x5508e316 	Table_map: `codelieche`.`users` mapped to number 204
# at 1885
#190702 10:48:28 server id 1  end_log_pos 1954 CRC32 0x653b1fb5 	Delete_rows: table id 204 flags: STMT_END_F
### DELETE FROM `codelieche`.`users`
### WHERE
###   @1=3
###   @2='admin'
###   @3=26
###   @4='admin@example.com'
# at 1954
#190702 10:48:28 server id 1  end_log_pos 1985 CRC32 0x11ef793a 	Xid = 3531
COMMIT/*!*/;
# at 1985
#190702 10:48:34 server id 1  end_log_pos 2029 CRC32 0xa77a2058 	Rotate to binlog.000003  pos: 4
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
```



