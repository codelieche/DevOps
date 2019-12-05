## 在线修改表结构：pt-online-schema-change



### 准备

- **安装percona-toolkit**

  - 安装源：

    - Ubuntu或者Debian:

      ```bash
      wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb
      sudo dpkg -i percona-release_latest.generic_all.deb
      ```

    - Red Hat或者CentOS：

      ```bash
      sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
      ```

  - 安装

    - `sudo apt-get install percona-toolkit`
    - `sudo yum install percona-toolkit`

- **准备数据库：**

  ```sql
  -- 创建数据库
  CREATE DATABASE codelieche DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  
  -- 选择数据库
  use codelieche;
  
  -- 创建表
  CREATE TABLE users (
          `id` INT PRIMARY KEY AUTO_INCREMENT,
          `name` VARCHAR(40) NOT NULL COMMENT "用户名",
          `age` INT UNSIGNED NOT NULL COMMENT "年龄",
          `email` VARCHAR(100) COMMENT "邮箱"
  ) ENGINE = INNODB COMMENT = "用户表";
  
  -- 插入数据
  INSERT INTO users (`name`, `age`, `email`) VALUES
   ("Tome", 18, "tome@example.com"),
   ("Jim", 19, "jim@example.com"),
   ("admin", 26, "admin@example.com"),
   ("Tome2", 18, "tome2@example.com"),
   ("Jim2", 19, "jim2@example.com");
  ```



### 修改表结构

- 查看修改前user表结构：

  ```sql
  mysql> desc users;
  +-------+------------------+------+-----+---------+----------------+
  | Field | Type             | Null | Key | Default | Extra          |
  +-------+------------------+------+-----+---------+----------------+
  | id    | int(11)          | NO   | PRI | NULL    | auto_increment |
  | name  | varchar(40)      | NO   |     | NULL    |                |
  | age   | int(10) unsigned | NO   |     | NULL    |                |
  | email | varchar(100)     | YES  |     | NULL    |                |
  +-------+------------------+------+-----+---------+----------------+
  4 rows in set (0.01 sec)
  ```

- **执行修改命令：**

  ```bash
  pt-online-schema-change --host=127.0.0.1 --port=3306 \
  --user=root --password=changeme \
  --alter "MODIFY name VARCHAR(60) NOT NULL COMMENT '用户名'" \
  D=codelieche,t=users  --print --execute
  ```

- 查看修改后的表结构：

  ```sql
  mysql> desc users;
  +-------+------------------+------+-----+---------+----------------+
  | Field | Type             | Null | Key | Default | Extra          |
  +-------+------------------+------+-----+---------+----------------+
  | id    | int(11)          | NO   | PRI | NULL    | auto_increment |
  | name  | varchar(60)      | NO   |     | NULL    |                |
  | age   | int(10) unsigned | NO   |     | NULL    |                |
  | email | varchar(100)     | YES  |     | NULL    |                |
  +-------+------------------+------+-----+---------+----------------+
  4 rows in set (0.00 sec)
  ```

  