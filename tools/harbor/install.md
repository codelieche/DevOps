## Harbor的安装



### CentOS通过docker-compose安装

> Centos7

#### 安装docker

```bash
sudo su -
yum install -y wget vim
cd /etc/yum.repos.d/
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum repolist
yum install docker-ce
```

- 把vagrant普通用户加入docker分组

  ```bash
  groupadd docker
  gpasswd -a vagrant docker
  systemctl restart docker
  ```

- 检查docker：`docker version`

- 设置开机启动：`systemctl enable docker`

#### 安装docker-compose

- 安装拓展epel: `yum -y install epel-release`
- 安装pip: `yum install python-pip`
- 安装docker-compose: `pip install docker-compose`
- 查看：`docker-compose -v`



#### 安装harbor

- 下载harbor-offline-installer-v1.6.0：
- 解压：`tar -zxvf ./harbor-offline-installer-v1.6.0.tgz`

##### 配置harbor.cfg

##### 安装 ./install

