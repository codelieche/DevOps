## 软件磁盘阵列 (Software RAID)

> 磁盘阵列的全称是：Redundant Arrays Of Inexpensive Disks, RAID。独立冗余磁盘阵列。

RAID可以通过技术（软件或硬件）将多个较小的磁盘整合成为一个较大的磁盘设备，而这个较大的磁盘功能可不止是存储而已，它还具有数据保护的功能。

常用的有：`RAID 0`，`RAID 1`, `RAID 5`, `RAID 6`, `RAID 0 + 1`, `RAID 1 + 0`。



### RAID 0 

> 等量模式，Stripe。性能最佳

这种模式的RAID会将磁盘先切出等量的数据块(Chunk, 一般可设置为4kb-1MB),然后当一个文件要写入RAID时，会把该文件根据chunk的大小切割好，之后再依次放到各个磁盘里面去。

由于每个磁盘会交错地存放数据，因此当你的数据要写入RAID是，数据会被等量地放置在各个磁盘上面。

**总容量 =  S1 + S2 + …. + Sn**

> RAID 0 只要有任何一块磁盘损坏，在RAID上面的所有数据都会遗失而无法读取。



### RAID 1

> 镜像模式，Mirror，完整备份。 **总容量 = Min(S1, S2, …. Sn)**

RAID 1这种模式主要是：让同一份数据，完整地保存在两块磁盘上。

由于两块磁盘内的数据一模一样，所以任何一块硬盘损坏时，你的数据还是可以完整地保留下来。

- RAID 1最大的优点就是备份数据
- 写入性能不佳，但是读取性能提升



### RAID 1+0， RAID 0+1

> RAID 0的性能佳但是数据不安全，RAID 1的数据安全但是性能不佳，那么我们能不能将这两者整合起来设置RAID呢？  
>
> 可以：那就是RAID 1+0或者RAID 0 + 1。RAID 01没有RAID 10好。

所谓`RAID 1 + 0`就是：

- 先让两块磁盘组成`RAID 1`， 这样设置2个组
- 将这2组`RAID 1` 再组成`RAID 0`



### RAID 4

- 第一块存：1010
- 第二块存：0011
- 第三块存, 校验码，异或：1001

### RAID 5

> 性能与数据备份的均衡考虑。
>
> RAID 5需要三块以上的磁盘才能组成这种类型的磁盘阵列。
>
> RAID 5校验码是循环使用的，而不像RAID 4，一块做校验码。

**可用空间 = (N - 1) x min(S1, S2, …. Sn)**

- 读、写性能提升
- 有容错能力，最多一块磁盘
- 最少磁盘数：`3, 3+`

> RAID 5这种磁盘阵列的数据写入有点类似RAID 0，不过每个循环的写入过程中(striping)，在每块磁盘还会加入一个奇偶校验数据（Parity），这个数据会记录其它磁盘的备份数据，用于当有磁盘损坏时的恢复。

每个循环写入时，都会有部分的奇偶校验值(parity)被记录下来，并且每次都记录在不同的磁盘。

因此：任何一个磁盘损坏时都能借由其他磁盘的检查码来重建原本磁盘内的数据。

**RAID 5默认仅支持一块磁盘的损坏情况**

### RAID 6

> RAID 5仅能支持一块磁盘的损坏。
>
> RAID 6使用两块磁盘的容量存储奇偶校验码，因此整体的磁盘容量是少两块，但是允许出错的磁盘数量可以达到两块。



## mdadm

> Mutiple Device Admin。
>
> 软件磁盘阵列的设置工具。

### mdadm 参数

- `—create`:  为建立RAID的选项
- `—auto=yes`: 决定建立后面接的软件磁盘阵列设备，亦即/dev/md0、/dev/md1等
- `--chunk=NK`: 决定这个设备的chunk大小，也可以当成stripe大小，一般是64K或者512K
- `—raid-devices=N`: 使用几个磁盘分区(partition)作为磁盘阵列的设备
- `—spare-devices=N`: 使用几个磁盘作为备用(spare)设备
- `—level=[015]`: 设置这组磁盘阵列的级别，支持很多，不过建议用0、1、5即可
- `—detail`: 后面所接的那个磁盘阵列设备的详细信息

### 以三块磁盘创建RAID5

- 查看磁盘

  ```bash
  root@localhost:~# fdisk -l | grep sd
  Disk /dev/sdb: 16 GiB, 17179869184 bytes, 33554432 sectors
  Disk /dev/sda: 16 GiB, 17179869184 bytes, 33554432 sectors
  /dev/sda1  *       2048   999423   997376  487M 83 Linux
  /dev/sda2       1001470 33552383 32550914 15.5G  5 扩展
  /dev/sda5       1001472 33552383 32550912 15.5G 8e Linux LVM
  Disk /dev/sdc: 16 GiB, 17179869184 bytes, 33554432 sectors
  Disk /dev/sdd: 16 GiB, 17179869184 bytes, 33554432 sectors
  ```

- mdadm创建磁盘阵列

  ```bash
  root@localhost:~# mdadm --create /dev/md0 --auto=yes --level=5 --chunk=256K --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd
  mdadm: Defaulting to version 1.2 metadata
  mdadm: array /dev/md0 started.
  ```

- 查看md0

  ```bash
  root@localhost:~# mdadm --detail /dev/md0
  /dev/md0:                                         # RAID的设备文件名
          Version : 1.2
    Creation Time : Tue Jul 16 15:56:59 2019        # 创建RAID的世界
       Raid Level : raid5                           # RAID的级别，这里是5
       Array Size : 33521664 (31.97 GiB 34.33 GB)   # 整组RAID的可用容量
    Used Dev Size : 16760832 (15.98 GiB 17.16 GB)   # 每块磁盘设备的容量
     Raid Devices : 3                               # 组成RAID的磁盘数量
    Total Devices : 3                               # 包括spare的总磁盘数量
      Persistence : Superblock is persistent
  
      Update Time : Tue Jul 16 15:59:11 2019
            State : clean                           # 目前这个磁盘阵列的使用状态
   Active Devices : 3                               # 启动(active)的设备数量
  Working Devices : 3                               # 目前使用与此阵列的设备数量
   Failed Devices : 0                               # 损坏的设备数
    Spare Devices : 0                               # 热备分磁盘的数量
  
           Layout : left-symmetric
       Chunk Size : 256K                            # chunk的小数据块容量
  
             Name : localhost:0  (local to host localhost)
             UUID : 4458bec4:56cbd513:b0e77990:47e98372
           Events : 18
  
      Number   Major   Minor   RaidDevice State
         0       8       16        0      active sync   /dev/sdb
         1       8       32        1      active sync   /dev/sdc
         3       8       48        2      spare rebuilding   /dev/sdd
  ```

  总容量是 = (3 - 1) * 16G  = 32G

  注意：磁盘阵列创建需要些时间，所以等几分钟再查看状态才是`clean`要不会有差异。

- 格式化文件系统

  ```bash
  root@localhost:~# blkid /dev/md0
  root@localhost:~# mkfs.ext4 /dev/md0
  mke2fs 1.42.13 (17-May-2015)
  Creating filesystem with 8380416 4k blocks and 2097152 inodes
  Filesystem UUID: 79f40cf6-234c-46eb-a0bf-2b195baf0942
  Superblock backups stored on blocks:
  	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
  	4096000, 7962624
  
  Allocating group tables: 完成
  正在写入inode表: 完成
  Creating journal (32768 blocks): 完成
  Writing superblocks and filesystem accounting information: 完成
  
  root@localhost:~# blkid /dev/md0
  /dev/md0: UUID="79f40cf6-234c-46eb-a0bf-2b195baf0942" TYPE="ext4"
  ```

- 挂载

  ```bash
  root@localhost:~# mount /dev/md0 /data/rddata/
  root@localhost:~# mount | grep md0
  /dev/md0 on /data/rddata type ext4 (rw,relatime,stripe=128,data=ordered)
  ```

  

#### mdadm —manage

选项和参数：

- `—add`: 会将后面的设备加入到这个md中
- `—remove`: 会将后面的设备由这个md中删除
- `—fail`: 将设备设置为出错的状态

```
mdadm --manage /dev/md0 --add /dev/sde
mdadm --manage /dev/md0 --remove /dev/sde
mdadm --manage /dev/md0 --fail /dev/sdd
```



#### 开机自动启动RAID并自动挂载

软件RAID也是有配置文件的，这个配置文件是`/etc/mdadm.conf`

- 先获取到md0的uuid：`mdadm —detail /dev/md0 | grep UUID`

  ```bash
  root@localhost:~# blkid /dev/md0
  /dev/md0: UUID="79f40cf6-234c-46eb-a0bf-2b195baf0942" TYPE="ext4"
  root@localhost:~# mdadm --detail /dev/md0 | grep UUID
             UUID : 4458bec4:56cbd513:b0e77990:47e98372
  ```

  **注意**：`blkid /dev/md0`获取到的UUID是不一样的哦

- 配置：`/etc/mdadm.conf`

  ```bash
  root@localhost:~# cat /etc/mdadm.conf
  ARRAY /dev/md0 UUID=4458bec4:56cbd513:b0e77990:47e98372
  #     RAID设备 识别码内容
  ```

- 设置挂载目录：`/etc/fstab`

  ```bash
  root@localhost:~# cat /etc/fstab
  # .....
  UUID=4458bec4:56cbd513:b0e77990:47e98372 /data/rddata ext4 defaults 0 0
  ```

#### 关闭mdadm创建的RAID

```bash
root@localhost:~# umount /dev/md0
root@localhost:~# df -h
文件系统                      容量  已用  可用 已用% 挂载点
udev                          4.3G     0  4.3G    0% /dev
tmpfs                         877M   17M  860M    2% /run
/dev/mapper/ykstest--vg-root   15G  6.7G  6.9G   50% /
tmpfs                         4.3G     0  4.3G    0% /dev/shm
tmpfs                         5.0M     0  5.0M    0% /run/lock
tmpfs                         4.3G     0  4.3G    0% /sys/fs/cgroup
/dev/sda1                     472M  105M  343M   24% /boot
tmpfs                         877M     0  877M    0% /run/user/0
root@localhost:~# mdadm --stop /dev/md0
mdadm: stopped /dev/md0
root@localhost:~# ls /dev/md0
ls: 无法访问'/dev/md0': 没有那个文件或目录
root@localhost:~# blkid /dev/sdb
/dev/sdb: UUID="4458bec4-56cb-d513-b0e7-799047e98372" UUID_SUB="c78ab8ba-5a4e-9026-2d52-175ed67bec75" LABEL="localhost:0" TYPE="linux_raid_member"
root@localhost:~# blkid /dev/sdc
/dev/sdc: UUID="4458bec4-56cb-d513-b0e7-799047e98372" UUID_SUB="c0b5bf16-10da-ffb8-6d8c-368a56ae95fd" LABEL="localhost:0" TYPE="linux_raid_member"
root@localhost:~# blkid /dev/sdd
/dev/sdd: UUID="4458bec4-56cb-d513-b0e7-799047e98372" UUID_SUB="d101103c-bebb-7982-d51b-2c75348fef23" LABEL="localhost:0" TYPE="linux_raid_member"
root@localhost:~# dd if=/dev/zero of=/dev/sdb bs=1M count=10
记录了10+0 的读入
记录了10+0 的写出
10485760 bytes (10 MB, 10 MiB) copied, 0.0694904 s, 151 MB/s
root@localhost:~# blkid /dev/sdb
root@localhost:~# dd if=/dev/zero of=/dev/sdc bs=1M count=10
记录了10+0 的读入
记录了10+0 的写出
10485760 bytes (10 MB, 10 MiB) copied, 0.0717 s, 146 MB/s
root@localhost:~# dd if=/dev/zero of=/dev/sdd bs=1M count=10
记录了10+0 的读入
记录了10+0 的写出
10485760 bytes (10 MB, 10 MiB) copied, 0.0603371 s, 174 MB/s
root@localhost:~# blkid /dev/sdd
root@localhost:~#
```

另外记得删除`/etc/mdadm.conf`和`/etc/fstab`中的相关配置。

**注意**：dd命令别执行到错误的盘了。

- dd命说明：

  > dd命令用于读取、转换并输出数据。
  >
  > dd可从标准输入或文件中读取数据，根据指定的格式来转换数据，再输出到文件，设备或标准输出。

  参数：

  - `if=文件名`: 输入文件名，不填就是标准输入，即指定源文件
  - `of=文件名`: 输出文件名，不填就是标准输出，即指定目的文件
  - `bs=bytes`: 同时设置读取/输出的块大小为bytes个字节
  - `count=blocks`: 从仅拷贝blocks个块，块大小等于bs指定的字节数

  ```bash
  root@localhost:~# dd if=/dev/zero of=/root/ddtest.log bs=1M count=100
  记录了100+0 的读入
  记录了100+0 的写出
  104857600 bytes (105 MB, 100 MiB) copied, 0.0825224 s, 1.3 GB/s
  root@localhost:~# ls -alh /root/ddtest.log
  -rw-r--r-- 1 root root 100M Jul 18 16:50 /root/ddtest.log
  ```

  





