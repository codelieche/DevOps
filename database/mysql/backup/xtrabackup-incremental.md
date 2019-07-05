## xtrabackup增量备份

> 增量备份是需要先有全量备份的基础的。

### 执行全量备份

- 执行命令

  ```bash
  innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=xxxx --backup /root/backup/full/
  ```

- 查看备份文件目录

  ```bash
  root@546c948f8d-qqd5f:~/backup/full# du -smh *
  888M	2019-07-05_08-58-57
  ```

### 执行增量备份

> 现在我们有了全备：`/root/backup/full/2019-07-05_08-58-57`
>
> 我们在这个全备的基础上做增量备份。

- 执行增量备份

  ```bash
  innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=xxxx \
  --incremental-basedir=/root/backup/full/2019-07-05_08-58-57 \
  --incremental /root/backup/incremental
  ```

- 添加个数据库：codelieche，创建users表添加些数据

  ```sql
  CREATE TABLE users (
  	`id` INT PRIMARY KEY AUTO_INCREMENT,
  	`name` VARCHAR(40) NOT NULL COMMENT "用户名",
  	`age` INT UNSIGNED NOT NULL COMMENT "年龄",
  	`email` VARCHAR(100) COMMENT "邮箱"
  ) ENGINE = INNODB COMMENT = "用户表";
  
  INSERT INTO users (`name`, `age`, `email`) VALUES
   ("Tome", 18, "tome@example.com"),
   ("Jim", 19, "jim@example.com"),
   ("admin", 26, "admin@example.com"),
   ("Tome2", 18, "tome2@example.com"),
   ("Jim2", 19, "jim2@example.com");
   
   -- 多执行几次，不断的让表数据自增
   INSERT INTO users (`name`, `age`, `email`) 
   SELECT name, age, email FROM users;
  ```

- 再次执行增量备份

  ```bash
  innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=xxxx \
  --incremental-basedir=/root/backup/full/2019-07-05_08-58-57 \
  --incremental /root/backup/incremental
  ```

  输出日志：

  ```
  # ......
  xtrabackup: Stopping log copying thread.
  .190705 09:24:54 >> log scanned up to (1437325570)
  
  190705 09:24:54 Executing UNLOCK BINLOG
  190705 09:24:54 Executing UNLOCK TABLES
  190705 09:24:54 All tables unlocked
  190705 09:24:54 Backup created in directory '/root/backup/incremental/2019-07-05_09-23-38/'
  190705 09:24:54 [00] Writing /root/backup/incremental/2019-07-05_09-23-38/backup-my.cnf
  190705 09:24:54 [00]        ...done
  190705 09:24:54 [00] Writing /root/backup/incremental/2019-07-05_09-23-38/xtrabackup_info
  190705 09:24:54 [00]        ...done
  xtrabackup: Transaction log of lsn (1437325570) to (1437325570) was copied.
  190705 09:24:55 completed OK!
  ```

- 重复增加部分数据，再执行增量备份几次, 再执行次DELETE语句，然后查看增量备份目录：

  - 增加1w条数据

    ```sql
    INSERT INTO users (`name`, `age`, `email`) 
    SELECT name, age, email FROM users LIMIT 10000;
    ```

  - 删除id大于1w后面的数据

    ```sql
     DELETE FROM users WHERE id > 10000;
    ```

  - 查看目录

    ```bash
    root@546c948f8d-qqd5f:~/backup/incremental# du -smh *
    8.2M	2019-07-05_09-12-21
    8.7M	2019-07-05_09-18-58
    45M	2019-07-05_09-23-38
    45M	2019-07-05_09-26-50
    59M	2019-07-05_09-29-05
    ```

  ### 备份文件信息查看

  #### xtrabackup_checkpoints

  - 全备

    ```bash
    root@546c948f8d-qqd5f:~# cat /root/backup/full/2019-07-05_08-58-57/xtrabackup_checkpoints
    backup_type = full-backuped
    from_lsn = 0
    to_lsn = 1389785076
    last_lsn = 1389785076
    compact = 0
    recover_binlog_info = 0
    flushed_lsn = 1389785076
    ```

  - 增量备份

    ```bash
    root@546c948f8d-qqd5f:~# cat /root/backup/incremental/2019-07-05_09-29-05/xtrabackup_checkpoints
    backup_type = incremental
    from_lsn = 1389785076
    to_lsn = 1502395365
    last_lsn = 1502395365
    compact = 0
    recover_binlog_info = 0
    flushed_lsn = 1502395365
    ```

  > 可以看出增量备份的`from_lsn`是全备的`to_lsn`。
  >
  > 根据这个，我们再次测试下，基于`incremental/2019-07-05_09-29-05`这个增备再做一次增量备份。

  - 基于增备，再次增备

    - 添加5000条数据：

      ```sql
      INSERT INTO users (`name`, `age`, `email`) 
      SELECT name, age, email FROM users LIMIT 5000;
      ```

    - 执行增备: 

      ```bash
      innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=rIjpdicDYs1Rn8PS \
      --incremental-basedir=/root/backup/incremental/2019-07-05_09-29-05 \
      --incremental /root/backup/incremental
      ```

      **注意**：这里的`—incremental-basedir`是不一样的

    - 查看目录

      ```bash
      root@546c948f8d-qqd5f:~/backup/incremental# du -smh *
      8.2M	2019-07-05_09-12-21
      8.7M	2019-07-05_09-18-58
      45M	2019-07-05_09-23-38
      45M	2019-07-05_09-26-50
      59M	2019-07-05_09-29-05
      9.3M	2019-07-05_09-49-00
      ```

      `2019-07-05_09-49-00`这个就是最新的增量备份。

    - 查看`xtrabackup_checkpoints`文件

      ```bash
      root@546c948f8d-qqd5f:~/backup/incremental# cat 2019-07-05_09-49-00/xtrabackup_checkpoints
      backup_type = incremental
      from_lsn = 1502395365
      to_lsn = 1502849168
      last_lsn = 1502849168
      compact = 0
      recover_binlog_info = 0
      flushed_lsn = 1502849168
      ```

      > 可以看出这里的`from_lsn`就是上一个增量备份的`to_lsn`。

  