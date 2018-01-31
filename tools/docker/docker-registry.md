## Docker Registry

> `docker-registry`是官方提供的工具，可以用于构建私有的镜像仓库。

### 参考文档
- [hub.docker registry](https://hub.docker.com/_/registry/)
- [docker registory docs](https://docs.docker.com/registry/)

### 安装使用docker-registry

**1. 创建registry容器**

```bash
dokcer pull registry
docker run -d -p 5000:5000 -v ~/Documents/DockerData/registry:/var/lib/registry registry
```

默认情况下，仓库会被创建在容器的`/var/lib/registry`目录下。  
通过`-v`参数来将镜像文件存放在本地的指定路径。

**2. 推送自己创建的镜像到私有仓库**

使用`docker tag`来标记一个镜像，然后推送到它的仓库

```
docker tag python36:webv1 127.0.0.1:5000/python36:webv1
```

查看所有的镜像

```bash
➜  docker images
REPOSITORY                            TAG                 IMAGE ID            CREATED             SIZE
127.0.0.1:5000/python36               webv1               c659686eea04        16 hours ago        371MB
python36                              webv1               c659686eea04        16 hours ago        371MB
redis                                 latest              861cc310cd91        6 days ago          107MB
busybox                               latest              5b0d59026729        6 days ago          1.15MB
registry                              2.6.2               d1fd7d86a825        3 weeks ago         33.3MB
registry                              latest              d1fd7d86a825        3 weeks ago         33.3MB
python                                3.6.3-slim          d3a5cf753410        7 weeks ago         156MB
```

推送到私有仓库：

```bash
➜  ~ docker push 127.0.0.1:5000/python36:webv1
The push refers to repository [127.0.0.1:5000/python36]
1bd538e505e4: Pushed
7d2912f80be2: Pushed
e61305eddd22: Pushed
a123d21e55f2: Pushed
c8a00682f83b: Pushed
f6fc4b4fae03: Pushed
9fccad5277f0: Pushed
cfce7a8ae632: Pushed
webv1: digest: sha256:a31c66a0d7f2e719341a96b5dsfasfsdfsafsagg size: 1997
```

使用curl查看仓库中的镜像：

```bash
➜  ~ curl 127.0.0.1:5000/v2/_catalog
{"repositories":["python36"]}
```


