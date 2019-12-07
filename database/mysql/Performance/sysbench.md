## 使用sysbench对MySQL进行压力测试

### 参考文档

- https://github.com/akopytov/sysbench

### 性能测试的指标

- **QPS**：每秒钟处理完请求的次数
- **TPS**：每秒钟处理完的事务次数
- **响应时间**：一次请求所需要的平均处理时间
- **并发量**：系统能同时处理的请求数



## Sysbench

> sysbench是一款开源的多线程性能测试工具，可以执行CPU/内存/线程/IO/数据库等方面的性能测试。

### 安装Sysbench

- MacOS中安装sysbench

  ```bash
  brew install sysbench
  ```

### Sysbench基本使用

- CPU测试

  ```bash
  sysbench --test=cpu --cpu-max-prime=40000 run
  ```

- 线程测试

  ```bash
  sysbench --test=threads --num-threads=10 --thread-yields=100 --thread-locks=2 run
  ```

- 内存测试

  ```bash
  sysbench --test=memory --memory-block-size=8k --memory-total-size=4G run
  ```

- 磁盘测试

  ```bash
  sysbench --test=fileio --num-threads=16 --file-total-size=10G --file-test-mode=rmdrw run
  ```

- 数据库测试

  ```bash
  sysbench --test=oltp --mysql-table-engine=innodb --oltp-table-size=1000000
  ```



### 使用sysbench对数据库进行测试

> sysbench script [options] [command]

- [OPTION]连接信息参数
  - `--mysql-host`: IPD地址
  - `--mysql-port`: 数据库端口号
  - `--mysql-user`: 用户名
  - `--mysql-password`: 密码
- [OPTION]执行参数
  - `--oltp-test-mode`: 执行模式
    - `simple`: 
    - `nontrx`: 
    - `complex`:
  - `--oltp-tables-count`: 测试表的数量
  - `--oltp-table-size`: 测试表的记录数
  - `--threads`: 并发线程数
  - `--time`: 测试执行时间(秒)
  - `--preport-interval`: 生成报告单的间隔时间(秒)

- 命令：COMMAND
  - `prepare`: 准备测试数据
  - `run`: 执行测试
  - `cleanup`: 清楚测试数据

#### 准备测试数据：

- 先准备好数据库，并创建一个`sbtest`的库

  进入容器：

  ```bash
  root@ubuntu123:~# docker exec -it mysql-t1 /bin/bash
  bash-4.2$ mysql -uroot -pchangeme
  Warning: Using a password on the command line interface can be insecure.
  Welcome to the MySQL monitor.  Commands end with ; or \g.
  Your MySQL connection id is 7
  Server version: 5.6.46-86.2-log Percona Server (GPL), Release 86.2, Revision 5e33e07
  
  Copyright (c) 2009-2019 Percona LLC and/or its affiliates
  Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.
  
  Oracle is a registered trademark of Oracle Corporation and/or its
  affiliates. Other names may be trademarks of their respective
  owners.
  
  Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
  ```

  **执行SQL：**

  ```sql
  mysql> create database sbtest;
  Query OK, 1 row affected (0.01 sec)
  
  mysql> use sbtest;
  Database changed
  mysql> show tables;
  Empty set (0.00 sec)
  ```

- 先找到脚本的位置:

  ```bash
  ls -alh `which sysbench`
  ```

  在MacOS上脚本路径是：

  `/usr/local/Cellar/sysbench/1.0.18_1/share/sysbench/tests/include/oltp_legacy/oltp.lua`

  而如果是Linux，在:`/usr/share/sysbench/tests/include/oltp_legacy/oltp.lua`

- **执行prepare**

  ```bash
  sysbench /usr/local/Cellar/sysbench/1.0.18_1/share/sysbench/tests/include/oltp_legacy/oltp.lua \
  --mysql-host=192.168.1.123 --mysql-port=3306 \
  --mysql-user=root --mysql-password=changeme \
  --oltp-tables-count=20 --oltp-table-size=1000000 prepare
  ```

  **创建20个数据表，买个表100W条数据。**

  输出结果：

  > sysbench 1.0.18 (using bundled LuaJIT 2.1.0-beta2)
  >
  > Creating table 'sbtest1'...
  > Inserting 1000000 records into 'sbtest1'
  > Creating secondary indexes on 'sbtest1'...
  > Creating table 'sbtest2'...
  > Inserting 1000000 records into 'sbtest2'
  > Creating secondary indexes on 'sbtest2'...
  > Creating table 'sbtest3'...
  > ..........
  > Creating table 'sbtest20'...
  > Inserting 1000000 records into 'sbtest20'
  > Creating secondary indexes on 'sbtest20'...

- 查看数据库中的表：

  ```sql
  -- 查看数据库中的表
  mysql> show tables;
  +------------------+
  | Tables_in_sbtest |
  +------------------+
  | sbtest1          |
  | sbtest2         |
  | sbtest3         |
  .....
  | sbtest18         |
  | sbtest19         |
  | sbtest20         |
  +------------------+
  20 rows in set (0.00 sec)
  -- 查看表结构
  mysql> desc sbtest1;
  +-------+------------------+------+-----+---------+----------------+
  | Field | Type             | Null | Key | Default | Extra          |
  +-------+------------------+------+-----+---------+----------------+
  | id    | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
  | k     | int(10) unsigned | NO   | MUL | 0       |                |
  | c     | char(120)        | NO   |     |         |                |
  | pad   | char(60)         | NO   |     |         |                |
  +-------+------------------+------+-----+---------+----------------+
  4 rows in set (0.00 sec)
  
  -- 查询2行数据看下
  mysql> select * from sbtest1 LIMIT 2;
  +----+--------+-------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------+
  | id | k      | c                                                                                                                       | pad                                                         |
  +----+--------+-------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------+
  |  1 | 499284 | 83868641912-28773972837-60736120486-75162659906-27563526494-20381887404-41576422241-93426793964-56405065102-33518432330 | 67847967377-48000963322-62604785301-91415491898-96926520291 |
  |  2 | 501969 | 38014276128-25250245652-62722561801-27818678124-24890218270-18312424692-92565570600-36243745486-21199862476-38576014630 | 23183251411-36241541236-31706421314-92007079971-60663066966 |
  +----+--------+-------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------+
  2 rows in set (0.00 sec)
  ```

  

#### 执行：

- 执行命令：

  ```bash
  sysbench /usr/local/Cellar/sysbench/1.0.18_1/share/sysbench/tests/include/oltp_legacy/oltp.lua \
  --mysql-host=192.168.1.123 --mysql-port=3306 \
  --mysql-user=root --mysql-password=changeme \
  --oltp-test-mode=complex --threads=10 \
  --time=600 --report-interval=5 run >> ~/report.log
  ```

- 查看报告：

  ```bash
  ➜  ~ tail -f report.log
  sysbench 1.0.18 (using bundled LuaJIT 2.1.0-beta2)
  
  Running the test with following options:
  Number of threads: 10
  Report intermediate results every 5 second(s)
  Initializing random number generator from current time
  
  Initializing worker threads...
  
  Threads started!
  
  [ 5s ] thds: 10 tps: 217.57 qps: 4375.61 (r/w/o: 3066.58/871.89/437.14) lat (ms,95%): 61.08 err/s: 0.00 reconn/s: 0.00
  [ 10s ] thds: 10 tps: 225.60 qps: 4519.05 (r/w/o: 3162.44/905.21/451.41) lat (ms,95%): 59.99 err/s: 0.20 reconn/s: 0.00
  [ 15s ] thds: 10 tps: 221.02 qps: 4418.21 (r/w/o: 3092.89/883.48/441.84) lat (ms,95%): 63.32 err/s: 0.00 reconn/s: 0.00
  [ 20s ] thds: 10 tps: 222.76 qps: 4450.30 (r/w/o: 3115.97/888.62/445.71) lat (ms,95%): 58.92 err/s: 0.00 reconn/s: 0.00
  [ 25s ] thds: 10 tps: 222.15 qps: 4445.45 (r/w/o: 3112.74/888.41/444.31) lat (ms,95%): 59.99 err/s: 0.00 reconn/s: 0.00
  
  # ......
  
  [ 595s ] thds: 10 tps: 230.60 qps: 4612.95 (r/w/o: 3228.76/922.59/461.59) lat (ms,95%): 55.82 err/s: 0.00 reconn/s: 0.00
  [ 600s ] thds: 10 tps: 232.40 qps: 4651.21 (r/w/o: 3256.00/930.40/464.80) lat (ms,95%): 53.85 err/s: 0.00 reconn/s: 0.00
  SQL statistics:
      queries performed:
          read:                            1915088
          write:                           547078
          other:                           273546
          total:                           2735712
      transactions:                        136754 (227.91 per sec.)
      queries:                             2735712 (4559.27 per sec.)
      ignored errors:                      38     (0.06 per sec.)
      reconnects:                          0      (0.00 per sec.)
  
  General statistics:
      total time:                          600.0308s
      total number of events:              136754
  
  Latency (ms):
           min:                                   17.95
           avg:                                   43.87
           max:                                  694.52
           95th percentile:                       56.84
           sum:                              5999901.48
  
  Threads fairness:
      events (avg/stddev):           13675.4000/188.49
      execution time (avg/stddev):   599.9901/0.01
  ```

  

#### 清理：

- 执行命令

  ```bash
  sysbench /usr/local/Cellar/sysbench/1.0.18_1/share/sysbench/tests/include/oltp_legacy/oltp.lua \
  --mysql-host=192.168.1.123 --mysql-port=3306 \
  --mysql-user=root --mysql-password=changeme cleanup
  ```

  

