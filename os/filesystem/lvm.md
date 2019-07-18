## LVM

> Logical Volume Manager, 简称LVM，逻辑卷管理器。

LVM是将几个物理磁盘(或分区)通过软件组合成一块看起来是独立的大磁盘(VG)，然后将这块大磁盘再经过划分成为可使用的LV，最终就能够挂载使用了。

LVM解决的问题是：**可以弹性地调整文件系统的容量**。比如开始`/data`设置的是50G，后续要不断增大，就可使用LVM。

> 需要文件的读写性能和可靠性，请参考RAID。

**LVM可以整合多个物理分区/磁盘，让这些看起来就像是一个磁盘一样。而且，未来还可以在这个LVM管理的磁盘当中新增或者删除其他的物理分区。**



### PV、PE、VG、LV

- `pv`: 物理卷（Physical Volume，PV）

- `VG`: 卷组（Volume Group）

  > LVM大磁盘就是讲多个PV整合成这个VG。

- `PE`: 物理扩展块（Physical Extent，PE）

  > LVM默认使用4M的PE数据块。PE有点像文件系统里面的block。

- `LV`: 逻辑卷(Logical Volume, LV)

  > 最终的VG还会被切成LV，这个LV就是后面被挂载使用的，类似分区的块设备。
  >
  > LV的设备路径通常是：/dev/vgname/lvname



**LVM最主要的用处是实现一个可以弹性调整容量的文件系统，而不是建立一个性能/容错的磁盘。**

性能和容错或者备份可使用RAID。

### 实战

> 把3块磁盘（/dev/sdb、/dev/sdc、/dev/sdd）组合成一个VG。

- 查看磁盘

  ```bash
  root@localhost:~# fdisk -l | grep sd
  Disk /dev/sdb: 16 GiB, 17179869184 bytes, 33554432 sectors
  # .....
  Disk /dev/sdc: 16 GiB, 17179869184 bytes, 33554432 sectors
  Disk /dev/sdd: 16 GiB, 17179869184 bytes, 33554432 sectors
  ```

- **PV阶段：**

  - `pvcreate`: 将物理分区建立为PV
  - `pvscan`: 查找目前系统里面任何具有PV的磁盘
  - `pvdisplay`: 显示出目前系统上面的PV状态
  - `pvremove`: 将PV属性删除，让该分区不具有PV属性

  ```bash
  root@localhost:~# pvcreate /dev/sdb
    Physical volume "/dev/sdb" successfully created
  root@localhost:~# pvcreate /dev/sdc
    Physical volume "/dev/sdc" successfully created
  root@localhost:~# pvcreate /dev/sdd
    Physical volume "/dev/sdd" successfully created
  root@localhost:~# pvscan
    PV /dev/sda5   VG test-vg      lvm2 [15.52 GiB / 0    free]
    PV /dev/sdc                       lvm2 [16.00 GiB]
    PV /dev/sdd                       lvm2 [16.00 GiB]
    PV /dev/sdb                       lvm2 [16.00 GiB]
    Total: 4 [63.52 GiB] / in use: 1 [15.52 GiB] / in no VG: 3 [48.00 GiB]
  ```

  - 详细的查看pv

    ```bash
    root@localhost:~# pvdisplay /dev/sdb
      "/dev/sdb" is a new physical volume of "16.00 GiB"
      --- NEW Physical volume ---
      PV Name               /dev/sdb      # 设备名
      VG Name                             # 还未加入VG，所以这里是空
      PV Size               16.00 GiB     # 容量
      Allocatable           NO            # 是否已被分配，这里是No
      PE Size               0             # 在此PV内的PE大小
      Total PE              0             # 共划分出几个PE
      Free PE               0             # 没被LV掉的PE
      Allocated PE          0             # 尚可分配出去的PE数量
      PV UUID               ALZLMA-o0MW-OsC3-DAVA-PGYB-Uivl-aNLs28
    ```

    > 由于刚创建的PV为加入到VG，所以很多值是0，稍后我们再看。

- **VG阶段**

  - `vgcreate`: 创建VG
  - `vgscan`: 查找系统上面是否有VG存在
  - `vgdisplay`: 显示目前系统上面的VG状态
  - `vgextend`: 在VG内增加额外的PV
  - `vgreduce`: 在VG内删除PV
  - `vgchange`: 设置VG是否启用(active)
  - `vgremove`: 删除一个VG

  > 创建VG与创建PV不同，VG需要自己填写个名字，PV的名字就是设备名。

  - 创建VG

    - `-s`: 后面接PE的大小，单位可以是m、g、t, 不填写默认就是4M

    ```bash
    root@localhost:~# vgcreate data-vg /dev/sdb
      Volume group "data-vg" successfully created
    root@localhost:~# vgscan
      Reading all physical volumes.  This may take a while...
      Found volume group "test-vg" using metadata type lvm2
      Found volume group "data-vg" using metadata type lvm2
    root@localhost:~# pvscan | grep sdb
      PV /dev/sdb    VG data-vg         lvm2 [16.00 GiB / 16.00 GiB free]
    root@localhost:~# pvdisplay /dev/sdb
      --- Physical volume ---
      PV Name               /dev/sdb
      VG Name               data-vg
      PV Size               16.00 GiB / not usable 4.00 MiB
      Allocatable           yes
      PE Size               4.00 MiB
      Total PE              4095
      Free PE               4095
      Allocated PE          0
      PV UUID               ALZLMA-o0MW-OsC3-DAVA-PGYB-Uivl-aNLs28
    ```

  - `vgdisplay`: 查看vg

    ```bash
      root@localhost:~# vgdisplay data-vg
      --- Volume group ---
      VG Name               data-vg
      System ID
      Format                lvm2
      Metadata Areas        1
      Metadata Sequence No  1
      VG Access             read/write
      VG Status             resizable
      MAX LV                0
      Cur LV                0
      Open LV               0
      Max PV                0
      Cur PV                1
      Act PV                1
      VG Size               16.00 GiB         # 整体VG的大小
      PE Size               4.00 MiB          # 内部每个PE的大小
      Total PE              4095              # PE数量
      Alloc PE / Size       0 / 0
      Free  PE / Size       4095 / 16.00 GiB  # 可分配的PE数量/大小
      VG UUID               OUw14w-R3ak-uL1G-vVqu-GzaO-O3O7-DzKkpM
    ```

  - 把`/dev/sdc`的PV也加入到`data-vg`中

    ```bash
    root@localhost:~# vgextend data-vg /dev/sdc
      Volume group "data-vg" successfully extended
    root@localhost:~# vgs
      VG         #PV #LV #SN Attr   VSize  VFree
      data-vg      2   0   0 wz--n- 31.99g 31.99g
      test-vg   1   2   0 wz--n- 15.52g     0
    ```

  - `vgreduce`: 删除pv

    ```bash
    root@localhost:~# vgextend data-vg /dev/sdd
      Volume group "data-vg" successfully extended
    root@localhost:~# vgs
      VG         #PV #LV #SN Attr   VSize  VFree
      data-vg      3   0   0 wz--n- 47.99g 47.99g
      test-vg   1   2   0 wz--n- 15.52g     0
    root@localhost:~# vgreduce data-vg /dev/sdd
      Removed "/dev/sdd" from volume group "data-vg"
    root@localhost:~# vgs
      VG         #PV #LV #SN Attr   VSize  VFree
      data-vg      2   0   0 wz--n- 31.99g 31.99g
      test-vg   1   2   0 wz--n- 15.52g     0
    ```

- **LV阶段**

  > 创建了VG这个大磁盘后，再来就是要建立分区，这个分区就是所谓的LV。

  - `lvcreate`: 创建LV

  - `lvscan`: 查询系统上面的LV

  - `lvdisplay`: 显示系统上面的LV状态

  - `lvextend`: 在LV里面增加容量

  - `lvreduce`: 在LV里面减少容量，**慎用**

  - `lvremove`: 删除一个LV

  - `lvresize`: 对LV进行容量大小的调整

  - 创建LV: lvcreate

    - `-L`: 后面接容量，`-L N[mMgGtT]`
    - `-n`: LV的名字

    ```bash
    root@localhost:~# lvcreate -L 2G -n mysql-lv data-vg
      Logical volume "mysql-lv" created.
    root@localhost:~# lvs
      LV       VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
      mysql-lv data-vg    -wi-a-----   2.00g
      root     test-vg -wi-ao----  14.56g
      swap_1   test-vg -wi-ao---- 980.00m
    root@localhost:~# lvscan
      ACTIVE            '/dev/test-vg/root' [14.56 GiB] inherit
      ACTIVE            '/dev/test-vg/swap_1' [980.00 MiB] inherit
      ACTIVE            '/dev/data-vg/mysql-lv' [2.00 GiB] inherit
    ```

  - 查看刚刚创建的LV

    ```bash
    root@localhost:~# lvdisplay /dev/data-vg/mysql-lv
      --- Logical volume ---
      LV Path                /dev/data-vg/mysql-lv  # LV的全名
      LV Name                mysql-lv
      VG Name                data-vg
      LV UUID                KekWXK-D2Rb-3GEO-v7e4-iS4p-lhK5-lY1eKS
      LV Write Access        read/write
      LV Creation host, time localhost, 2019-07-18 20:04:32 +0800
      LV Status              available
      # open                 0
      LV Size                2.00 GiB    # 容量大小
      Current LE             512
      Segments               1
      Allocation             inherit
      Read ahead sectors     auto
      - currently set to     256
      Block device           252:2
    ```

- **文件系统阶段**

  - 创建文件系统

    ```bash
    root@localhost:~# mkfs.ext4 /dev/data-vg/mysql-lv
    mke2fs 1.42.13 (17-May-2015)
    Creating filesystem with 524288 4k blocks and 131072 inodes
    Filesystem UUID: 5ca6b0fb-aacb-4b26-99d5-7c28c9ff4829
    Superblock backups stored on blocks:
    	32768, 98304, 163840, 229376, 294912
    
    Allocating group tables: 完成
    正在写入inode表: 完成
    Creating journal (16384 blocks): 完成
    Writing superblocks and filesystem accounting information: 完成
    ```

  - 挂载目录

    ```bash
    root@localhost:~# mkdir /data/mysql2
    root@localhost:~# mount /dev/data-vg/mysql-lv /data/mysql2
    root@localhost:~# df -h | grep mysql2
    /dev/mapper/data--vg-mysql--lv  2.0G  3.0M  1.8G    1% /data/mysql2
    ```

#### 增加LV的容量

> 我们再前面创建了/dev/data-vg/mysql-lv的LV，它的容量是2G，现在我们想再增加2G。

   - 因为是`ext4`所以resize要用`resize2fs`。

     ```bash
     /dev/mapper/data--vg-mysql--lv  2.0G  3.0M  1.8G    1% /data/mysql2
     root@localhost:~# lvextend -L +2G /dev/data-vg/mysql-lv
       Size of logical volume data-vg/mysql-lv changed from 2.00 GiB (512 extents) to 4.00 GiB (1024 extents).
       Logical volume mysql-lv successfully resized.
     root@localhost:~# df -h | grep mysql2
     /dev/mapper/data--vg-mysql--lv  2.0G  3.0M  1.8G    1% /data/mysql2
     
     root@localhost:~# resize2fs /dev/data-vg/mysql-lv
     resize2fs 1.42.13 (17-May-2015)
     Filesystem at /dev/data-vg/mysql-lv is mounted on /data/mysql2; on-line resizing required
     old_desc_blocks = 1, new_desc_blocks = 1
     The filesystem on /dev/data-vg/mysql-lv is now 1048576 (4k) blocks long.
     
     root@localhost:~# df -h | grep mysql2
     /dev/mapper/data--vg-mysql--lv  3.9G  4.0M  3.7G    1% /data/mysql2
     root@localhost:~# blkid /dev/mapper/data--vg-mysql--lv
     /dev/mapper/data--vg-mysql--lv: UUID="5ca6b0fb-aacb-4b26-99d5-7c28c9ff4829" TYPE="ext4"
     ```

     现在`/data/mysql2`目录的大小由2G变成了4G。

     



