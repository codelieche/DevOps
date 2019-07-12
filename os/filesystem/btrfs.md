## btrfs文件系统



### 实战btrfs

- 查看测试机磁盘

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

- 把sdb和sdc两个设备做成btrfs

  ```
  root@localhost:~# mkfs.btrfs -L mybtrdata /dev/sdb /dev/sdc
  btrfs-progs v4.4
  See http://btrfs.wiki.kernel.org for more information.
  
  /dev/sdc appears to contain a partition table (dos).
  Use the -f option to force overwrite.
  ```

  提示sdc中含有分区表信息，使用`-f`强制覆盖：

  ```
  root@localhost:~# mkfs.btrfs -L mybtrdata /dev/sdb /dev/sdc -f
  btrfs-progs v4.4
  See http://btrfs.wiki.kernel.org for more information.
  
  Label:              mybtrdata
  UUID:               f4dbb683-ff34-4361-af38-137fcb11702e
  Node size:          16384
  Sector size:        4096
  Filesystem size:    32.00GiB
  Block group profiles:
    Data:             RAID0             2.01GiB
    Metadata:         RAID1             1.01GiB
    System:           RAID1            12.00MiB
  SSD detected:       no
  Incompat features:  extref, skinny-metadata
  Number of devices:  2
  Devices:
     ID        SIZE  PATH
      1    16.00GiB  /dev/sdb
      2    16.00GiB  /dev/sdc
  ```

- 查看btrfs文件系统: `btrfs filesystem show`

  ```bash
  root@localhost:~# btrfs filesystem show
  Label: 'mybtrdata'  uuid: f4dbb683-ff34-4361-af38-137fcb11702e
  	Total devices 2 FS bytes used 112.00KiB
  	devid    1 size 16.00GiB used 2.01GiB path /dev/sdb
  	devid    2 size 16.00GiB used 2.01GiB path /dev/sdc
  	
  root@localhost:~# blkid /dev/sdb
  /dev/sdb: LABEL="mybtrdata" UUID="f4dbb683-ff34-4361-af38-137fcb11702e" UUID_SUB="8eb9a414-a56e-4927-970a-2be72cadc4d6" TYPE="btrfs"
  root@localhost:~# blkid /dev/sdc
  /dev/sdc: LABEL="mybtrdata" UUID="f4dbb683-ff34-4361-af38-137fcb11702e" UUID_SUB="ed66df4e-2008-4a98-89af-4bee475543ba" TYPE="btrfs"
  ```

  可以看到/dev/sdb, /dev/sdc的UUID是一样的。

- 挂载: 把`/dev/sdb`挂载到`/data/btrdata`

  指定btrfs中的任何一个即可，挂载:`sdb`或者`sdc`随便一个即可，它们两个是一样的。

  ```
  root@localhost:~# mount -t btrfs /dev/sdb /data/btrdata
  mount: mount point /data/btrdata does not exist
  root@localhost:~# mkdir /data/btrdata
  root@localhost:~# mount -t btrfs /dev/sdb /data/btrdata
  ```

  查看挂载：

  ```bash
  root@localhost:~# mount | grep btrdata
  /dev/sdb on /data/btrdata type btrfs (rw,relatime,space_cache,subvolid=5,subvol=/)
  ```

  卸载后，采用透明压缩：

  ```bash
  root@localhost:~# umount /dev/sdb
  root@localhost:~# mount -o compress=lzo /dev/sdb /data/btrdata/
  root@localhost:~# cp /etc/rc.local /data/btrdata/
  root@localhost:~# ll /data/btrdata/
  总用量 24
  drwxr-xr-x 1 root root   16 Jul 12 10:49 ./
  drwxr-xr-x 6 root root 4096 Jul 12 10:42 ../
  -rwxr-xr-x 1 root root  306 Jul 12 10:49 rc.local*
  ```

- 修改文件系统的大小：减少6G

  ```bash
  root@localhost:/data/btrdata# btrfs filesystem show
  Label: 'mybtrdata'  uuid: f4dbb683-ff34-4361-af38-137fcb11702e
  	Total devices 2 FS bytes used 896.00KiB
  	devid    1 size 16.00GiB used 2.01GiB path /dev/sdb
  	devid    2 size 16.00GiB used 2.01GiB path /dev/sdc
  
  root@localhost:/data/btrdata# btrfs filesystem resize -6G /data/btrdata/
  Resize '/data/btrdata/' of '-6G'
  root@localhost:/data/btrdata# btrfs filesystem show
  Label: 'mybtrdata'  uuid: f4dbb683-ff34-4361-af38-137fcb11702e
  	Total devices 2 FS bytes used 896.00KiB
  	devid    1 size 10.00GiB used 2.01GiB path /dev/sdb
  	devid    2 size 16.00GiB used 2.01GiB path /dev/sdc
  ```

  现在`/dev/sdb`设备上就由16G变成了10G，减少了6G。

  ```bash
  root@localhost:/data/btrdata# btrfs filesystem df /data/btrdata/
  Data, RAID0: total=2.00GiB, used=768.00KiB
  System, RAID1: total=8.00MiB, used=16.00KiB
  Metadata, RAID1: total=1.00GiB, used=112.00KiB
  GlobalReserve, single: total=16.00MiB, used=0.00B
  ```

  采用df查看:

  ```bash
  root@localhost:/data/btrdata# df -lh
  文件系统                      容量  已用  可用 已用% 挂载点
  udev                          4.3G     0  4.3G    0% /dev
  tmpfs                         877M   17M  860M    2% /run
  /dev/mapper/mylvm--vg-root   15G  6.7G  6.9G   50% /
  tmpfs                         4.3G     0  4.3G    0% /dev/shm
  tmpfs                         5.0M     0  5.0M    0% /run/lock
  tmpfs                         4.3G     0  4.3G    0% /sys/fs/cgroup
  /dev/sda1                     472M  105M  343M   24% /boot
  tmpfs                         877M     0  877M    0% /run/user/0
  /dev/sdb                       26G   17M   18G    1% /data/btrdata
  ```

- resize：增加2G

  ```bash
  root@localhost:/data/btrdata# btrfs filesystem resize +2G /data/btrdata/
  Resize '/data/btrdata/' of '+2G'
  root@localhost:/data/btrdata# df -lh
  文件系统                      容量  已用  可用 已用% 挂载点
  # ......
  /dev/sdb                       28G   17M   22G    1% /data/btrdata
  ```

  直接调整到最大：`btrfs filesystem resize max /data/btrdata/`

  ```bash
  root@localhost:/data/btrdata# btrfs filesystem resize max /data/btrdata/
  Resize '/data/btrdata/' of 'max'
  root@localhost:/data/btrdata# df -lh
  文件系统                      容量  已用  可用 已用% 挂载点
  # .....
  /dev/sdb                       32G   17M   30G    1% /data/btrdata
  ```

- 生成1w个1M的文件:  目录：`/data/btrdata/test`

  ```bash
  seq 10000 | xargs -i dd if=/dev/zero of={}.log bs=1024000 count=1
  ```

  查看磁盘：

  ```bash
  root@localhost:/data/btrdata/test# df -lh
  文件系统                      容量  已用  可用 已用% 挂载点
  # ...
  /dev/sdb                       32G  364M   30G    2% /data/btrdata
  ```

- 管理btrfs文件系统的设备

  > btrfs device add/remove/scan

  - 添加设备: `/dev/sdd`

    ```bash
    root@localhost:/data/btrdata/test# btrfs device add /dev/sdd /data/btrdata/
    root@localhost:/data/btrdata/test# df -lh
    文件系统                      容量  已用  可用 已用% 挂载点
    # ...
    /dev/sdb                       48G  364M   44G    1% /data/btrdata
    ```

    增加后，目录`/data/btrdata`容量增加了16G。

  - 移除设备：

    ```bash
    root@localhost:/data/btrdata# btrfs device remove /dev/sdd /data/btrdata
    root@localhost:/data/btrdata# df -lh
    文件系统                      容量  已用  可用 已用% 挂载点
    # ...
    /dev/sdb                       32G   364M   30G    1% /data/btrdata
    ```

  - 删除已有设备：**注意**先继续把sdd设备加入进来

    ```bash
    root@localhost:/data/btrdata/test# btrfs device add /dev/sdd /data/btrdata/
    root@localhost:/data/btrdata/test# btrfs device delete /dev/sdb /data/btrdata/
    root@localhost:/data/btrdata/test# df -lh
    文件系统                      容量  已用  可用 已用% 挂载点
    # ...
    /dev/sdc                       32G  370M   32G    2% /data/btrdata
    ```

    查看:

    ```bash
    root@localhost:~# btrfs filesystem show
    Label: 'mybtrdata'  uuid: f4dbb683-ff34-4361-af38-137fcb11702e
    	Total devices 2 FS bytes used 333.41MiB
    	devid    2 size 16.00GiB used 1.28GiB path /dev/sdc
    	devid    3 size 16.00GiB used 1.28GiB path /dev/sdd
    	
    root@localhost:~# btrfs filesystem df /data/btrdata/
    Data, RAID0: total=2.00GiB, used=313.06MiB
    System, RAID1: total=32.00MiB, used=16.00KiB
    Metadata, RAID1: total=256.00MiB, used=20.33MiB
    GlobalReserve, single: total=16.00MiB, used=0.00B
    ```

- 修改RAID级别

  - 修改成RAID0或者RAID1

    ```bash
    root@localhost:~# btrfs balance start -dconvert=raid0 /data/btrdata/
    Done, had to relocate 1 out of 3 chunks
    root@localhost:~# btrfs balance start -dconvert=raid1 /data/btrdata/
    Done, had to relocate 1 out of 3 chunks
    ```

  - 修改成raid5：RAID5至少3块设备，那再把sdb加入进去

    ```bash
    root@localhost:~# btrfs device add /dev/sdb /data/btrdata/
    root@localhost:~# btrfs balance start -dconvert=raid5 /data/btrdata/
    Done, had to relocate 2 out of 4 chunks
    root@localhost:~# btrfs filesystem df /data/btrdata/
    Data, RAID1: total=1.00GiB, used=0.00B
    Data, RAID5: total=4.00GiB, used=313.06MiB
    System, RAID1: total=32.00MiB, used=16.00KiB
    Metadata, RAID1: total=256.00MiB, used=20.30MiB
    GlobalReserve, single: total=16.00MiB, used=0.00B
    ```

- **子卷：subvolume**

  - 创建子卷

    ```bash
    root@localhost:~# btrfs subvolume create /data/btrdata/logs
    Create subvolume '/data/btrdata/logs'
    root@localhost:~# btrfs subvolume create /data/btrdata/images
    Create subvolume '/data/btrdata/images'
    root@localhost:~# btrfs subvolume create /data/btrdata/htmls
    Create subvolume '/data/btrdata/htmls'
    ```

  - 查看子卷：

    ```bash
    root@localhost:~# btrfs subvolume list /data/btrdata/
    ID 263 gen 94 top level 5 path logs
    ID 264 gen 95 top level 5 path images
    ID 265 gen 96 top level 5 path htmls
    root@localhost:~# ls /data/btrdata/
    htmls  images  logs  rc.local  test
    ```

  - 查看子卷

    ```bash
    root@localhost:~# btrfs subvolume show /data/btrdata/logs/
    /data/btrdata/logs
    	Name: 			logs
    	UUID: 			db7d8c99-53f1-be4a-8b7e-f85acc45760a
    	Parent UUID: 		-
    	Received UUID: 		-
    	Creation time: 		2019-07-12 11:48:01 +0800
    	Subvolume ID: 		263
    	Generation: 		94
    	Gen at creation: 	94
    	Parent ID: 		5
    	Top level ID: 		5
    	Flags: 			-
    	Snapshot(s):
    ```

  - 删除子卷：`btrfs subvolume delete /data/btrdata/html`

- 子卷快照

  - 准备个文件：

    ```bash
    root@localhost:~# echo `date` >> /data/btrdata/logs/test.log
    root@localhost:~# cat /data/btrdata/logs/test.log
    Fri Jul 12 11:53:32 CST 2019
    Fri Jul 12 11:53:45 CST 2019
    ```

  - 创建快照卷

    ```bash
    root@localhost:~# btrfs subvolume snapshot /data/btrdata/logs/ /data/btrdata/logs_snapshot
    Create a snapshot of '/data/btrdata/logs/' in '/data/btrdata/logs_snapshot'
    root@localhost:~# btrfs subvolume list /data/btrdata/
    ID 263 gen 100 top level 5 path logs
    ID 264 gen 95 top level 5 path images
    ID 265 gen 96 top level 5 path htmls
    ID 266 gen 100 top level 5 path logs_snapshot
    ```

  - 修改原来的文件

    ```bash
    root@ykstest3:~# cat /data/btrdata/logs_snapshot/test.log
    Fri Jul 12 11:53:32 CST 2019
    Fri Jul 12 11:53:45 CST 2019
    root@ykstest3:~# echo "This Is Test" >> /data/btrdata/logs/test.log
    root@ykstest3:~# cat /data/btrdata/logs_snapshot/test.log
    Fri Jul 12 11:53:32 CST 2019
    Fri Jul 12 11:53:45 CST 2019
    root@ykstest3:~# cat /data/btrdata/logs/test.log
    Fri Jul 12 11:53:32 CST 2019
    Fri Jul 12 11:53:45 CST 2019
    This Is Test
    ```

  - 删除快照：`btrfs subvolume delete /data/btrdata/logs_snapshot/`

 







