### 简单使用

#### 1. 安装
- pip安装：`sudo pip install ansible`
- ubuntu/Debain: `apt-get install ansible`
- centOS: `yum install ansible`

#### 2. 配置文件
- 配置文件位置：`/etc/ansible/ansible.cfg`
- 服务器清单: `/etc/ansible/hosts`

##### 认证方式
> Ansible 1.2.1以及之后的版本都默认启用公匙认证。

比如：主机A上安装了ansible，想在主机A上，操作B、C、D主机。那么先要把A主机上的公匙添加到主机B、C、D的`hnown_hosts`中。

#### 3. 第一条命令
先查看下hosts：

```bash
➜  ~ cat /etc/ansible/hosts
[web]
192.168.1.106
```
执行命令：

```bash
➜  ~ ansible web -m ping
192.168.1.106 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

> Ansible会像SSH那么试图以当前用户名来连接远程机器，如果要指定用户名，使用-u参数即可。  
如果想访问sudo模式，可以加`--sudo`来实现。

```bash
# 使用 user2
$ ansible all -m ping -u user2
# 使用user2, sudoing to root
$ ansible all -m ping -u user2 --sudo
# 使用 user2, sudoing to user3
$ ansible all -m ping -u user2 --sudo --sudo-user user3
```

#### 4. Inventory文件
> Ansible可同时操作属于一个组的多台主机，组合主机之间的关系通过`inventory`文件配置。  
默认的文件路径是：`/etc/ansible/hosts`.
除默认文件外，还可以同时使用多个inventory文件，也可以从动态源拉取信息。

##### 4-1. 主机和组

```
[web]
192.168.1.101
192.168.1.102
192.168.1.103
test.codelieche.com

[dbserver]
192.168.1.107
192.168.1.108
```

方括号`[]`中的是组名，用于对系统进行分类，便于对不同系统进行个别的管理。  
默认主机的SSH端口号是22，如果不是默认的端口号，可以明确的设置。

```
test.codelieche.com:5309
```

也可以给主机设置个别名，eg：

```
codelieche ansible_ssh_port=5555 ansible_ssh_host=192.168.1.105
```

在上面的例子中，通过`codelieche`别名，实际上会连接`192.168.1.105:5555`。


##### 4-2. Inventory参数说明
- `ansible_ssh_host`: 将要连接的远程主机名
- `ansible_ssh_port`: ssh端口好，如果不是默认的端口号, 通过此变量设置
- `ansible_ssh_user`: 默认的ssh用户名
- `ansible_ssh_pass`: ssh密码(推荐使用`--ask-pass`或SSH密匙，而不是把密码填这里)
- `ansible_sudo_pass`: sudo密码(推荐用 `--ask-sudo-pass`)
- `ansible_sudo_exe`: sudo命令路径(适用于1.8+的版本)
- `ansible_connection`: 与主机连接的类型。比如：`local`,`ssh`或者`paramiko`（1.2以前默认使用paramiko,之后版本默认使用`smart`）,`smart`方式会根据是否支持ControlPersist来判断`ssh`方式是否可行。
- `ansible_ssh_private_key_file`: ssh使用的私匙文件(适用于有多个密匙，而不像使用ssh代理的情况)
- `ansible_shell_type`: 目标系统的shell类型，默认情况下，命令的执行使用`sh`语法，可设置为`csh`或`fish`.
- `ansible_python_interpreter`: 目标主机的python路径，适用于情况：系统中有多个Python，或者命令路径不是`/usr/bin/python`.

**示例：**

```
some_host         ansible_ssh_port=55555     ansible_ssh_user=admin
aws_host          ansible_ssh_private_key_file=/home/admin/.ssh/aws.pem
freebsd_host      ansible_python_interpreter=/usr/local/bin/python
ruby_module_host  ansible_ruby_interpreter=/usr/bin/ruby.2.1.5
```

