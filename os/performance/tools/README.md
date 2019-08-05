## Linux Performance Tools

> OS提供许许多多的工具来观察系统的软件和硬件。

### 安装软件

- yum install -y epel-release

- stress： yum install stress
- sysstat: yum install sysstat



### 工具类型

性能工具可以按照**系统级别**和**进程级别**来分类，多数的工具要么基于**计数器**要么基于**跟踪**



#### 计数器

> 内核维护着各种统计数据，称为计数器，用于对事件计数。
>
> 通常计数器实现为无符号的整型数，发生事件的时候递增。例如：有网络包接收的计数器，磁盘I/O发生的计数器，也有系统调用执行的计数器。

计数器的使用可以认为是“零开销”的，因为它们默认就开启的，而且始终由内核维护。

唯一的使用开销是从用户空间读取它们的时候（可忽略不计）。



##### 系统级别

> 下面这些工具利用内核的计数器在系统软件硬件的环境中检查系统级别的活动。

- `vmstat`: 虚拟内存和物理内存的统计，系统级别。
- `mpstat`: 每个CPU的使用情况
- `iostat`: 每个磁盘I/O的使用情况，由块设备接口报告
- `netstat`: 网络接口的统计，TCP/IP栈的统计，以及每个连接的一些统计信息。
- `sar`: 各种各样的统计，能归档历史数据。

这些工具通常是系统全体用户可见的（非root用户）。统计出的数据也常常被监控软件用来绘图。

这些工具有一个使用惯例，即可选时间间隔和次数。比如：`vmstat(8)`用一秒作为时间间隔，输出2次

```bash
root@node3:~# vmstat 1 2
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0    640 6167268 281848 1206560    0    0     7   158    1    8  0  0 99  0  0
 1  0    640 6167588 281848 1205808    0    0     0 21024  358  914  2  1 84 13  0
```



##### 进程级别

> 下面这些工具是以进程为导向的，使用的是内核为每个进程维护的计数器。

- `ps`: 进程状态，显示进程的各种统计信息，包括内存和CPU的使用
- `top`: 按一个统计数据（如CPU使用）排序，显示排名高的进程
- `pmap`: 将进程的内存段和使用统计一起列出

> 一般来说，上述这些工具是从`/proc`文件系统里读取统计信息的。



#### 跟踪

> 跟踪收集每一个事件的数据以供分析。
>
> 跟踪框架一般默认是不开启的，因为跟踪捕获数据会有CPU开销，另外还需要不小的存储空间来存放数据。
>
> 这些开销会拖慢所跟踪的对象，在解释测量时间的时候需要加以考虑。

日志，包括日志系统，可以认为是一种默认开启的低频率跟踪。

##### 系统级别

> 利用内核的跟踪设施，下面这些跟踪工具在系统软件硬件的环境中检查系统级别的活动。

- `tcpdump`: 网络包跟踪（利用libpcap库）
- `snoop`: 为基于Solaris的系统打造的网络包跟踪工具
- `blktrace`: 块I/O跟踪（Linux）
- `iosnoop`: 块I/O跟踪（基于DTrace）
- `execsnoop`: 跟踪新进程（基于DTrace）
- `dtruss`: 系统级别的系统调用缓冲跟踪（基于DTrace）
- `DTrace`: 跟踪系统内核的内部活动和所有资源的使用情况（不仅仅是网络和块I/O），支持静态和动态的跟踪
- `SystemTap`: 跟踪内核的内部活动和所有资源的使用情况，支持静态和动态的跟踪
- `perf`: Linux性能事件，跟踪静态和动态的探针

> DTrace和SystemTap都是可编程环境，在它们之上可以构建系统级别的跟踪工具，在前面的列表中已经包括了一些。

##### 进程级别

> 下面这些跟踪工具是以进程为导向的，基于的是操作系统提供的框架。

- `strace`: 基于Linux系统的系统调用跟踪
- `truss`: 基于Solaris系统的系统调用跟踪
- `gdb`: 源代码级别的调试器，广泛应用于Linux系统
- `mdb`: Solaris系统的一个具有可扩展性的调试器

调试器能够检查每一个事件的数据，不过做这件事情时需要停止目标程序的执行，然后启动。



#### 剖析

> 剖析(profiling)通过对目标收集采样或快照来归纳目标特征。

##### 系统级别和进程级别

> 下面是一些剖析器的例子，这些工具所做的剖析都是基于时间并基于硬件缓存的。

- `oprofile`: Linux系统剖析
- `perf`: Linux性能工具集，包含有剖析的子命令
- `DTrace`: 程序化剖析，基于时间的剖析用自身的`profile provider`, 基于硬件事件的剖析`cpc provider`
- `SystemTap`: 程序化剖析，基于时间的剖析用自身的`timer tapset`, 基于硬件事件的剖析用自身`perf tapset`
- `cachegrind`: 源自`valgrind`工具集，能对硬件缓存的使用做剖析，也能用`kcachegrind`做数据可视化
- `Intel VTune Amplifier XE`: Linux和Windows的剖析，拥有包含源代码浏览在内的图形界面
- `Oracle Solaris Studio`: 用自带的性能分析器对`Solaris`和`Linux`做剖析，拥有包括源代码浏览在内的图形界面



### 观测来源

> 系统性能统计的主要来源是：`/proc`、`/sys`和`kstat`。

- **/proc**

  > 这是一个提供内核统计信息的文件系统接口。`/proc`包含很多的目录，其中以进程ID命名的目录代表的就是那个进程。
  >
  > 这些目录下的众多文件包含了进程的信息和统计数据，由内核数据结构映射而来。
  >
  > 在Linux中，/proc还有其它的文件，提供系统级别的统计数据。

  `/proc`由内核动态创建，不需要任何存储设备（在内存中运行）。多数文件是只读的，为观测工具提供统计数据。一部分文件是可写的，用于控制进程和内核的行为。

- 进程统计文件

  > 先查看个进程示例：

  ```bash
  root@node3:~# ls /proc/1292
  attr        cmdline          environ  io         mem         ns             pagemap      schedstat  stat     timers
  autogroup   comm             exe      limits     mountinfo   numa_maps      personality  sessionid  statm    timerslack_ns
  auxv        coredump_filter  fd       loginuid   mounts      oom_adj        projid_map   setgroups  status   uid_map
  cgroup      cpuset           fdinfo   map_files  mountstats  oom_score      root         smaps      syscall  wchan
  clear_refs  cwd              gid_map  maps       net         oom_score_adj  sched        stack      task
  ```

  - `limits`: 实际的资源限制
  - `map`: 映射的内存区域
  - `sched`: CPU调度器的各种统计
  - `schedstat`: CPU运行时间、延时和时间分片
  - `smaps`: 映射内存区域的使用统计
  - `stat`: 进程状态和统计，包括总的CPU和内存的使用情况
  - `statm`: 以页为单位的内存使用总结
  - `status`: `stat`和`statm`的信息，用户可读
  - `task`: 每个任务的统计目录

- 系统级别的文件

  > Linux将`/proc`延伸到了系统级别的统计，包括下面这些额外的文件和目录：

  - `cpuinfo`: 物理处理器信息，包含所有虚拟CPU、型号、时钟频率和缓存大小
  - `diskstats`: 对于所有磁盘设备的磁盘I/O统计
  - `interrupts`: 每个CPU中断计数器
  - `loadavg`: 负载平均值
  - `meminfo`: 系统内存使用明细
  - `net/dev`: 网络统计接口
  - `net/tcp`: 活跃的TCP套接字信息
  - `schedstat`: 系统级别的CPU调度器统计
  - `self`: 关联当前进程ID路径的符号链接，为了使用方便
  - `slabinfo`: 内核slab分配器缓存统计
  - `stat`: 内核和系统资源的统计，CPU、磁盘、分页、交换区、进程
  - `zoneinfo`: 内存区信息

  系统级别的工具会读取这些文件。

- /sys

  > Linux还提供了一个sysfs文件系统，挂载在`/sys`，这是在2.6内核引入的，为内核统计提供一个基于目录的结构。



- kstat

