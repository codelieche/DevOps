## 主从复制错误：1062

> Last_SQL_Error: Could not execute Write_rows event on table codelieche.users; Duplicate entry '11' for key 'PRIMARY', Error_code: 1062; handler error HA_ERR_FOUND_DUPP_KEY; the event's master log mysql-bin.000004, end_log_pos 2267

### 准备

- 搭建好的主从集群
- 准备触发错误

### 触发错误

- 先查看slave状态

  ```sql
  show slave status \G;
  ```

  得到信息：

  ```bash
  Last_SQL_Errno: 0
  Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
  Master_Server_Id: 20191203
  ```

  **此时集群是ok的。**

- **查看同步的数据：**

  ```bash
  mysql> show databases;
  +--------------------+
  | Database           |
  +--------------------+
  | information_schema |
  | codelieche         |
  | mysql              |
  | performance_schema |
  +--------------------+
  4 rows in set (0.00 sec)
  
  mysql> use codelieche
  Database changed
  mysql> show tables;
  +----------------------+
  | Tables_in_codelieche |
  +----------------------+
  | users                |
  +----------------------+
  1 row in set (0.00 sec)
  
  mysql> desc users;
  +-------+------------------+------+-----+---------+----------------+
  | Field | Type             | Null | Key | Default | Extra          |
  +-------+------------------+------+-----+---------+----------------+
  | id    | int(11)          | NO   | PRI | NULL    | auto_increment |
  | name  | varchar(40)      | NO   |     | NULL    |                |
  | age   | int(10) unsigned | NO   |     | NULL    |                |
  | email | varchar(100)     | YES  |     | NULL    |                |
  +-------+------------------+------+-----+---------+----------------+
  4 rows in set (0.00 sec)
  
  mysql> select * from users;
  +----+----------+-----+-------------------+
  | id | name     | age | email             |
  +----+----------+-----+-------------------+
  |  1 | Tome     |  18 | tome@example.com  |
  |  2 | Jim      |  19 | jim@example.com   |
  |  3 | admin    |  26 | admin@example.com |
  |  4 | Tome2    |  18 | tome2@example.com |
  |  5 | Jim2     |  19 | jim2@example.com  |
  |  6 | Tome     |  18 | tome@example.com  |
  |  7 | Jim      |  19 | jim@example.com   |
  |  8 | admin    |  26 | admin@example.com |
  |  9 | Tome2    |  18 | tome2@example.com |
  | 10 | Jim2     |  19 | jim2@example.com  |
  +----+----------+-----+-------------------+
  10 rows in set (0.00 sec)
  ```

- **在slave节点上插入一条数据：**

  ```sql
  INSERT INTO users(`name`, `age`, `email`) VALUES ("t1-slave", 100, "t1@gmail.com");
  ```

  查看数据：

  ```sql
  mysql> select * from users;
  +----+----------+-----+-------------------+
  | id | name     | age | email             |
  +----+----------+-----+-------------------+
  |  1 | Tome     |  18 | tome@example.com  |
  -- .......
  | 11 | t1-slave | 100 | t1@gmail.com      |
  +----+----------+-----+-------------------+
  11 rows in set (0.00 sec)
  ```

- **在Master节点上插入一条数据：**

  ```sql
  INSERT INTO users(`name`, `age`, `email`) VALUES ("t1-master", 100, "t1@gmail.com");
  ```

  查看数据：

  ```sql
  mysql> INSERT INTO users(`name`, `age`, `email`) VALUES ("t1-master", 100, "t1@gmail.com");
  Query OK, 1 row affected (0.01 sec)
  
  mysql> select * from users;
  +----+-----------+-----+-------------------+
  | id | name      | age | email             |
  +----+-----------+-----+-------------------+
  |  1 | Tome      |  18 | tome@example.com  |
  |  2 | Jim       |  19 | jim@example.com   |
  |  3 | admin     |  26 | admin@example.com |
  |  4 | Tome2     |  18 | tome2@example.com |
  |  5 | Jim2      |  19 | jim2@example.com  |
  |  6 | Tome      |  18 | tome@example.com  |
  |  7 | Jim       |  19 | jim@example.com   |
  |  8 | admin     |  26 | admin@example.com |
  |  9 | Tome2     |  18 | tome2@example.com |
  | 10 | Jim2      |  19 | jim2@example.com  |
  | 11 | t1-master | 100 | t1@gmail.com      |
  +----+-----------+-----+-------------------+
  11 rows in set (0.00 sec)
  
  mysql> INSERT INTO users(`name`, `age`, `email`) VALUES ("t2-master", 100, "t1@gmail.com");
  Query OK, 1 row affected (0.01 sec)
  ```

- 在slave节点查看slave状态：

  ```sql
  mysql> show slave status \G;
  *************************** 1. row ***************************
                 Slave_IO_State: Waiting for master to send event
                    Master_Host: 172.17.0.5
                    Master_User: repl
                    Master_Port: 3306
                  Connect_Retry: 60
                Master_Log_File: mysql-bin.000004
            Read_Master_Log_Pos: 2298
                 Relay_Log_File: mysql-relay-bin.000002
                  Relay_Log_Pos: 2223
          Relay_Master_Log_File: mysql-bin.000004
               Slave_IO_Running: Yes
              Slave_SQL_Running: No
                Replicate_Do_DB:
            Replicate_Ignore_DB:
             Replicate_Do_Table:
         Replicate_Ignore_Table:
        Replicate_Wild_Do_Table:
    Replicate_Wild_Ignore_Table:
                     Last_Errno: 1062
                     Last_Error: Could not execute Write_rows event on table codelieche.users; Duplicate entry '11' for key 'PRIMARY', Error_code: 1062; handler error HA_ERR_FOUND_DUPP_KEY; the event's master log mysql-bin.000004, end_log_pos 2267
                   Skip_Counter: 0
            Exec_Master_Log_Pos: 2060
                Relay_Log_Space: 2634
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
                 Last_SQL_Errno: 1062
                 Last_SQL_Error: Could not execute Write_rows event on table codelieche.users; Duplicate entry '11' for key 'PRIMARY', Error_code: 1062; handler error HA_ERR_FOUND_DUPP_KEY; the event's master log mysql-bin.000004, end_log_pos 2267
    Replicate_Ignore_Server_Ids:
               Master_Server_Id: 20191203
                    Master_UUID: 67dbbb13-1a3a-11ea-9338-0242ac110005
               Master_Info_File: /var/lib/mysql/master.info
                      SQL_Delay: 0
            SQL_Remaining_Delay: NULL
        Slave_SQL_Running_State:
             Master_Retry_Count: 86400
                    Master_Bind:
        Last_IO_Error_Timestamp:
       Last_SQL_Error_Timestamp: 191209 06:52:51
                 Master_SSL_Crl:
             Master_SSL_Crlpath:
             Retrieved_Gtid_Set:
              Executed_Gtid_Set:
                  Auto_Position: 0
  1 row in set (0.00 sec)
  
  ERROR:
  No query specified
  ```

  **到这里，问题就触发了。**

  这里的原因是：日志是基于行的，我们在slave中插入了一条语句，那么11这个ID已经有了数据了。当从master中同步它插入的这条数据(id=11)的语句时，就抛出了错误。

---

### 错误解决方法

#### 方式一：删除slave中重复的行

- 删除重复的行：`delete from users where id=11;`

- 停止slave：`stop slave;`

- 开启slave：`start slave`

- 再次查看状态：`SHOW SLAVE STATUS \G;`

  执行后，状态又恢复为了：`Last_SQL_Errno: 0`

#### 方式二：跳过这一条行

> 如果恢复了，可重复上面触发1062错误的步骤，再次触发错误。

- 停止slave：

- 设置`sql_slave_skip_counter=`:

- 启动slave:

  ```sql
  mysql> stop slave;
  Query OK, 0 rows affected (0.00 sec)
  
  mysql> set global sql_slave_skip_counter=1;
  Query OK, 0 rows affected (0.00 sec)
  
  mysql> start slave;
  Query OK, 0 rows affected (0.00 sec)
  ```

- 再次查看slave状态：`SHOW SLAVE STATUS \G;`







