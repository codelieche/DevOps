## stress的基本使用

- CentOS安装stress:`yum install stress`
- Ubuntu安装：`apt-get install stress`

```bash
[root@localhost ~]# stress
`stress' imposes certain types of compute stress on your system

Usage: stress [OPTION [ARG]] ...
 -?, --help         show this help statement
     --version      show version statement
 -v, --verbose      be verbose
 -q, --quiet        be quiet
 -n, --dry-run      show what would have been done
 -t, --timeout N    timeout after N seconds
     --backoff N    wait factor of N microseconds before work starts
 -c, --cpu N        spawn N workers spinning on sqrt()
 -i, --io N         spawn N workers spinning on sync()
 -m, --vm N         spawn N workers spinning on malloc()/free()
     --vm-bytes B   malloc B bytes per vm worker (default is 256MB)
     --vm-stride B  touch a byte every B bytes (default is 4096)
     --vm-hang N    sleep N secs before free (default none, 0 is inf)
     --vm-keep      redirty memory instead of freeing and reallocating
 -d, --hdd N        spawn N workers spinning on write()/unlink()
     --hdd-bytes B  write B bytes per hdd worker (default is 1GB)

Example: stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 10s

Note: Numbers may be suffixed with s,m,h,d,y (time) or B,K,M,G (size).
```

**参数说明：**

1. `-?, --help`: 显示帮助信息
2. `--version`: 查看版本信息
3. `-v, --verbose`: 显示详细的信息
4. `-q, --quiet`: 不显示运行信息
5. `-n, --dry-run`: 显示已完成的指令情况
6. `-t, --timeout`: 指定运行N秒后停止
7. `--backoff N`: 等待N微秒后开始运行
8. `-c, --cpu`: 产生N个进程，每个进程反复执行`sqrt()`计算随机数的平方根
9. `-i, --io`: 产生N个进程，每个进程反复执行`sync()`将内存中的数据写到磁盘上
10. `-m, --vm`: 生成N个进程，每个进程不断的调用`malloc()/free()`分配和释放内存函数
11. `--vm-bytes B`: 指定malloc时内存的字节数(默认是：256MB)
12. `--vm-hang N`:  sleep N秒，在执行free之前，默认是o
13. `--vm-keep`: redirty memory instead of freeing and reallocating
14. `-d, --hdd N`: 生成N个执行`write()/unlink()`函数的进程
15. `--hdd-bytes B`: 指定写的字节数

---

### 示例1: stress cpu测试

#### 进程

> 在用户态将CPU耗尽。

Linux按照特权等级，把进程的运行空间分为内核空间(内核态)和用户空间(用户态)。

- 内核空间(CPU特权等级Ring 0）：最高权限，可以直接访问所有资源
- 用户空间(Ring 3): 只能访问受限资源，不能直接访问内存等硬件设备，想访问特权资源，必须通过**系统调用**到内核中。

我们查看文件内容时，就需要多次系统调用：

1. 首先调用`open()`打开文件
2. 然后调用`read()`读取文件内容
3. 调用`write()`将文件写到标准输出
4. 最后：再调用`close()`关闭文件。

#### 环境准备

- CentOS机器：8核，16G内存
- 安装stress和sysstat工具包
- 开三个终端

#### 执行命令

- uptime：查看负载的变化：

  ```bash
  [root@localhost ~]# watch -n 1 uptime
  Every 1.0s: uptime                                                          Wed Feb 27 15:18:40 2019
  
   15:18:40 up 9 days,  3:00,  5 users,  load average: 4.90, 1.56, 0.59
  ```

- 执行stress：

  ```bash
  [root@localhost ~]# stress -c 8 -t 60
  stress: info: [8249] dispatching hogs: 8 cpu, 0 io, 0 vm, 0 hdd
  ```

  显示详细的信息：

  ```bash
  [root@localhost ~]# stress -c 8 -v -t 60
  stress: info: [8483] dispatching hogs: 8 cpu, 0 io, 0 vm, 0 hdd
  stress: dbug: [8483] using backoff sleep of 24000us
  stress: dbug: [8483] setting timeout to 60s
  stress: dbug: [8483] --> hogcpu worker 8 [8484] forked
  stress: dbug: [8483] using backoff sleep of 21000us
  stress: dbug: [8483] setting timeout to 60s
  # ....
  stress: dbug: [8483] --> hogcpu worker 1 [8491] forked
  stress: dbug: [8483] <-- worker 8484 signalled normally
  # ....
  stress: info: [8483] successful run completed in 60s
  ```

- 执行pidstat: 

  > 间隔5秒输出一组CPU的指标数据, -u: 表示CPU指标

  ```bash
  [root@localhost ~]# pidstat -u 5 1
  Linux 3.10.0-862.el7.x86_64 (localhost) 	02/27/2019 	_x86_64_	(4 CPU)
  
  03:24:50 PM   UID       PID    %usr %system  %guest    %CPU   CPU  Command
  03:24:55 PM     0      9080   46.34    0.00    0.00   46.34     3  stress
  # ...
  03:24:55 PM     0      9148    0.00    0.20    0.00    0.20     0  pidstat
  03:24:55 PM     0     26155    0.20    0.00    0.00    0.20     0  containerd
  ```

---

### 示例2：stress io测试

- 终端执行: `watch -d uptime`

  ```bash
  Every 2.0s: uptime                                                          Wed Feb 27 15:32:25 2019
  
   15:32:25 up 9 days,  3:14,  6 users,  load average: 8.11, 3.67, 1.93
  ```

- 执行stress

  ```bash
  [root@localhost ~]# stress -i 8 -t 120
  stress: info: [9747] dispatching hogs: 0 cpu, 8 io, 0 vm, 0 hdd
  ```

- 执行统计信息

  - mpstat -P ALL 10 1

    ```bash
    [root@localhost ~]# mpstat -P ALL 10 1
    Linux 3.10.0-862.el7.x86_64 (localhost) 	02/27/2019 	_x86_64_	(4 CPU)
    
    03:44:34 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
    03:44:44 PM  all    0.28    0.00   84.28    0.30    0.00    0.00    0.00    0.00    0.00   15.13
    # ...
    ```

  - Pidstat -u 10 1 

    ```bash
    [root@localhost ~]# pidstat -u 10 1
    Linux 3.10.0-862.el7.x86_64 (localhost) 	02/27/2019 	_x86_64_	(4 CPU)
    
    03:44:49 PM   UID       PID    %usr %system  %guest    %CPU   CPU  Command
    03:44:59 PM     0     10496    0.10   41.26    0.00   41.36     0  stress
    03:44:59 PM     0     10497    0.10   41.86    0.00   41.96     0  stress
    # ...
    
    Average:      UID       PID    %usr %system  %guest    %CPU   CPU  Command
    Average:        0     10496    0.10   41.26    0.00   41.36     -  stress
    Average:        0     10497    0.10   41.86    0.00   41.96     -  stress
    # ...
    ```

---

### 示例3：memory测试

1. `-m, --vm`: 生成N个进程，每个进程不断的调用`malloc()/free()`分配和释放内存函数
2. `--vm-bytes B`: 指定malloc时内存的字节数(默认是：256MB)
3. `--vm-hang N`:  sleep N秒，在执行free之前，默认是0
4. `--vm-keep`: redirty memory instead of freeing and reallocating



- 执行stress命令

  > 启动8个进程，malloc去分配内存，分配512M, 保持60秒后释放

  ```bash
  [root@localhost ~]# stress --vm 8 --vm-bytes 512M --vm-hang 60 --timeout 180
  stress: info: [10970] dispatching hogs: 0 cpu, 0 io, 8 vm, 0 hdd
  ```
