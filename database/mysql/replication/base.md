## MySQL复制的基本使用

> 复制功能是构建基于MySQL的大规模、高性能应用的基础。  
>
> 复制可以让一台MySQL服务器的数据与其它的服务器数据保持同步。一台主库的数据可以同步到多台从库。
>
> 复制有两种方式：一个是基于行的复制(逻辑复制)和基于语句的复制。

### 使用复制的步骤

1. 开启二进制日志：在主库上把数据库更改记录到二进制日志
2. 备库开启Relay Log: 备库将主库上的日志复制到自己的Relay log(中继日志)中



### 搭建主从数据库

#### 准备Docker镜像

- [MySQL Dockerfile](https://github.com/codelieche/notebooks/tree/master/dockerfile/mysql)

- 配置文件：`my.cnf`

  ```
  # .....
  mysqld]
  pid-file      = /var/run/mysqld/mysqld.pid
  socket        = /var/run/mysqld/mysqld.sock
  datadir       = /var/lib/mysql
  server_id = 20191203
  log_bin                         = mysql-bin.log       # 二进制日志名 /var/log/mysql/mysql-bin.log 
  binlog_format                   = ROW                 # 如无其他考虑采用行格式
  expire_logs_days                = 3                   # 二进制日志过期期限3天
  max_binlog_size                 = 100M                # 二进制日志大小
  # ....
  ```

- 执行构建镜像：

  ```bash
  cd 5.6
  docker build . -t mysql:56-v1
  docker tag mysql:56-v1 codelieche/mysql56-v1
  ```

### 新的数据库搭建主从

> Master和Slave都是全新搭建的。

#### 操作步骤

- 准备挂载数据的目录

- 创建Master数据库
- 创建Slave数据库
- 创建复制账号
- 开启复制

#### 操作

- 准备挂载数据的目录

  ```bash
  mkdir -p /data/mysql/replication
  cd /data/mysql/replication
  mkdir /data/mysql/replication/master /data/mysql/replication/slave
  chmod 777 -R /data/mysql/replication
  ```

  > 注意挂载的目录，docker需要能写的权限。

- 创建Master数据库

  ```bash
  cd /data/mysql/replication/master
  docker run -itd -v "${PWD}/data:/var/lib/mysql" -v "${PWD}/backup:/backup" -p 3306:3306 --name mysql-master mysql:56-v1
  ```

- 创建Slave数据库

  - 准备配置文件：重点修改my.cnf的server_id

    ```
    root@ubuntu238:/data/mysql/replication/slave# cat my.cnf | grep "server_id\|relay"
    server_id = 20191209
    relay_log = /var/lib/mysql/mysql-relay-bin
    ```

  - 创建容器：

    ```bash
    cd /data/mysql/replication/slave
    
    docker run -itd -v "${PWD}/my.cnf:/etc/my.cnf" -v "${PWD}/data:/var/lib/mysql" -v "${PWD}/backup:/backup" -p 3316:3306 --name mysql-slave mysql:56-v1
    ```

    

  查看容器：

  ```bash
  root@ubuntu123:/data/mysql/replication/slave# docker ps | grep mysql
  d5fdbd9a9036        mysql:56-v1                   "/docker-entrypoint.…"   8 seconds ago       Up 6 seconds        0.0.0.0:3316->3306/tcp   mysql-slave
  9c8face2e5bf        mysql:56-v1                   "/docker-entrypoint.…"   6 minutes ago       Up 3 minutes        0.0.0.0:3306->3306/tcp   mysql-master
  ```

- 创建复制账号

  - 进入容器: `docker exec -it mysql-slave /bin/bash`
  - 连接mysql: `mysql -uroot -pchangeme`
  - 执行创建用户语句:
    - `CREATE user 'repl'@'%' IDENTIFIED BY 'ThisIsPassword';`
    - `GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO repl@'%';`

  - 操作

    ```bash
    root@ubuntu238:~# docker exec -it mysql-slave /bin/bash
    bash-4.2$ mysql -uroot -pchangeme
    Warning: Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 2
    Server version: 5.6.46-86.2-log Percona Server (GPL), Release 86.2, Revision 5e33e07
    
    Copyright (c) 2009-2019 Percona LLC and/or its affiliates
    Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.
    
    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.
    
    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    
    mysql> CREATE user 'repl'@'%' IDENTIFIED BY 'ThisIsPassword';
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO repl@'%';
    Query OK, 0 rows affected (0.00 sec)
    ```

- 启动复制

  - 进入：`slave`容器: `docker exec -it mysql-slave /bin/bash`

  - 连接mysql: `mysql -uroot -pchangeme`

  - 执行sql：

    ```sql
    mysql> CHANGE MASTER TO MASTER_HOST="172.17.0.5",
        -> MASTER_USER='repl',
        -> MASTER_PASSWORD='ThisIsPassword',
        -> MASTER_LOG_FILE='mysql-bin.000004',
        -> MASTER_LOG_POS=0;
    Query OK, 0 rows affected, 2 warnings (0.04 sec)
    ```

    **注意：**

    - master的ip是通过:`docker inspect mysql-master`查看到的。
    - 容器重启IP可能会变，临时测试这样ok，推荐docker运行的时候使用个docker link。
    - 或者用master所在节点的IP：`192.168.1.123`

  - 查看Slave状态：

    ```bash
    ersion for the right syntax to use near '' at line 1
    mysql> SHOW SLAVE STATUS\G;
    *************************** 1. row ***************************
                   Slave_IO_State:
                      Master_Host: 172.17.0.5
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000004
              Read_Master_Log_Pos: 4
                   Relay_Log_File: mysql-relay-bin.000001
                    Relay_Log_Pos: 4
            Relay_Master_Log_File: mysql-bin.000004
                 Slave_IO_Running: No
                Slave_SQL_Running: No
                  Replicate_Do_DB:
              Replicate_Ignore_DB:
               Replicate_Do_Table:
           Replicate_Ignore_Table:
          Replicate_Wild_Do_Table:
      Replicate_Wild_Ignore_Table:
                       Last_Errno: 0
                       Last_Error:
                     Skip_Counter: 0
              Exec_Master_Log_Pos: 4
                  Relay_Log_Space: 120
                  Until_Condition: None
                   Until_Log_File:
                    Until_Log_Pos: 0
               Master_SSL_Allowed: No
               Master_SSL_CA_File:
               Master_SSL_CA_Path:
                  Master_SSL_Cert:
                Master_SSL_Cipher:
                   Master_SSL_Key:
            Seconds_Behind_Master: NULL
    Master_SSL_Verify_Server_Cert: No
                    Last_IO_Errno: 0
                    Last_IO_Error:
                   Last_SQL_Errno: 0
                   Last_SQL_Error:
      Replicate_Ignore_Server_Ids:
                 Master_Server_Id: 0
                      Master_UUID:
                 Master_Info_File: /var/lib/mysql/master.info
                        SQL_Delay: 0
              SQL_Remaining_Delay: NULL
          Slave_SQL_Running_State:
               Master_Retry_Count: 86400
                      Master_Bind:
          Last_IO_Error_Timestamp:
         Last_SQL_Error_Timestamp:
                   Master_SSL_Crl:
               Master_SSL_Crlpath:
               Retrieved_Gtid_Set:
                Executed_Gtid_Set:
                    Auto_Position: 0
    1 row in set (0.00 sec)
    
    ERROR:
    No query specified
    ```

  - **启动Slave**

    ```sql
    mysql> START SLAVE;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> SHOW SLAVE STATUS\G;
    *************************** 1. row ***************************
                   Slave_IO_State: Waiting for master to send event
                      Master_Host: 172.17.0.5
                      Master_User: repl
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000004
              Read_Master_Log_Pos: 906
                   Relay_Log_File: mysql-relay-bin.000002
                    Relay_Log_Pos: 1069
            Relay_Master_Log_File: mysql-bin.000004
                 Slave_IO_Running: Yes
                Slave_SQL_Running: Yes
                  Replicate_Do_DB:
              Replicate_Ignore_DB:
               Replicate_Do_Table:
           Replicate_Ignore_Table:
          Replicate_Wild_Do_Table:
      Replicate_Wild_Ignore_Table:
                       Last_Errno: 0
                       Last_Error:
                     Skip_Counter: 0
              Exec_Master_Log_Pos: 906
                  Relay_Log_Space: 1242
                  Until_Condition: None
                   Until_Log_File:
                    Until_Log_Pos: 0
               Master_SSL_Allowed: No
               Master_SSL_CA_File:
               Master_SSL_CA_Path:
                  Master_SSL_Cert:
                Master_SSL_Cipher:
                   Master_SSL_Key:
            Seconds_Behind_Master: 0
    Master_SSL_Verify_Server_Cert: No
                    Last_IO_Errno: 0
                    Last_IO_Error:
                   Last_SQL_Errno: 0
                   Last_SQL_Error:
      Replicate_Ignore_Server_Ids:
                 Master_Server_Id: 20191203
                      Master_UUID: 67dbbb13-1a3a-11ea-9338-0242ac110005
                 Master_Info_File: /var/lib/mysql/master.info
                        SQL_Delay: 0
              SQL_Remaining_Delay: NULL
          Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
               Master_Retry_Count: 86400
                      Master_Bind:
          Last_IO_Error_Timestamp:
         Last_SQL_Error_Timestamp:
                   Master_SSL_Crl:
               Master_SSL_Crlpath:
               Retrieved_Gtid_Set:
                Executed_Gtid_Set:
                    Auto_Position: 0
    1 row in set (0.00 sec)
    
    ERROR:
    No query specified
    ```

### 测试数据

- 在master创建数据库和表

  ```sql
  mysql> show master status;
  +------------------+----------+--------------+------------------+-------------------+
  | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
  +------------------+----------+--------------+------------------+-------------------+
  | mysql-bin.000004 |      120 |              |                  |                   |
  +------------------+----------+--------------+------------------+-------------------+
  1 row in set (0.00 sec)
  
  mysql> CREATE DATABASE codelieche DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  Query OK, 1 row affected (0.01 sec)
  
  mysql> use codelieche;
  Database changed
  mysql> CREATE TABLE users (
      -> `id` INT PRIMARY KEY AUTO_INCREMENT,
      -> `name` VARCHAR(40) NOT NULL COMMENT "用户名",
      -> `age` INT UNSIGNED NOT NULL COMMENT "年龄",
      -> `email` VARCHAR(100) COMMENT "邮箱"
      -> ) ENGINE = INNODB COMMENT = "用户表";
  Query OK, 0 rows affected (0.03 sec)
  
  mysql> show master status;
  +------------------+----------+--------------+------------------+-------------------+
  | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
  +------------------+----------+--------------+------------------+-------------------+
  | mysql-bin.000004 |      906 |              |                  |                   |
  +------------------+----------+--------------+------------------+-------------------+
  1 row in set (0.00 sec)
  
  mysql> drop user repl@'%';
  Query OK, 0 rows affected (0.00 sec)
  
  mysql> CREATE user 'repl'@'%' IDENTIFIED BY 'ThisIsPassword';
  Query OK, 0 rows affected (0.00 sec)
  
  mysql> GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO repl@'%';
  Query OK, 0 rows affected (0.00 sec)
  
  mysql> INSERT INTO users (`name`, `age`, `email`) VALUES
      ->  ("Tome", 18, "tome@example.com"),
      ->  ("Jim", 19, "jim@example.com"),
      ->  ("admin", 26, "admin@example.com"),
      ->  ("Tome2", 18, "tome2@example.com"),
      ->  ("Jim2", 19, "jim2@example.com");
  Query OK, 5 rows affected (0.00 sec)
  Records: 5  Duplicates: 0  Warnings: 0
  
  mysql> show master status;
  +------------------+----------+--------------+------------------+-------------------+
  | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
  +------------------+----------+--------------+------------------+-------------------+
  | mysql-bin.000004 |     1693 |              |                  |                   |
  +------------------+----------+--------------+------------------+-------------------+
  1 row in set (0.00 sec)
  
  mysql> INSERT INTO users (`name`, `age`, `email`) VALUES
      ->  ("Tome", 18, "tome@example.com"),
      ->  ("Jim", 19, "jim@example.com"),
      ->  ("admin", 26, "admin@example.com"),
      ->  ("Tome2", 18, "tome2@example.com"),
      ->  ("Jim2", 19, "jim2@example.com");
  Query OK, 5 rows affected (0.01 sec)
  Records: 5  Duplicates: 0  Warnings: 0
  
  mysql> show master status;                                                                                         +------------------+----------+--------------+------------------+-------------------+
  | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
  +------------------+----------+--------------+------------------+-------------------+
  | mysql-bin.000004 |     2060 |              |                  |                   |
  +------------------+----------+--------------+------------------+-------------------+
  1 row in set (0.00 sec)
  ```

- slave中查看数据：

  ```sql
  mysql> show databases;
  +--------------------+
  | Database           |
  +--------------------+
  | information_schema |
  | codelieche         |
  | mysql              |
  | performance_schema |
  +--------------------+
  4 rows in set (0.01 sec)
  
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
  +----+-------+-----+-------------------+
  | id | name  | age | email             |
  +----+-------+-----+-------------------+
  |  1 | Tome  |  18 | tome@example.com  |
  |  2 | Jim   |  19 | jim@example.com   |
  |  3 | admin |  26 | admin@example.com |
  |  4 | Tome2 |  18 | tome2@example.com |
  |  5 | Jim2  |  19 | jim2@example.com  |
  |  6 | Tome  |  18 | tome@example.com  |
  |  7 | Jim   |  19 | jim@example.com   |
  |  8 | admin |  26 | admin@example.com |
  |  9 | Tome2 |  18 | tome2@example.com |
  | 10 | Jim2  |  19 | jim2@example.com  |
  +----+-------+-----+-------------------+
  10 rows in set (0.00 sec)
  ```

  

