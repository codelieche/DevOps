## 安装gitlab


### Detian中安装
#### 1. Install and configure the necessary dependencies

```
sudo apt-get install curl openssh-server ca-certificates postfix -y
```

postfix需要配置，可以先设置成不配置

#### 2.  Add the GitLab package server and install the package

```
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt-get install gitlab-ce
```

#### 3. Configure and start GitLab

```
sudo gitlab-ctl reconfigure
```

出现失败：`Chef Client failed. 15 resources updated....`  
修改配置：`sudo vim /etc/gitlab/gitlab.rb`, 修改external_url.


#### 4. 浏览器访问
输入设置的ip或者域名，默认账号密码：

```
Username: root  
Password: 5iveL!fe  
```

### 基本使用

#### gitlab-ctl常用命令
- `gitlab-ctl reconfigure`: 初始化配置，启动gitlab
- `gitlab-ctl status`: 查看gitlab状态，可以查看到启动的服务
- `gitlab-ctl restart`: 重启gitlab
- 查看gitlab版本：`cat /opt/gitlab/embedded/service/gitlab-rails/VERSION`

如果想修改些配置，可以去这里：`/var/opt/gitlab/gitlab-rails/etc/gitlab.yml`

### Docker中安装

- 拉取镜像：`docker pull gitlab/gitlab-ce`
- docker部署容器

```
docker run --detach \
    --hostname gitlab.example.com \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

## 参考文档
- [gitlab install](https://about.gitlab.com/installation/#debian)
- [GitLab Docker images](https://docs.gitlab.com/omnibus/docker/)