## Linux Network Namespace

命名空间相关的命令：

- `ip netns list`: 查看网络命名空间
- `ip netns add test1`: 添加网络命名空间
- `ip netns delete test1`: 删除网络命名空间

在不同的命名空间中执行命令：

- `ip netns exec test1 ip a`: 在test1网络命名空间中执行`ip a`命令

- `ip netns exec test1 ip link`: 在test1网络命名空间中执行`ip link`命令

- `ip netns exec test1 ip link set dev lo up`: 启动网卡

  ```bash
  root@localhost:~# ip netns exec test1 ip a
  1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  root@localhost:~# ip netns exec test1 ip link
  1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  root@localhost:~# ip netns exec test1 ip link set dev lo up
  root@localhost:~# ip netns exec test1 ip addr
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
      inet 127.0.0.1/8 scope host lo
         valid_lft forever preferred_lft forever
      inet6 ::1/128 scope host
         valid_lft forever preferred_lft forever
  ```

### Veth Pair

Veth Pair是成对出现的，Veth Pair设备的特点：

> 它被创建出来后，总是两张虚拟网卡(Veth Pear)的形式成对出现的。  
>
> 并且，从其中一个网卡发出的数据包，可以直接出现在对应的另一张网卡上，哪怕这两个网卡在不同的Network Namespace里。

- 在linux中创建Veth Pair设备

```bash
root@localhost:~# ip link add veth-test1 type veth peer name veth-test2
root@localhost:~# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:50:56:9d:fc:ad brd ff:ff:ff:ff:ff:ff
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:8a:ca:8b:01 brd ff:ff:ff:ff:ff:ff
4: veth-test2@veth-test1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 26:37:a3:35:a5:6f brd ff:ff:ff:ff:ff:ff
5: veth-test1@veth-test2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ba:14:cf:a3:5c:79 brd ff:ff:ff:ff:ff:ff
```

- 把这两个虚拟网卡添加到前面创建的命名空间中

  1. `ip link set veth-test1 netns test1`
  2. `ip link set veth-test2 netns test2`

  ```bash
  root@localhost:~# ip netns exec test1 ip link
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  root@localhost:~# ip link set veth-test1 netns test1
  root@localhost:~# ip netns exec test1 ip link
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  5: veth-test1@if4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
      link/ether ba:14:cf:a3:5c:79 brd ff:ff:ff:ff:ff:ff link-netnsid 0
  ```

- 给Veth Pair两个虚拟网卡分配IP地址

  - `ip netns exec test1 ip addr add 172.17.0.101/24 dev veth-test1`
  - `ip netns exec test1 ip addr add 172.17.0.102/24 dev veth-test2`

  ```bash
  root@localhost:~# ip netns exec test1 ip addr add 172.17.0.101/24 dev veth-
  root@localhost:~# ip netns exec test1 ip link
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  5: veth-test1@if4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
      link/ether ba:14:cf:a3:5c:79 brd ff:ff:ff:ff:ff:ff link-netnsid 0
      
  root@localhost:~# ip netns exec test1 ip addr
  # .....
  5: veth-test1@if4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
      link/ether ba:14:cf:a3:5c:79 brd ff:ff:ff:ff:ff:ff link-netnsid 0
      inet 172.17.0.101/24 scope global veth-test1
         valid_lft forever preferred_lft forever
  ```

  可以通过`ip addr`命令查看到`test1`中的`vetg-test1`已经有了IP。

  ```bash
  root@localhost:~# ip link set veth-test2 netns test2
  root@localhost:~# ip netns exec test2 ip addr add 172.17.0.102/24 dev veth-test2
  root@localhost:~# ip netns exec test2 ip addr
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
      inet 127.0.0.1/8 scope host lo
         valid_lft forever preferred_lft forever
      inet6 ::1/128 scope host
         valid_lft forever preferred_lft forever
  4: veth-test2@if5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
      link/ether 26:37:a3:35:a5:6f brd ff:ff:ff:ff:ff:ff link-netnsid 0
      inet 172.17.0.102/24 scope global veth-test2
         valid_lft forever preferred_lft forever
  ```

  **注意：**通过命令查看`veth-test1`和`veth-test2`其状态是`DOWN`的哦。

- 启动两个网卡：

  - `ip netns exec test1 ip link set dev veth-test1 up`
  - `ip netns exec test2 ip link set dev veth-test2 up`

  ```bash
  root@localhost:~# ip netns exec test1 ip link set dev veth-test1 up
  root@localhost:~# ip netns exec test1 ip link
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  5: veth-test1@if4: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state LOWERLAYERDOWN mode DEFAULT group default qlen 1000
      link/ether ba:14:cf:a3:5c:79 brd ff:ff:ff:ff:ff:ff link-netnsid 1
  ```

  可以看到`veth-test1`的状态是**UP**了

- ping不同命名空间中的IP地址：

  ```bash
  root@localhost:~# ip netns exec test1 ping 172.17.0.102
  PING 172.17.0.102 (172.17.0.102) 56(84) bytes of data.
  64 bytes from 172.17.0.102: icmp_seq=1 ttl=64 time=0.116 ms
  64 bytes from 172.17.0.102: icmp_seq=2 ttl=64 time=0.055 ms
  64 bytes from 172.17.0.102: icmp_seq=3 ttl=64 time=0.102 ms
  ^C
  --- 172.17.0.102 ping statistics ---
  3 packets transmitted, 3 received, 0% packet loss, time 1998ms
  rtt min/avg/max/mdev = 0.055/0.091/0.116/0.026 ms
  root@localhost:~# ip netns exec test2 ping 172.17.0.101
  PING 172.17.0.101 (172.17.0.101) 56(84) bytes of data.
  64 bytes from 172.17.0.101: icmp_seq=1 ttl=64 time=0.073 ms
  64 bytes from 172.17.0.101: icmp_seq=2 ttl=64 time=0.073 ms
  ^C
  --- 172.17.0.101 ping statistics ---
  2 packets transmitted, 2 received, 0% packet loss, time 999ms
  rtt min/avg/max/mdev = 0.073/0.073/0.073/0.000 ms
  ```

