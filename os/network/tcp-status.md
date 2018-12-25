### TCP连接时的状态

> 客户端A和服务端B

- 最开始的时候客户端A和服务端B都是出于`CLOSED`的状态

- 显示服务端主动监听某个端口，比如80，处于`LISTEN`状态, 通过`netstat -an | grep tcp | grep LISTEN`可以查看哪些端口在监听状态



  TCP三次握手时状态：`请求(客户端A) >> 应答(服务端B) >> 应答之应答(客户端A)`

- **客户端A --> 服务端B**：客户端A主动发起连接**SYN**，发送后处于`SYN_SENT`状态

- 服务端B在收到发起的连接，返回**SYN**，并且**ACK**客户端A的**SYN**，之后处于`SYN_RCVD`状态

- **服务端B --> 客户端A**：客户端A收到服务端B发送的**SYN**和**ACK**之后，发送**ACK**的**ACK**，之后处于`ESTABLISHED`状态

- **客户端A --> 服务端B**：服务器B收到客户端A的**ACK**的**ACK**之后，也处于`ESTABLISHED`状态。

### TCP断开连接时的状态



### 统计TCP各连接状态的数量

```bash
$ netstat -an | awk '/^tcp/ {++dict[$NF]} END {for (i in dict) print i, dict[i]}'
LISTEN 17
ESTABLISHED 95
SYN_SENT 1
TIME_WAIT 163
```



