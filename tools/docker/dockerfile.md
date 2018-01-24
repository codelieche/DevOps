## Dockerfile基本使用
> Docker提供了一个`docker commit`命令，可以将容器的存储层保存下来成为镜像。  
换句话说：就是在原有镜像的基础上，再叠加上容器的存储层，并构成新的镜像。  
**注意：**定制镜像应该使用Dockerfile。

镜像的定制实际上就是定制每一层所添加的配置、文件。  
我们把每一层修改、安装、构建、操作的命令都写入一个脚本，用这个脚本来构建、定制镜像。这个脚本就是Dockerfile。

Dockerfile是一个文本文件，其内包含了一条条的指令(Instruction)，每一条指令构建一层，因此每一条指令的内容，就是描述该层应当如何构建。



### Dockerfile语法
- `FROM`: base image，指定基础镜像（不需要有操作系统提供运行时支持FROM scratch）
- `RUN`: 执行命令
- `ADD`: 添加文件
- `COPY`: 拷贝文件
- `CMD`: 执行命令
- `EXPOSE`: 暴露端口
- `WORKDIR`: 指定路径
- `MAINTAINER`: 维护者
- `ENV`: 设定环境变量
- `ENTRYPOINT`: 容器入口
- `USER`: 指定用户
- `VOLUME`: mount point

### 镜像分层
> Dockerfile中的每一行都产生一个新层。  
镜像是多层存储，每一层是在前一层的基础上进行修改。  
容器同样也是多层存储的，是在以镜像为基础层，在其基础上加一层作为容器运行时的存储层。

```
FROM python:3.6.3-slim  78dfsafjslfl
MAINTAINER codelieche   fasdbasldjl13
CMD echo "Hello Docker"   ldl45364777
```
## Dockerfile指令

### FROM 指定基础镜像

> 所谓定制镜像，那一定是以一个镜像为基础，在其上进行定制。  

`FROM`就是指定基础镜像，因此一个`Dockerfile`中`FROM`是必备的指令，并且必须是第一条指令。  
在Docker Store上有很多高质量的官方镜像，可以直接拿来使用。  

**scratch：**  
`scratch`是一个特殊的镜像，这个镜像是虚拟的概念，并不实际存在，它表示一个空白的镜像。  
比如：`swarm`,`coreos/etcd`，对于linux下静态编译的程序来说，并不需要有操作系统提供运行时支持，所需的一切库都已经在可执行文件里了，因此直接`FROME scratch`会让镜像体积更加小巧。  

> 使用Go语言开发的应用很多会使用这种方式来制作镜像，这也是为什么有人认为Go是贴别适合容器微服务架构的语言的原因之一。

### RUN 执行指令
`RUN`指令是用来执行命令行命令的，有2种格式：

1. shell格式：`RUN <命令>`,就像直接在命令行中输入的命令一样。
2. exec格式：`RUN ["可执行文件", "参数1", "参数2"]`, 这更像是函数调用中的格式。

**注意：**每次RUN都会创建一层，所以多条命令记得连起来（`&&`）执行。

### COPY 复制文件

格式：
- `COPY <源路径> ... <目标路径>`
- `COPY ["源路径1", ... "<目标路径>"]`

> `COPY`指令将从构建上下文目录中`<源路径>`的文件/目录复制到新的一层的镜像内的`<目标路径>`位置。比如：  

```
COPY ./settings.py /var/www/app/
```

`<目标路径>`可以是容器内的绝对路径，也可以是相对于工作目录的相对路径。  
工作目录可以用`WORKDIR`指令来指定。  
目标路径不需要事先创建，如果目录不存在会在复制文件前先行创建缺失目录。

### ADD 更高级的复制文件

`ADD`指令和`COPY`的格式和性质基本一致。但是在`COPY`基础上增加了一些功能呢。

比如`<源路径>`可以是一个`URL`，这种情况下，Docker引起会试图去下载这个链接的文件放到`<目标路径>`去。  
下载后的文件权限自动设置为`600`。

### CMD 容器启动命令
`CMD`指令的格式和`RUN`相似，也是2种格式：  
- `shell`格式：`CMD <命令>`
- `exec`格式：`CMD ["可执行文件", "参数1", "参数2"]`

> Docker不是虚拟机，容器中的应用都应该以前台执行，而不是像虚拟机、物理机里面那样，用`upstart/sysemd`去启动后台服务，容器内没有后台服务的概念。

比如：`service nginx start`命令，会被理解为`CMD ["sh", "-c", "service nginx start"]`，因此主进程实际上是`sh`。那么`service nginx start`命令结束后，`sh`也就结束了，`sh`作为主进程退出了，自然就会命令容器退出。

正确的做法是直接执行`nginx`可执行文件，并且要求以前台形式运行。比如：

```
CMD ["nginx", "-g", "daemon off;"]
```

### ENTRYPOINT 入口点
`ENTRYPOINT`的格式和`RUN`指令格式一样，分别是`exec`格式和`shell`格式。

`ENTRYPOINT`的目的和`CMD`一样，都是在指定容器启动程序及参数。  
当指定了`ENTRYPOINT`后，`CMD`的含义就发生了改变，不在是直接的运行其命令，而是将`CMD`的内容作为参数传给`ENTRYPOINT`指令。  
换句话说实际执行时，将变成：`<ENTRYPOINT> "<CMD>"`。

比如想切换用户来执行相关操作，可以用到ENTRYPOINT. 写个`docker-entrypoint.sh`处理CMD指令。


### ENV 设置环境变量
2种格式：
- `ENV <key> <value>`
- `ENV <key1>=<value1> <key2>=<value2>...`


### VOLUME 定义匿名卷
格式为：
- `VOLUME ["<路径1>", "<路径2>"]`
- `VOLUME <路径>`

> 容器运行时尽量保持容器存储层不发生写操作，对于数据库类需要保存冬天数据的应用，其数据库文件应该保持存于(`volume`)中。  
在`Dockerfile`中，我们可以事先指定某些目录挂载为匿名卷，这样在运行时如果用户不指定挂载，其应用也可以正常运行，不会向容器存储层写入大量数据。

```
VOLUME /data
```
这里的`/data`目录就会在运行时自动挂载为匿名券，任何向`/data`中写入的信息都不会记录进容器存储层，从而保证了容器存储层的无状态化。  
运行时可以覆盖这个挂载设置。

```
docker run -d -v mydata:/data redis
```

### EXPOSE 声明端口
格式为`EXPOSE <端口1> [<端口2>...]`

`EXPOSE`指令是声明运行容器提供服务端口，这只是一个声明，在运行时并不会因为这个声明应用就会开启这个端口的服务。

```
docker -p <宿主机端口>:<容器端口>
```

### WORKDIR 指定工作目录

格式：`WORKDIR <工作目录路径>`  
使用`WORKDIR`指令可以来指定工作目录（或者称之为当前目录），以后各层的当前目录就被改为指定的目录，如该目录不存在，`WORKDIR`会帮你建立目录。

### USER 指定当前用户

格式：`USER <用户名>`  
`USER`指令和`WORKDIR`相似，都是改变环境状态并影响以后的层。  
`WORKDIR`是改变工作目录，`USER`则是改变之后层的执行`RUN`,`CMD`以及`ENTRYPOINT`这类命令的身份。

注意：事先请先确保有这个用户，没有请先创建。  

```
RUN groupadd -r devops && useradd -r -g devops devops
USER devops
RUN ["xxxxx"]
```

### HEALTHCHECK 监控检查



### docker build

`docker build .`中的`.`其实是指上下文目录。  
docker build命令得知这个路径后，会将路径下的所有内容打包，然后上传给Docker引擎。

```
COPY ./settings.py /app/
```
这个命令并不是要复制执行`docker build`命令所在的目录下的`settings.py`文件,  
也不是复制`Dockerfile`所在目录下的`settings.py`,  
**而是**复制上下文(`context`)目录下的`settings.py`。  

因此：`COPY`之类指令中的源文件的路径都是相对路径。  
**特别注意**：超出上下文范围的文件，Docker引擎是无法获取这些位置的文件的。  
比如: `../settings.py`, `/var/www/source/settings.py`都是无法工作的。



