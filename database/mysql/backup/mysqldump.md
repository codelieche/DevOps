## mysqldump的基本使用



### 参数

- `—user=name`: 让mysqldump以name账号与MySQL服务器进行交互

- `—password`: 账号的密码

- `—databases name`: 备份指定的数据库

- `—lock-all-tables`: 在做备份前，先让MySQL锁住所有表，然后直到备份完成才解锁

  > 对于繁忙的数据库，长时间锁住所有表会有很大的影响。

- `—all-databases`: 导出所有数据库

- `—extended-insert`: 一个表一条INSERT语句，默认是一行数据一条INSERT

- `—complete-insert`: 让生成的INSERT语句包含列名

- `—ignore-table=mysql.user`: 忽略`mysql`库的`user`表

- `—result-fle=dump.sql`: 指定输出文件



### 备份codelieche的数据库

```bash
mysqldump --databases codelieche --user=root --password > ~/codelieche_backup.sql
```

### dump文件的查看

> mysqldump先给dump文件写一些注释，设置一些变量，然后列出CREATE DATABASE、CREATE TABLE、INSERT语句。最后还原变量。

- 文件头部：

  ```
  -- MySQL dump 10.13  Distrib 8.0.16, for Linux (x86_64)
  --
  -- Host: localhost    Database: codelieche
  -- ------------------------------------------------------
  -- Server version	8.0.16
  ```

  1. 第一行显示的是mysqldump、MySQL和操作系统的版本
  2. 这次dump是从`localhost`登录后执行的，备份数据库的名字是：`codelieche`
  3. 下面`8.0.16`是MySQL的版本

- 一堆SET语句

  ```
  /*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
  /*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
  /*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
   SET NAMES utf8mb4 ;
  /*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
  /*!40103 SET TIME_ZONE='+00:00' */;
  /*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
  /*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
  /*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
  /*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
  ```

  这些SET语句处于`/*!….*/`之间，看起来像不会执行的注释。**注意**：开头是`/*!`而不是`/*`，这个是MySQL和MariaDB的条件性语句。

  > MySQL会检查感叹号后的版本号是否与自身匹配，再决定是否执行。
  >
  > 在dump文件中，注释是以`- -`开头的。

  ```
  /*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
  ```

  上面这行语句是指：**只在MySQL或者MariaDB 4.01.01以及以上版本执行此命令。**

- 末尾恢复命令

  ```
  /*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
  
  /*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
  /*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
  /*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
  /*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
  /*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
  /*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
  /*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
  ```

  它们与最开始的顺序刚好相反，这些SET语句所做的就是：**用刚开始创建的变量将这些全局变量恢复成原来的设置。**

### 定期备份

```
#!/bin/bash
# 备份codelieche的 codelieche_mysql数据库

# 注意
# 1. mysqldump和mysqld的版本号要统一
# 2. 比如mysqldump8.0的去备份 mysql5.6的数据库就会报错

MYSQL_USER="backup_user"
MYSQL_PASSWORD="pwd123456"

MYSQL_HOST="192.168.1.123"
MYSQL_PORT=3306

# --databases xx1 xx2 xx3
# 指定要备份的数据库
# --all-databases 可以是备份全库
db="codelieche"

# --tables xxx
# 指定要备份的表
# --ignore-table=mysql.user 忽略mysql库的user表

now=`date +"%F%Y"`

backup_dir='/data/backup/mysql'

dump_file_path="${backup_dir}/${db}_${now}.sql"

# 输出执行命令
echo "mysqldump --host=${MYSQL_HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --databases $db > ${dump_file_path}"

# 执行备份命令
mysqldump --host=${MYSQL_HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --databases $db > ${dump_file_path}
# 退出备份脚本
exit
```

然后可把这个脚本加入计划任务之中定期执行。`10 1 * * * bash /data/backup/backup_xxx.sh`



----

查看备份文件的内容：

```
-- MySQL dump 10.13  Distrib 8.0.16, for Linux (x86_64)
--
-- Host: localhost    Database: codelieche
-- ------------------------------------------------------
-- Server version	8.0.16

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `codelieche`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `codelieche` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `codelieche`;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'username',
  `age` int(10) unsigned NOT NULL COMMENT 'UserAge',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'UserEmail',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='UsersTable';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Tome',18,'tome@example.com'),(2,'Jim',19,'jim@example.com'),(4,'Tome2',18,'tome2@codelieche.com'),(5,'Jim2',19,'jim2@example.com');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-07-03  1:17:36
```





