动态主机配置协议(Dynamic Host Configuration Protocol)，简称DHCP。

> 通过这个协议，网络管理员只需要配置一段共享的IP地址。  
> 每台新加入这个网络的机器，都可以通过DHCP协议来这个共享的IP地址里申请，然后自动配置好IP。  
> 当机器下线，离开的时候，把机器还回去，这样其它的机器就能用这个IP了。

- 我们主动规划服务器的IP，有点像买房自己装修。
- 而DHCP的方式相当于租房，你不要配置(装修), 都是帮你配置好的，你暂时用一下，用完退租就可以了。

### DHCP的工作方式
**注意：** DHCP Offer可以是广播包(Broadcast)也可能是单播(Unicast)，不同路由器会不同。

#### 第一步：DHCP Discover
> 当一台新的机器加入一个网络，它只知道自己的MAC地址，它需要个IP，这是它要做什么呢？
> 就是向这个接入的网络吼一句【广播】：我来了，有人吗？

#### 第二步：DHCP Offer
> 网络中配置了DHCP Server的话，它立刻知道来了一个新成员了。这时候知道需要租给它一个IP地址了，会把相应的包广播出去（或者单播包）。


#### 第三步：DHCP Request
> 这个时候新的机器收到了Offer的包，如果有多个Offer，它会选择其中一个(一般是最先到达的Offer)，机器发送一个DHCP Request的广播包。

### 第四步：DHCP ACK
> 当DHCP Server收到客户机的DHCP Request后，会广播DHCP ACK包（或者单播包）。 ACK消息包，表明已经接受客户机的选择，并将这一IP的合法租用信息和其它的配置信息都放入该广播包，发给客户机，欢迎新的成员加入网络。

客户端就可以利用这个IP上网了。


### Wireshark抓取DHCP包

为了抓到电脑通过DHCP获取IP的过程，我们先：
1. 关闭网卡en7：`sudo ifconfig en0 down`
2. 打开wireshark开始抓包
3. 开启网卡en7：`sudo ifconfig en0 up`
4. 查看ip：`ifconfig | ip addr`

```bash
en0: flags=8963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1500
	ether 88:e9:fe:85:bc:a0
	inet6 fe80::10c1:f44f:bc52:8003%en0 prefixlen 64 secured scopeid 0xb
	inet 192.168.89.103 netmask 0xfffff800 broadcast 192.168.95.255
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect
	status: active
```

或者先手动关闭wifi，然后开启抓包工具后，再打开wifi。

抓完包后，再wireshark的Filter中输入bootp就可以开始查看相关的包了。

#### 第一步：DHCP Discover包

```
Frame 1: 342 bytes on wire (2736 bits), 342 bytes captured (2736 bits) on interface 0
Ethernet II, Src: Apple_85:bc:a0 (88:e9:fe:85:bc:a0), Dst: Broadcast (ff:ff:ff:ff:ff:ff)
    Destination: Broadcast (ff:ff:ff:ff:ff:ff)
    Source: Apple_85:bc:a0 (88:e9:fe:85:bc:a0)
    Type: IPv4 (0x0800)
Internet Protocol Version 4, Src: 0.0.0.0, Dst: 255.255.255.255
User Datagram Protocol, Src Port: 68, Dst Port: 67
    Source Port: 68
    Destination Port: 67
    Length: 308
    Checksum: 0x1fdd [unverified]
    [Checksum Status: Unverified]
    [Stream index: 0]

Bootstrap Protocol (Discover)
    Message type: Boot Request (1)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0x601cf31b
    Seconds elapsed: 0
    Bootp flags: 0x0000 (Unicast)
    Client IP address: 0.0.0.0
    Your (client) IP address: 0.0.0.0
    Next server IP address: 0.0.0.0
    Relay agent IP address: 0.0.0.0
    Client MAC address: Apple_85:bc:a0 (88:e9:fe:85:bc:a0)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (Discover)
        Length: 1
        DHCP: Discover (1)
    .....
```
- Client端使用IP地址`0.0.0.0`发送一个广播包，目的地址：`255.255.255.255`
> Client想通过广播把这个数据包发给DHCP Server

- `User Datagram Protocol`下面是`Bootstrap Protocol`可以知道DHCP属于应用层协议，传输层用得是UDP协议，目标端口是`67`


**DHCP Discover广播包：**

| 层      | 内容                                                         |
| ------- | ------------------------------------------------------------ |
| MAC头   | 源MAC:`88:e9:fe:85:bc:a0`(新人的MAC); 目标MAC：`ff:ff:ff:ff:ff:ff` |
| IP头    | 源IP地址：`0.0.0.0`; 广播IP：`255.255.255.255`               |
| UDP头   | 源端口：`68`;目标端口：`67`                                  |
| BOOTP头 | Boot Request                                                 |


#### 第二步：DHCP Offer包
> 当DHCP服务器收到DHCP Discover数据包的时候，指定来了个新的成员了，给予客户端响应。

**注意：**当电脑以前连过这个网络，可能包中的目标地址不会是个0.0.0.0的IP

| 层      | 内容                                                         |
| ------- | ------------------------------------------------------------ |
| 层      | 内容                                                         |
| ---     | ---                                                          |
| MAC头   | 源MAC:`4c:f9:5d:8e:d5:de`(新人的MAC); 目标MAC：`ff:ff:ff:ff:ff:ff` |
| IP头    | 源IP地址：`192.168.1.1`; 广播IP：`255.255.255.255`           |
| UDP头   | 源端口：`67`;目标端口：`68`                                  |
| BOOTP头 | Boot Offer                                                   |

#### 第三步：DHCP Request包
> 当Client收到DHCP Offer后，多个Offer的话选择其中一个（一般都是最先到达的一个）。


**DHCP Request包：**

| 层      | 内容                                                         |
| ------- | ------------------------------------------------------------ |
| MAC头   | 源MAC:`88:e9:fe:85:bc:a0`(新人的MAC); 目标MAC：`ff:ff:ff:ff:ff:ff` |
| IP头    | 源IP地址：`0.0.0.0`; 广播IP：`255.255.255.255`               |
| UDP头   | 源端口：`68`;目标端口：`67`                                  |
| BOOTP头 | Boot Request                                                 |

#### 第四步：DHCP ACK包

**DHCP ACK包：**
| 层      | 内容                                                         |
| ------- | ------------------------------------------------------------ |
| MAC头   | 源MAC:`4c:f9:5d:8e:d5:de`(新人的MAC); 目标MAC：`ff:ff:ff:ff:ff:ff` |
| IP头    | 源IP地址：`192.168.1.1`; 广播IP：`255.255.255.255`           |
| UDP头   | 源端口：`67`;目标端口：`68`                                  |
| BOOTP头 | Boot Reply                                                   |


### DHCP过程
> 客户端：Client, DHCP服务端：Server

1. `Client ==== DHCP Discover ===> Server`
2. `Client <==  DHCP Offer ======= Server`
3. `Client ==== DHCP Request ====> Server`
4. `Client <=== DHCP ACK ========= Server`
5. `Client ==DHCP Request(renew)=> Server`
6. `Client <=== DHCP ACK ========= Server`


### DHCP Offer 和 DHCP ACK是广播还是单播
> 在第二步DHCP Offer和第四步DHCP ACK是广播还是单播，不同的路由器可能不同。  
> 比如：我抓的这个路由器，是广播还是单播，取决于客户端的DHCP Discover报文中的`Bootp Flags`字段。 

Boot Flags有两个字节：
- 如果最高位为1，代表回复的Offer为广播：`Boot flags = 0x8000`: Offer为广播
- 如果未0，代表回复的Offer为单播，其余Bits代表Reserved：`Boot flags = 0x0000`：Offer为单播

```
Bootstrap Protocol (Discover)
    Message type: Boot Request (1)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0x601cf32b
    Seconds elapsed: 4
    Bootp flags: 0x0000 (Unicast)
        0... .... .... .... = Broadcast flag: Unicast
        .000 0000 0000 0000 = Reserved flags: 0x0000
    Client IP address: 0.0.0.0
    Your (client) IP address: 0.0.0.0
```
可以看到`Bootp flags: 0x0000 (Unicast)`那么接下来收到的Offer会是单播包。