## Docker 基本使用
> Docker 是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。容器是完全使用沙箱机制，相互之间不会有任何接口。

### 镜像相关操作
- 查看下载的镜像: `docker images`
- 查找镜像: `docker search ubuntu`
- 下载镜像: `docker pull ubuntu:latest` 从仓库中下载镜像,默认是latest标签的
- 删除镜像: `docker rmi name/id/tag` 有容器在运行的镜像不能删除
- 镜像打标签: `docker tag ubuntu:latest ubuntu:14.04`
- 保存镜像: `docker save -o ./ubuntu.14.04.tar ubuntu:14.04`
- 导入镜像: `docker load ./ubuntu14.04.tar`
- 查看镜像(容器信息): `docker inspect ubuntu:latest`
- 通过Dockerfile构建镜像: `docker build`
- 查看指定镜像的创建历史: `docker history [options] IMAGE`

### 容器操作
- 列出所有容器: `docker ps -a`
- 创建个容器但是不启动: `docker create` 用法类似`docker run`
- 运行个容器: `docker run -i -t -d ubuntu:14.04`
- 启动/停止/重启: `docker start/stop/restart name`
- 连接到正在运行的容器: `docker attach ubuntu`
- 获取容器日志: `docker logs [options] CONTAINER`参数:`-f`,`-t`,`--tail`,`--since`

#### 运行容器参数:
- `-t`: 让docker分配有一个伪终端(pseudo-tty)并绑定到容器的标准输入上;
- `-i`: 让容器的标准输入保持打开，通常和`-t`同时使用;
- `-d`: 启动后进入后台;
- `--rm`: 运行完后删除容器，不可以与`-d`同时使用;
- `-v`: 指定挂着一个本地的已有的目录到容器中作为数据卷;
- `-p`: 指定要映射的端口,可以用`docker port`来查看当前映射的端口配置,eg: `docker port redis 6379`;
- `--name`: 给容器指定个名字
- `--link`: 可以容容器之间安全的进行交互,如访问mysql,mongodb容器;
- `--dns 8.8.8.8`: 指定容器使用DNS服务器，默认和宿主一致;
- `-c MYSQL_USER="root"`: 设置环境变量
- `--net`: 指定容器网络模式，默认:`bridge`.
    1. `host`模式,使用`--net=host`指定
    2. `container`模式，使用`--net=container:Name_or_id`指定
    3. `none`模式, 使用`--net=none`指定
    4. `bridge`模式(默认), 使用`--net=bridge`指定

## 概念
### 镜像与容器
Docker两个重要的概念是镜像(`Image`)和容器(`Container`)。  
镜像有点像虚拟机的快照，但是更轻量级。  
可以从镜像中创建容器，这等同于基于快照创建虚拟机，我们在容器中运行应用。

**我们也可以这样理解:**  
- 镜像是个系统安装盘，容器就是用这个系统盘安装的可以运行的系统
- 镜像比作类的话，那么容器就是这个类实例化出来的对象。

### 数据卷
在我们使用Docker容器的时候，如果容器释放了，但是我们想把容器运行时的某些数据保存住，不受容器生命周期的影响，让数据可以持久化，这时候就需要用到数据卷了。  
这个数据卷: 表现为容器的空间，实际保存在容器之外的。有点类似于磁盘的挂载，让某个目录挂载到容器中的某个目录。  
Docker生成容器的时候可以用 `-v`来挂载一个本地目录到容器中。

### 术语
- `host`: 宿主机
- `image`: 镜像
- `container`: 容器
- `registry`: 仓库
- `daemon`: 守护进程
- `client`: 客户端

## Docker命令

### 常用命令

- `docker pull`: 获取image
- `docker build`: 创建image
- `docker images`: 列出image
- `docker run`: 运行container
- `docker ps`: 列出container
- `docker rm`: 删除container
- `docker rmi`: 删除image
- `docker cp`: 在host和container之间拷贝文件
- `docker commit`: 保存改动未新的image

### Docker Help

  命令 | 说明
 ------------ | ------------
  attach  |   Attach to a running container
 build  |    Build an image from a Dockerfile
 commit  |   Create a new image from a container's changes
 cp  |  Copy files/folders between a container and the local filesystem
 create  |   Create a new container
 deploy  |   Deploy a new stack or update an existing stack
 diff  |     Inspect changes on a container's filesystem
 events  |   Get real time events from the server
 exec  |     Run a command in a running container
 export  |   Export a container's filesystem as a tar archive
 history  |  Show the history of an image
 images  |   List images
 import  |   Import the contents from a tarball to create a filesystem image
 info  |     Display system-wide information
 inspect  |  Return low-level information on Docker objects
 kill  |     Kill one or more running containers
 load  |     Load an image from a tar archive or STDIN
 login  |    Log in to a Docker registry
 logout  |   Log out from a Docker registry
 logs  |     Fetch the logs of a container
 pause  |    Pause all processes within one or more containers
 port  |     List port mappings or a specific mapping for the container
 ps  |  List containers
 pull  |     Pull an image or a repository from a registry
 push  |     Push an image or a repository to a registry
 rename  |   Rename a container
 restart  |  Restart one or more containers
 rm  |  Remove one or more containers
 rmi  |      Remove one or more images
 run  |      Run a command in a new container
 save  |     Save one or more images to a tar archive (streamed to STDOUT by default)
 search  |   Search the Docker Hub for images
 start  |    Start one or more stopped containers
 stats  |    Display a live stream of container(s) resource usage statistics
 stop  |     Stop one or more running containers
 tag  |      Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
 top  |      Display the running processes of a container
 unpause  |  Unpause all processes within one or more containers
 update  |   Update configuration of one or more containers
 version  |  Show the Docker version information
 wait  |     Block until one or more containers stop, then print their exit codes
 

