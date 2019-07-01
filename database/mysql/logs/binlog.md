### MySQL二进制日志的基本使用

#### 准备工作

- docker启动个MySQL服务

  ```bash
  docker run --name mysql80 -v ~/data/docker/mysql80:/var/lib/mysql \
  -p 3308:3306 \
  -e MYSQL_ROOT_PASSWORD=xxx \
  -d mysql:8.0 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
  ```

- 进入docker容器

  ```bash
  docker exec -it mysql80 /bin/bash
  ```

- 查看二进制日志

  - MySQL 8.0的默认已经开启了二进制日志: 

    ```bash
    root@1fb6aa5953f8:/etc/mysql# mysql --user=root --password=xxx --execute="SHOW VARIABLES LIKE 'log_bin'"
    +---------------+-------+
    | Variable_name | Value |
    +---------------+-------+
    | log_bin       | ON    |
    +---------------+-------+
    ```

  - 查看二进制日志文件: `SHOW BINARY LOGS`

- 二进制相关的配置【mysqld】

  - `log-bin`
  - `binlog-ignore-db=mysql`: 忽略mysql数据库的改动
  - `binlog_expire_logs_seconds=7 * 24 * 3600`: 设置binlog日志文件过期时间
  - `SHOW MASTER STATUS`: 检查二进制日志是否已开启

#### 查看二进制日志

- `SHOW MASTER STATUS`: 显示主服务器中的二进制日志信息

  ```mysql
  mysql> SHOW MASTER STATUS;
  +---------------+----------+--------------+------------------+-------------------+
  | File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
  +---------------+----------+--------------+------------------+-------------------+
  | binlog.000003 |   143766 |              |                  |                   |
  +---------------+----------+--------------+------------------+-------------------+
  1 row in set (0.00 sec)
  ```

- `SHOW MASTER | BINARY LOGS`: 查看使用了哪些日志文件

  ```mysql
  mysql> SHOW MASTER LOGS;
  +---------------+-----------+-----------+
  | Log_name      | File_size | Encrypted |
  +---------------+-----------+-----------+
  | binlog.000001 |   3091158 | No        |
  | binlog.000002 |       178 | No        |
  | binlog.000003 |    143766 | No        |
  +---------------+-----------+-----------+
  3 rows in set (0.00 sec)
  
  mysql> SHOW BINARY LOGS;
  +---------------+-----------+-----------+
  | Log_name      | File_size | Encrypted |
  +---------------+-----------+-----------+
  | binlog.000001 |   3091158 | No        |
  | binlog.000002 |       178 | No        |
  | binlog.000003 |    143766 | No        |
  +---------------+-----------+-----------+
  3 rows in set (0.00 sec)
  ```

- `SHOW BINLOG EVENTS [IN ``'log_name'``] [FROM pos]   ` : 查看日志中进行了哪些操作

  ```mysql
  SHOW BINLOG EVENTS IN 'binlog.000003';
  ```

#### 删除二进制日志

-   `RESET MASTER`: 删除全部的二进制日志, 并且让日志文件重新从**000001**开始

  ```mysql
  mysql> SHOW MASTER STATUS;
  +---------------+----------+--------------+------------------+-------------------+
  | File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
  +---------------+----------+--------------+------------------+-------------------+
  | binlog.000003 |   143766 |              |                  |                   |
  +---------------+----------+--------------+------------------+-------------------+
  1 row in set (0.00 sec)
  
  mysql> RESET MASTER;
  Query OK, 0 rows affected (0.41 sec)
  
  mysql> SHOW MASTER STATUS;
  +---------------+----------+--------------+------------------+-------------------+
  | File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
  +---------------+----------+--------------+------------------+-------------------+
  | binlog.000001 |      155 |              |                  |                   |
  +---------------+----------+--------------+------------------+-------------------+
  1 row in set (0.00 sec)
  ```

- `PURGE  BINARY|MASTER LOGS { TO 'log_name' BEFORE datetime_expr}` 

  - `PURGE BINARY LOGS TO "binlog.000005"`: 删除000005之前的日志文件

  - `PURGE MASTER LOGS BEFORE 'yyyy-mm-dd hh:mi:ss'`: 删除指定日志之前的所有日志

    > 如果指定的时间，处在正在使用的日志文件中，将无法进行PURGE操作。

    ```mysql
    mysql> PURGE BINARY LOGS BEFORE '2019-07-01 07:32:00';
    Query OK, 0 rows affected, 1 warning (0.01 sec)
    
    mysql> SHOW WARNINGS;
    +---------+------+------------------------------------------------------------------------+
    | Level   | Code | Message                                                                |
    +---------+------+------------------------------------------------------------------------+
    | Warning | 1868 | file ./binlog.000001 was not purged because it is the active log file. |
    +---------+------+------------------------------------------------------------------------+
    1 row in set (0.00 sec)
    ```

- **查看/设置binlog文件保存时间**

  > 注意：老的是用`expire_logs_days` 在新版中已经废弃, 推荐使用：`binlog_expire_logs_seconds`.

  - 查看：`SHOW VARIABLES LIKE 'binlog_expire_logs_seconds'` 不设置的话默认是0【不过期】

  - 设置：`SET GLOBAL binlog_expire_logs_seconds=7 * 24 * 3600`

    ```mysql
    mysql> SHOW VARIABLES LIKE 'binlog_expire_logs_seconds';
    +----------------------------+---------+
    | Variable_name              | Value   |
    +----------------------------+---------+
    | binlog_expire_logs_seconds | 2592000 |
    +----------------------------+---------+
    1 row in set (0.00 sec)
    
    mysql> SET GLOBAL binlog_expire_logs_seconds=7 * 24 * 3600;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> SHOW VARIABLES LIKE 'binlog_expire_logs_seconds';
    +----------------------------+--------+
    | Variable_name              | Value  |
    +----------------------------+--------+
    | binlog_expire_logs_seconds | 604800 |
    +----------------------------+--------+
    1 row in set (0.00 sec)
    ```

    **说明：2592000 / 3600 / 24 = 30**

- 刷新日志: `FLUSH LOGS` 

  ```mysql
  mysql> SHOW BINARY LOGS;
  +---------------+-----------+-----------+
  | Log_name      | File_size | Encrypted |
  +---------------+-----------+-----------+
  | binlog.000001 |       155 | No        |
  +---------------+-----------+-----------+
  1 row in set (0.00 sec)
  
  mysql> FLUSH LOGS;
  Query OK, 0 rows affected (0.04 sec)
  
  mysql> SHOW BINARY LOGS;
  +---------------+-----------+-----------+
  | Log_name      | File_size | Encrypted |
  +---------------+-----------+-----------+
  | binlog.000001 |       199 | No        |
  | binlog.000002 |       155 | No        |
  +---------------+-----------+-----------+
  2 rows in set (0.00 sec)
  ```

  

