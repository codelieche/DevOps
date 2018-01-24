## Dockerfile基本使用

### Dockerfile语法
- `FROM`: base image
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

```
FROM python:3.6.3-slim  78dfsafjslfl
MAINTAINER codelieche   fasdbasldjl13
CMD echo "Hello Docker"   ldl45364777
```

