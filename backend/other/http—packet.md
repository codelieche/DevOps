## HTTP 报文
> 用于HTTP协议交互的信息被称之为HTTP报文。  
请求端（客户端）的HTTP报文叫做请求报文，响应端（服务器端）的叫做响应报文。  
HTTP报文本身是由多行（用CR + LF作为换行符）数据构成的字符串文本。

HTTP报文有两块：  
1. 报文首部：包含服务器和客户端需处理的请求或响应的内容及属性
2. 报文主体(通常，不一定有报文主体): 是应该被发送的数据

示例：

```
➜  study http :8080/api/1.0/account/login
HTTP/1.0 200 OK
Allow: GET, POST, HEAD, OPTIONS
Content-Length: 18
Content-Type: application/json
Date: Tue, 23 Jan 2018 13:35:43 GMT
Server: WSGIServer/0.2 CPython/3.5.3
Vary: Accept, Cookie
X-Frame-Options: SAMEORIGIN

{
    "logined": false
}
```

### 请求报文及响应报文的结构
**1. 请求报文**
- 报文首部：
    1. 请求行
    2. 请求首部字段
    3. 通用首部字段
    4. 实体首部字段
    5. 其它
    
- 空行（CR + LF）
- 报文主体

**2. 响应报文**
- 报文首部：
    1. 状态行
    2. 响应首部字段
    3. 通用首部字段
    4. 实体首部字段
    5. 其它
    
- 空行（CR + LF）
- 报文主体

#### 报文首部说明
- `请求行`: 包含用于请求的方法，请求URI和HTTP版本
- `状态行`: 包含表明响应结果的状态码(200, 30x, 40x, 50x)，原因短语和HTTP版本。
- `首部字段`: 包含表示请求和响应的各种条件和属性的各类首部，一般有四种首部：
    1. 通用首部
    2. 请求首部
    3. 响应首部
    4. 实体首部
    
- `其它`：可能包含HTTP的RFC里未定义的首部（Cookie等）

