### 二进制日志测试

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

  