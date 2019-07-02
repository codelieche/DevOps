### 二进制日志测试实验

#### 测试步骤

- 刷新日志文件：`FLUSH LOGS`
- 查看binlog状态：`SHOW BINARY LOGS`
- 开始执行SQL
  - 创建数据库、创建表
  - 添加数据、修改数据、删除数据
- 再次刷新日志文件：`FLUSH LOGS`
- 查看binlog

#### 准备SQL语句

- 创建数据库: 

  - `CREATE DATABASE codelieche;`
  - `CREATE DATABASE codelieche DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`

- 创建表：

  ```mysql
  CREATE TABLE users (
  	`id` INT PRIMARY KEY AUTO_INCREMENT,
  	`name` VARCHAR(40) NOT NULL COMMENT "用户名",
  	`age` INT UNSIGNED NOT NULL COMMENT "年龄",
  	`email` VARCHAR(100) COMMENT "邮箱"
  ) ENGINE = INNODB COMMENT = "用户表";
  ```

- 插入数据：

  ```sql
  INSERT INTO users (`name`, `age`, `email`) VALUES
   ("Tome", 18, "tome@example.com"),
   ("Jim", 19, "jim@example.com"),
   ("admin", 26, "admin@example.com"),
   ("Tome2", 18, "tome2@example.com"),
   ("Jim2", 19, "jim2@example.com");
  ```

- 更新数据：

  ```sql
  UPDATE users SET email='tome2@codelieche.com'
  WHERE name="tome2" LIMIT 1;
  ```

- 删除数据：

  ```sql
  DELETE FROM users WHERE name="admin" LIMIT 1;
  ```

- 刷新log：`FLUSH LOGS`

- 查看binlog

  ```sql
  mysql> SHOW BINARY LOGS;
  +---------------+-----------+-----------+
  | Log_name      | File_size | Encrypted |
  +---------------+-----------+-----------+
  | binlog.000001 |       398 | No        |
  | binlog.000002 |      2029 | No        |
  | binlog.000003 |       155 | No        |
  +---------------+-----------+-----------+
  3 rows in set (0.00 sec)
  ```

#### 查看日志

- 通过mysql查看日志文件中进行了哪些操作

  ```sql
  mysql> SHOW BINLOG EVENTS IN 'binlog.000002';
  | Log_name      | Pos  | Event_type     | Server_id | End_log_pos | Info
  ```

- 通过mysqlbinlog查看:

  ```bash
  mysqlbinlog --database codelieche ./binlog.000002
  ```

- 通过mysqlbinlog查看，显示SQL内容：

  ```sql
  mysqlbinlog --database codelieche --base64-output=decode-rows -v ./binlog.000002
  ```

#### 测试通过binlog恢复数据

##### 1. 步骤

- 先查看codelieche.users表的数据
- 删除users表
- 通过binlog恢复创建的users表，插入的数据、再恢复修改的数据、再恢复删除语句
- 与最开始查看的数据做对比

##### 2. 测试恢复数据

- 查看users表数据

  ```sql
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
  ```

- 删除users表

  ```sql
  mysql> SHOW TABLES;
  +----------------------+
  | Tables_in_codelieche |
  +----------------------+
  | users                |
  +----------------------+
  1 row in set (0.00 sec)
  
  mysql> DROP TABLE users;
  Query OK, 0 rows affected (0.02 sec)
  
  mysql> SHOW TABLES;
  Empty set (0.00 sec)
  ```

- 通过binlog恢复users表

  - 先通过mysqlbinlog查看日志：

    **二进制日志的每个条目都以两行注释（以 `#` 开头的行）开始：**

    - 第一行注释的号码是位置号: 在at后面，**可用来指定恢复到哪一个点**
    - 第二行注释则记录了语句执行的时间及其他信息
    - 最后，条目以`/*!*/`作为结尾。

    ```bash
    mysqlbinlog --base64-output=decode-rows -v ./binlog.000002 --database=codelieche
    ```

    查看到`# at 496`是创建users表的语句：

    ```
     39 # at 496
     40 #190702 10:47:45 server id 1  end_log_pos 829 CRC32 0x23449430  Query   thread_id=23    exec_time=0 error_code=0    Xid = 35    26
     41 use `codelieche`/*!*/;
     42 SET TIMESTAMP=1562035665/*!*/;
     43 /*!80013 SET @@session.sql_require_primary_key=0*//*!*/;
     44 CREATE TABLE users ( `id` INT PRIMARY KEY AUTO_INCREMENT, `name` VARCHAR(40) NOT NULL COMMENT "username", `age` INT UNSIGNED     NOT NULL COMMENT "UserAge", `email` VARCHAR(100) COMMENT "UserEmail") ENGINE = INNODB COMMENT = "UsersTable"
     45 /*!*/;
    ```

    其中`end_log_pos 829`是指下一个条目的位置号。

  - 查看数据库表

    ```sql
    mysql> SHOW TABLES;
    Empty set (0.00 sec)
    ```

  - **执行恢复命令: **

    - `mysqlbinlog --database=codelieche --start-position=496 --stop-position=829 ./binlog.000002 | mysql --user=root —password`

      ```bash
      # 1. 进入Docker容器
      ➜  DevOps ✗ docker exec -it mysql80 /bin/bash
      
      # 2. 进入数据库数据目录
      root@1fb6aa5953f8:/# cd /var/lib/mysql/
      
      # 3. 执行恢复命令
      root@1fb6aa5953f8:/var/lib/mysql# mysqlbinlog --database=codelieche --start-position=496 --stop-position=829 \
      > ./binlog.000002 | mysql --user=root --password
      Enter password:
      
      # 4. 输入密码,然后回车
      root@1fb6aa5953f8:/var/lib/mysql#
      ```

  - 查看codelieche数据库的表：

- 恢复users表的数据

  ```bash
  mysqlbinlog --database=codelieche --start-position=829 ./binlog.000002 | mysql --user=root --password
  ```

- 再次查看users表数据

  ```sql
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
  ```

  到这里恢复创建表、插入数据、更新数据、删除数据的语句就结束了。