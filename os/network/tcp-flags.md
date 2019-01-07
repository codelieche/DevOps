## TCP协议中的标识

- `CWR`: Congestin Window Reduced(CWR)
- `E`: ECE 显示拥塞提醒回应 ECN-Echo
    - `CWR`和`ECE`用于传输过程中拥塞控制，与TCP的窗口协同工作
- `U`: URG 紧急 Urgent
- `A`: ACK 应答 acknowledgment
- `P`: PUSH 推送: 数据包立即发送
- `R`: RST 复位: 中断一个连接，连接重置
- `S`: SYN 同步:表示开始会话请求
- `F`: FIN 结束：结束会话


**抓包示例：**
```
Transmission Control Protocol, Src Port: 443, Dst Port: 49508, Seq: 1114, Ack: 695, Len: 213
    Source Port: 443
    Destination Port: 49508
    Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgment: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
        [TCP Flags: ·······AP···]
    Window size value: 8
```
- 值`1`表示当前位设置了
- 值`0`表示未设置

### 标志位
- SYN、ACK用得最多

#### SYN：同步标记
> Synchronisation flag：

#### ACK：确认标记
> Acknowledgement: 确认标记用于确认数据包的成功接收。

#### PUSH：推送标记
> 推送标记，以确保数据优先处理，并在发送或者接收端处理。  
> 这个标记在数据传输的开始和结束时被非常频繁的使用，影响数据在两端的处理的方式。

#### FIN：完成标记
> FINISH:完成。该标记用于端口SYN创建的虚拟连接，当连接之间最后一个数据包时，总是出现FIN标记。

#### TCP连接：三次握手标记位变化
> 客户端Client A；服务端ServerB。
- 步骤1：`Client A ===== SYN ====> Server B`: 请求
- 步骤2：`Client A <== SYN,ACK ==> Server B`：请求之应答
- 步骤3：`Client A ===== ACK ====> Server B`：应答之应答

**状态说明：**
- 步骤1时：
    1. `Client A`主动发起连接SYN，发送后`Client A`处于`SYN_SENT`状态
    2. `Server B`收到发起的连接，返回SYN，并ACK请求，之后处于`SYN_RCVD`状态
- 步骤2：
    1. `Client A`: 收到`SYN, ACK`后，状态称为了`ESTABLISHED`状态
    2. `Server B`：还是`SYN_RCVD`状态
- 步骤3：
    1. `Client A`: 已经是`ESTABLISHED`状态
    2. `Server B`在收到了`ACK`的`ACK`后，状态也为`ESTABLISHED`了。


#### TCP断开：四次挥手标记位
> 客户端Client A；服务端ServerB。

- 数据传输：`Client A <=== Data Transfer ===> Server B`
- 步骤1：`Client A ==== FIN, ACK ====> Server B`: 
- 步骤2：`Client A <=======  ACK =====> Server B`：
- 步骤3：`Client A <==== FIN, ACK ===== Server B`
- 步骤4：`Client A =======  ACK ======> Server B`

**状态说明：**
- `数据传输`的时候`Client A`和`Server B`其状态都是`ESTABLISHED`
- 步骤1：客户端说：我不玩了
    1. `Client A`发出了我不玩了的请求后，进入`FIN_WAIT_1`状态
    2. `Server B`收到请求后，知道client A不玩了，就进入`CLOSE_WAIT`状态
- 步骤2：服务端说：我知道了
    1. `Client A`收到了ACK后，由`FIN_WAIT 1`进入`FIN_WAIT 2`状态
    2. `Server B`还是`CLOSE_WAIT`状态
- 步骤3：服务端说：我也不玩了
    1. `Client A`: 收到了服务端说它也不玩后，进入`TIME-WAIT`状态
    2. `Server B`: 服务发出不玩了请求后，进入`LAST-ACK`状态，等待Client A的最后确认
- 步骤4：客户端说：我收到你也玩的消息了
> 如果CLient A发出的ACK，Server B未收到，Server B会继续发：服务端我不玩了的消息过来。
>     1. `Client A`: 此时A会继续等待一段时间，然后CLOSED状态
>     2. `Server B`: 收到ACK后进入CLOSE状态，断开连接确认
>     3. Client的等待时间是**2MSL**， `Maximum Segment Lifetime`报文最大生存时间。

---

