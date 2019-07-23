## fio

> flexible I/O tester

### 参考文档

- https://linux.die.net/man/1/fio



安装：

- `yum install fio`
- `apt-get install fio`



### 参数

- `—name`: 名称
- `—direct`: 表示十分跳过系统缓存。设置为`1`表示跳过系统缓存，`0`表示不跳过
- `—rw, —readwrite=str`: 表示I/O模式
  - `read`: 顺序读
  - `randread`: 随机读
  - `write`: 顺序写
  - `randwrite`: 随机写
- `—iodepth=int`: 表示使用异步I/O(asynchronous I/O检查AIO)时，同时发出的I/O请求上限，默认是1
- `—ioengine=str`: 表示I/O引擎
  - `sync`: 同步
  - `libaio`: 异步
  - `mmap`: 内存映射
  - `net`：网络
- `—bs,—blocksize=int`: 表示I/O的大小，比如：N[KMG]
- `—filename`: 文件路径，当然，它可以是磁盘路径(测试磁盘性能)，也可以是文件路径(测试文件系统性能)。
  - 注意：如果设置为磁盘(eg: /dev/sdd)， 用磁盘路径测试写，会破坏这个磁盘中的文件系统，所以在使用前，一定要先做好数据备份。
- `—size`: 测试文件大小
- `—group_reporting`: 汇总每个进程的信息

### 测试

### 写：write

- 对磁盘4k顺序写: write

  ```bash
  io --name=write --direct=1 --iodepth=64 --rw=write --ioengine=libaio --bs=4k --size=1G --runtime=1000 --group_reporting --filename=/dev/sdd
  ```

- 输出结果：

  ```
  write: (g=0): rw=write, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=64
  fio-2.2.10
  Starting 1 process
  Jobs: 1 (f=1): [W(1)] [100.0% done] [0KB/146.5MB/0KB /s] [0/37.5K/0 iops] [eta 00m:00s]
  write: (groupid=0, jobs=1): err= 0: pid=240114: Sat Jul 20 15:28:10 2019
    write: io=1024.0MB, bw=133798KB/s, iops=33449, runt=  7837msec
      slat (usec): min=1, max=845, avg= 3.46, stdev= 4.59
      clat (usec): min=653, max=68529, avg=1908.86, stdev=2704.84
       lat (usec): min=666, max=68535, avg=1912.40, stdev=2705.02
      clat percentiles (usec):
       |  1.00th=[ 1144],  5.00th=[ 1256], 10.00th=[ 1304], 20.00th=[ 1368],
       | 30.00th=[ 1432], 40.00th=[ 1480], 50.00th=[ 1528], 60.00th=[ 1592],
       | 70.00th=[ 1672], 80.00th=[ 1784], 90.00th=[ 2096], 95.00th=[ 2512],
       | 99.00th=[ 9792], 99.50th=[17280], 99.90th=[45312], 99.95th=[52480],
       | 99.99th=[61184]
      bw (KB  /s): min= 6568, max=167976, per=100.00%, avg=134037.00, stdev=43184.19
      lat (usec) : 750=0.01%, 1000=0.09%
      lat (msec) : 2=88.18%, 4=8.79%, 10=1.97%, 20=0.52%, 50=0.39%
      lat (msec) : 100=0.06%
    cpu          : usr=3.73%, sys=16.08%, ctx=33874, majf=0, minf=12
    IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
       submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
       complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
       issued    : total=r=0/w=262144/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
       latency   : target=0, window=0, percentile=100.00%, depth=64
  
  Run status group 0 (all jobs):
    WRITE: io=1024.0MB, aggrb=133798KB/s, minb=133798KB/s, maxb=133798KB/s, mint=7837msec, maxt=7837msec
  
  Disk stats (read/write):
    sdd: ios=9/256364, merge=0/0, ticks=0/480956, in_queue=480960, util=98.77%
  ```

- 对磁盘：4k随机写: randwrite

  ```bash
  fio --name=randwrite --direct=1 --iodepth=64 --rw=randwrite --ioengine=libaio --bs=4k --size=1G --runtime=1000 --group_reporting --filename=/dev/sdd
  ```



#### 读：Read

- 磁盘4k顺序读: read

  ```bash
  fio -name=read -direct=1 -iodepth=64 --rw=read --ioengine=libaio --bs=4k --size=1G --numjobs=1 --runtime=1000 --group_reporting --filename=/dev/sdd
  ```

  - 输出结果

    ```
    read: (g=0): rw=read, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=64
    fio-2.2.10
    
    Starting 1 process
    Jobs: 1 (f=1): [R(1)] [100.0% done] [172.1MB/0KB/0KB /s] [44.3K/0/0 iops] [eta 00m:00s]
    read: (groupid=0, jobs=1): err= 0: pid=240213: Sat Jul 20 15:40:15 2019
      read : io=1024.0MB, bw=174559KB/s, iops=43639, runt=  6007msec
        slat (usec): min=1, max=881, avg= 3.08, stdev= 4.05
        clat (usec): min=24, max=9632, avg=1462.59, stdev=943.94
         lat (usec): min=26, max=9634, avg=1465.75, stdev=943.87
        clat percentiles (usec):
         |  1.00th=[   90],  5.00th=[  660], 10.00th=[  732], 20.00th=[  788],
         | 30.00th=[  852], 40.00th=[  964], 50.00th=[ 1096], 60.00th=[ 1288],
         | 70.00th=[ 1624], 80.00th=[ 2096], 90.00th=[ 2928], 95.00th=[ 3408],
         | 99.00th=[ 4512], 99.50th=[ 4960], 99.90th=[ 6176], 99.95th=[ 6624],
         | 99.99th=[ 7968]
        bw (KB  /s): min=158024, max=192712, per=99.96%, avg=174489.25, stdev=11495.55
        lat (usec) : 50=0.01%, 100=1.24%, 250=0.96%, 500=0.96%, 750=10.04%
        lat (usec) : 1000=29.33%
        lat (msec) : 2=35.86%, 4=19.29%, 10=2.30%
      cpu          : usr=4.80%, sys=18.51%, ctx=34965, majf=0, minf=74
      IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
         submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
         complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
         issued    : total=r=262144/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
         latency   : target=0, window=0, percentile=100.00%, depth=64
    
    Run status group 0 (all jobs):
       READ: io=1024.0MB, aggrb=174559KB/s, minb=174559KB/s, maxb=174559KB/s, mint=6007msec, maxt=6007msec
    
    Disk stats (read/write):
      sdd: ios=257841/0, merge=0/0, ticks=368860/0, in_queue=368836, util=98.40%
    ```

- 磁盘4k随机读：randread

  ```bash
  fio -name=randread -direct=1 -iodepth=64 --rw=randread --ioengine=libaio --bs=4k --size=1G --numjobs=1 --runtime=1000 --group_reporting --filename=/dev/sdd
  ```



#### 报告查看

> 我们重点关注的是：`slat`、`clat`、`lat`、`bw`和`iops`这几行

- `slat`: Submission latency: 是指从I/O提交到实际执行I/O的时长
- `clat`: Completion latency: 是指从I/O提交到I/O完成的时长
- `lat`:  指从fio创建I/O到I/O完成的总时长
- `bw`: 指吞吐量
- `iops`: 就是每秒I/O的次数

> 对同步I/O来说，由于I/O提交和I/O完成是一个动作，所以slat实际上就是I/O完成的时机，而clat是0.





