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
    1. 通用首部(General Header Fields): 请求报文和响应报文两方都会使用的首部
    2. 请求首部(Request Header Fields)：从客户端向服务端发送请求报文时使用的首部
    3. 响应首部(Response Header Fields)：从服务器端向客户端返回响应报文时使用的首部
    4. 实体首部(Entity Header Fields)：针对请求报文和响应报文的实体部分使用的首部
    
- `其它`：可能包含HTTP的RFC里未定义的首部（Cookie等）


**1. 通用首部字段**

首部字段名 | 说明
--- | ---
Cache-Control | 控制缓存的行为
Connection | 逐跳首部、连接的管理
Date | 创建报文的日期时间
Pragma | 报文指令
Trailer | 报文末端的首部一览
Transfer-Encoding | 指定报文主体的传输编码方式
Upgrade | 升级为其它协议
Via | 代理服务器的相关信息【使用代理的时候可以看到，没经过一层代理，会把代理名加入这里】
Warning | 错误通知

**2. 请求首部字段**

首部字段名 | 说明
--- | ---
Accept | 用户代理可处理的媒体类型
Accept-Charset | 优先的字符集
Accept-Encoding | 优先的内容编码
Accept-Language | 优先的语言（自然语言）`accept-language:zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=`
Authorization | Web认证信息（比如DRF的Token校验）
Expect | 期待服务器的特定行为
From | 用户的电子邮箱地址
Host | 请求资源所在的服务器
If-Match | 比较实体标记（ETag）
If-Modified-Since | 比较资源的更新时间
If-None-Match | 比较实体标记（与If-Match相反）
If-Range | 资源未更新时发送实体Byte的范围请求
If-Unmodified-Since | 比较资源的更新时间（与If-Modified-Since）
Max-Forwards | 最大传输逐跳数
Proxy-Authorization | 代理服务器徐璈客户端的认证信息
Range | 实体的字节范围请求(如：一张图片一次加载一部分)
Referer | 对请求中的URI的原始获取方
TE | 传输编码的优先级
User-Agent | HTTP客户端程序的信息（浏览器版本信息等）

**3. 响应首部字段**

首部字段名 | 说明
--- | ---
Accept-Ranges | 是否接受字节范围请求
Age | 推算资源创建经过时间
ETag | 资源的匹配信息
Location | 令客户端重定向至指定URI
Proxy-Authenticate | 代理服务器对客户端的认证信息
Retry-After | 对再次发起请求的时机要求
Server | HTTP服务器的安装信息
Vary | 代理服务器缓存的管理信息
WWW-Authenticate | 服务器对客户端的认证信息

**4. 实体首部字段**

首部字段名 | 说明
--- | ---
Allow | 资源科支持的HTTP方法
Content-Encoding | 实体主体适用的编码方式
Content-Language | 实体主体的自然语言
Content-Length | 实体主体的大小（单位：字节）
Content-Locatio | 替代对应资源的URI
Content-MD5 | 实体主体的报文摘要
Content-Range | 实体主体的位置范围
Content-Type | 实体主体的媒体类型
Expires | 实体主体过期的日期时间
Last-Modified | 资源的最后修改日期时间


另外首部字段还有`Cookie`、`Set-Cookie`、`Content-Disposition`等在其它RFC中定义的首部字段


**Set-Cookie字段的属性**

属性 | 说明
--- | ---
NAME=VALUE | 赋予Cookie的名称和其值（必须项）
expires=DATE | Cookie的有效期（若不明确指定则默认为浏览器关闭前为止）
path=PATH | 将服务器上的文件目录作为Cookie的适用对象（默认：文档所在的文件目录）
domain=域名 | 作为Cookie适用对象的域名（默认：创建cookie的服务器的域名）
Secure | 仅在HTTPS安全通信时才会发送Cookie
HttpOnly | 加以限制，使Cookie不能被JavaScript脚本访问


