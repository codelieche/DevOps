## shell获取操作系统监控信息

### uname
> Linux uname命令用于显示系统信息，uname可以显示电脑以及操作系统的相关信息。

**语法**：`uname [-amnrsv][--help][--version]`

**参数说明：**

- `-a`或`--all`: 显示全部的信息
- `-m`或`--machine`: 显示电脑类型32位还是64位
- `-n`或`--nodename`: 显示在网络上的主机名(hostname)
- `-r`或`--release`: 显示操作系统的发型版本:`Kernel Release`
- `-s`或`--sysname`: 显示操作系统名称 Linux
- `--help`: 显示帮助


```shell
[vagrant@localhost ~]$ uname
Linux
[vagrant@localhost ~]$ uname -a
Linux localhost.localdomain 3.10.0-693.17.1.el7.x86_64 #1 SMP Thu Jan 25 20:13:58 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
[vagrant@localhost ~]$ uname -m
x86_64
[vagrant@localhost ~]$ uname -n
localhost.localdomain
[vagrant@localhost ~]$ uname -r
3.10.0-693.17.1.el7.x86_64
[vagrant@localhost ~]$ uname -s
Linux
```

### hostname
> `hostname`命令用于显示和设置系统的主机名称。

**参数：**

- `-a`: 显示主机别名
- `-f`: 显示FQDN名称
- `-i`: 显示主机的ip地址
- `-I`: 显示主机的IP地址

```shell
[vagrant@localhost ~]$ hostname -a
localhost.localdomain localhost4 localhost4.localdomain4 localhost.localdomain localhost6 localhost6.localdomain6
[vagrant@localhost ~]$ hostname -f
localhost
[vagrant@localhost ~]$ hostname -i
::1 127.0.0.1
[vagrant@localhost ~]$ hostname -I
10.0.2.15
```

### 获取操作系统内存信息
> 以CentOS为例, 内存信息都在`/proc/meminfo`文件中。

**proc:**

> /proc是一种伪文件系统（也即虚拟文件系统），存储的是当前内核运行状态的一系列特殊文件，  
用户可以通过这些文件查看有关系统硬件及当前正在运行进程的信息，甚至可以通过更改其中某些文件来改变内核的运行状态。

**系统使用的内存：**

系统使用的内存 = 总共的内存 - 剩余内存
```
awk '/MemTotal/{total=$2}/MemFree/{free=$2}END{print (total -free)/1024}' /proc/meminfo
```

**应用使用的内存:**

应用使用内存 = Total -(Free + Cached + Buffers)

```
awk '/MemTotal/{total=$2}/MemFree/{free=$2}/^Cached/{cached=$2}/Buffers/{buffers=$2}END{print (total - free - cached - buffers)/1024}' /proc/meminfo
```

示例：

```shell
[vagrant@localhost ~]$ awk '/MemTotal/{total=$2}/MemFree/{free=$2}END{print (total -free)/1024}' /proc/meminfo
185
[vagrant@localhost ~]$ awk '/MemTotal/{total=$2}/MemFree/{free=$2}/^Cached/{cached=$2}/Buffers/{buffers=$2}END{print (total - free - cached - buffers)/1024}' /proc/meminfo
104.16
[vagrant@localhost ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            488          69         303           4         115         380
Swap:          1535           0        1535
```


