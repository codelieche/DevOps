## 增量备份数据恢复

### 一：备份数据

   ```bash
# 先创建目录
mkdir -p /data/backup/full
mkdir -p /data/backup/incremental
   ```

- 1-1：全备

  ```bash
  innobackupex --defaults=/etc/mysql/my.cnf --user=root --password=xxx /data/backup/full/
  ```

  成功日志：

  ```
  190706 17:44:34 [00] Writing /data/backup/full/2019-07-06_17-44-31/xtrabackup_info
  190706 17:44:34 [00]        ...done
  xtrabackup: Transaction log of lsn (13291670773) to (13291670780) was copied.
  190706 17:44:34 completed OK!
  ```

  **得到全备的目录**：`/data/backup/full/2019-07-06_17-44-31/`

- 1-1: 第一次增备

  - 创建数据库codelieche;创建users表;插入大约1W条数据

    ```sql
    -- 创建数据库
    CREATE DATABASE codelieche DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    
    -- 创建表
    CREATE TABLE users (
    	`id` INT PRIMARY KEY AUTO_INCREMENT,
    	`name` VARCHAR(40) NOT NULL COMMENT "用户名",
    	`age` INT UNSIGNED NOT NULL COMMENT "年龄",
    	`email` VARCHAR(100) COMMENT "邮箱"
    ) ENGINE = INNODB COMMENT = "用户表";
    
    -- 插入五条数据
    INSERT INTO users (`name`, `age`, `email`) VALUES
     ("Tome", 18, "tome@example.com"),
     ("Jim", 19, "jim@example.com"),
     ("admin", 26, "admin@example.com"),
     ("Tome2", 18, "tome2@example.com"),
     ("Jim2", 19, "jim2@example.com");
     
     -- 不断的执行下面语句，直到大约有1W条数据
     INSERT INTO users (`name`, `age`, `email`)
     SELECT `name`, `age`, `email` FROM users;
    ```

  - 查看数据

    ```sql
    mysql> SHOW TABLES;
    +----------------------+
    | Tables_in_codelieche |
    +----------------------+
    | users                |
    +----------------------+
    1 row in set (0.00 sec)
    
    mysql> SELECT COUNT(*) FROM users;
    +----------+
    | COUNT(*) |
    +----------+
    |    10240 |
    +----------+
    1 row in set (0.01 sec)
    ```

    插入了10240条数据在users表中

  - 基于全备，进行第一次增备

    ```bash
    innobackupex --defaults=/etc/mysql/my.cnf --user=root --password=xxx --incremental-basedir=/data/backup/full/2019-07-06_17-44-31 --incremental /data/backup/incremental/
    ```

    成功日志：

    ```
    190706 17:54:36 [00] Writing /data/backup/incremental/2019-07-06_17-54-22/xtrabackup_info
    190706 17:54:36 [00]        ...done
    xtrabackup: Transaction log of lsn (13292617277) to (13292617285) was copied.
    190706 17:54:36 completed OK!
    ```

    **得到第一次增量备份，目录为：**`/data/backup/incremental/2019-07-06_17-54-22`

- 第二次增备

  - 插入新的表，而且插入新的数据

    ```sql
    mysql> SHOW TABLES;
    +----------------------+
    | Tables_in_codelieche |
    +----------------------+
    | users                |
    +----------------------+
    1 row in set (0.00 sec)
    
    mysql> SELECT COUNT(*) FROM users;
    +----------+
    | COUNT(*) |
    +----------+
    |    10240 |
    +----------+
    1 row in set (0.00 sec)
    
    mysql> CREATE TABLE users02 SELECT * FROM users WHERE id < 5000;
    Query OK, 3477 rows affected (0.03 sec)
    Records: 3477  Duplicates: 0  Warnings: 0
    
    mysql> SHOW TABLES;
    +----------------------+
    | Tables_in_codelieche |
    +----------------------+
    | users                |
    | users02              |
    +----------------------+
    2 rows in set (0.00 sec)
    ```

  - 基于第一次增备，做第二次增备

    ```bash
    innobackupex --defaults=/etc/mysql/my.cnf --user=root --password=xxx --incremental-basedir=/data/backup/incremental/2019-07-06_17-54-22/ --incremental /data/backup/incremental/
    ```

    成功日志：

    ```
    190706 18:08:24 [00] Writing /data/backup/incremental/2019-07-06_18-08-11/xtrabackup_info
    190706 18:08:24 [00]        ...done
    xtrabackup: Transaction log of lsn (13293300535) to (13293300543) was copied.
    190706 18:08:24 completed OK!
    ```

    **得到第二次增量备份，目录：**`/data/backup/incremental/2019-07-06_18-08-11`

- 第三次增量备份

  - 执行SQL

    创建个新的数据库`codelieche_bak`，而且添加个`users`的表

    ```sql
    mysql> CREATE DATABASE codelieche_bak DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    Connection id:    122425
    Current database: codelieche
    Query OK, 1 row affected (0.00 sec)
    
    mysql> CREATE TABLE codelieche_bak.users SELECT * FROM codelieche.users;
    Query OK, 10240 rows affected (0.10 sec)
    Records: 10240  Duplicates: 0  Warnings: 0
    
    mysql> use codelieche_bak;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A
    
    Database changed
    mysql> SHOW TABLES;
    +--------------------------+
    | Tables_in_codelieche_bak |
    +--------------------------+
    | users                    |
    +--------------------------+
    1 row in set (0.00 sec)
    ```

  - 基于第二次增备，做增量备份

    ```bash
    innobackupex --defaults=/etc/mysql/my.cnf --user=root --password=xxx --incremental-basedir=/data/backup/incremental/2019-07-06_18-08-11/ --incremental /data/backup/incremental/
    ```

    成功日志：

    ```
    190706 18:13:29 [00] Writing /data/backup/incremental/2019-07-06_18-13-21/xtrabackup_info
    190706 18:13:29 [00]        ...done
    xtrabackup: Transaction log of lsn (13294346394) to (13294346402) was copied.
    190706 18:13:29 completed OK!
    ```

    **得到第三次增量备份，目录：**`/data/backup/incremental/2019-07-06_18-13-21/`

  ### 二：查看备份文件

  ### 2-1： 备份目录说明

   - 目录

     ```bash
     root@2119207206-a1zod:/data/backup# tree /data/backup/ -L 2
     /data/backup/               # 数据库备份存储的目录
     |-- full
     |   `-- 2019-07-06_17-44-31 # 全量备份文件
     `-- incremental
         |-- 2019-07-06_17-54-22 # 第1次增量备份
         |-- 2019-07-06_18-08-11 # 第2次增量备份
         `-- 2019-07-06_18-13-21 # 第3次增量备份
     ```

  #### 2-2： 查看xtrabackup_checkpoints

  - 全备：`/data/backup/full/2019-07-06_17-44-31/xtrabackup_checkpoints`

    ```
    backup_type = full-backuped
    from_lsn = 0
    to_lsn = 13291670773
    last_lsn = 13291670780
    compact = 0
    recover_binlog_info = 0
    flushed_lsn = 13291670773
    ```

  - 第1次增备：`/data/backup/incremental/2019-07-06_17-54-22/xtrabackup_checkpoints`

    ```
    backup_type = incremental
    from_lsn = 13291670773
    to_lsn = 13292617277
    last_lsn = 13292617285
    compact = 0
    recover_binlog_info = 0
    flushed_lsn = 13292617277
    ```

  - 第2次增备：`/data/backup/incremental/2019-07-06_18-08-11/xtrabackup_checkpoints`

    ```
    backup_type = incremental
    from_lsn = 13292617277
    to_lsn = 13293300535
    last_lsn = 13293300543
    compact = 0
    recover_binlog_info = 0
    flushed_lsn = 13293300535
    ```

  - 第3次增备：`data/backup/incremental/2019-07-06_18-13-21/xtrabackup_checkpoints`

    ```
    backup_type = incremental
    from_lsn = 13293300535
    to_lsn = 13294346394
    last_lsn = 13294346402
    compact = 0
    recover_binlog_info = 0
    flushed_lsn = 13294346394
    ```

  **注意**：重点查看下`from_lsn`和`to_lsn`.



### 三：还原数据到增量备份2

#### 3-1： 还原步骤

- 停掉MySQL服务：`service mysql stop`
- 移动原来的数据目录：`mv /var/lib/mysql /var/lib/mysql_bak`
- 执行还原相关的命令
- 修改目录权限：`chown -R mysql.mysql /var/lib/mysql`
- 重启MySQL：`service mysql start`
- 校对数据

下面执行下还原前准备

```
service mysql stop

mv /var/lib/mysql /var/lib/mysql_bak
```



#### 3-2：操作还原数据

