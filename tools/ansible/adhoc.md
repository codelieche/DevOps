### Introduction To Ad-Hoc Commands

#### 1. Ad-Hoc是什么
> ad-hoc这其实是一个概念性的名字，是相对于写Ansible playbook来说的，
类似于在命令行敲shell命令和写shell scripts两者之间的关系。

如果我们敲入一些命令去比较快的完成一些事情，而不需要将这些执行的命令特点保存下来，这样的命令就叫做ad-hoc命令。

Ansible提供两种方式去完成任务，一是ad-hoc命令，一是些Ansible playbook.  
前者可以解决一些简单的任务，后者解决较复杂的任务。

> 至于说做配置管理或者部署这种事情，还是要借助playbook来完成。  
命令：`/usr/bin/ansible-playbook`。

```
➜  ~ ansible all -m shell -a 'echo $PATH'
➜  ~ ansible web -a 'cat /etc/hosts'
➜  ~ ansible web -a 'whoami'
 ```

#### 2. File Transfer
> Ansible能够以并行的方式同时SCP大量的文件到多台机器，命令如下：

```
$ ansible atlanta -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

**注意：**ansible的`synchronize`利用的`rsync`，而`file`利用的是`scp`。

若你使playbooks, 则可以利用`template`模块来做到更进一步的事情.(请参见 module 和 playbook 的文档)

使用 `file` 模块可以做到修改文件的属主和权限,(在这里可替换为 copy 模块,是等效的):

```
$ ansible webservers -m file -a "dest=/srv/foo/a.txt mode=600"
$ ansible webservers -m file -a "dest=/srv/foo/b.txt mode=600 owner=admin group=admin"
```

使用file模块也可以创建目录,与执行`mkdir -p`效果类似:

```
$ ansible webservers -m file -a "dest=/path/to/c mode=755 owner=admin group=admin state=directory"
```

删除目录(递归的删除)和删除文件:

```
$ ansible webservers -m file -a "dest=/path/to/c state=absent"
```

可以通过`ansible-doc file`来查看看选项说明。

#### 3. Managing Packages
> Ansible提供对`yum`和`apt`的支持。这里是关于`yum`的示例：

确认一个软件包已经安装，但不去升级它：

```
$ ansible webservers -m yum -a "name=acme state=present"
```

**state的值:**
> (Choices: present, installed, latest, absent, removed)[Default: present]

确认一个软件包的安装版本：

```
$ ansible webservers -m yum -a "name=acme-1.5 state=present"
```

确认一个软件包还没有安装：

```
$ ansible webservers -m yum -a "name=acme state=absent"
```

#### 4. Users and Groups
> 使用user模块可以方便的创建账号、删除账号，或者管理现有的账号。

```
$ ansible all -m user -a "name=foo password=<crypted password here>"
$ ansible all -m user -a "name=foo state=absent"
```

#### 5. Managing Services
确认某个服务在所有的webservices上已经启动：

```
ansible web -m service -a "name=nginx state=started"
```

或是在所有web上重启某个服务：

```
ansible web -m service -a "name=mysql state=restarted"
```

确认某个服务已经停止：

```
ansible web -m service -a "name=nginx state=stoped"
```

#### 6. Time Limited Backgroud Operations
> 需要长时间运行的命令可以放在后台去，在命令开始运行后我们也可以检查运行的状态，如果运行命令后，不想获取返回的信息，可以执行如下命令：

```
$ ansible all -B 3600 -P 0 -a "/usr/bin/long_running_operation --do-stuff"
```

如果你确定要在命令运行后检查运行的状态，可以使用`async_status`模块，前面执行后台命令后会返回一个job id，讲这个id传给async_status模块：

```
$ ansible web1.example.com -m async_status -a "jid=88987776655.2456"
```

获取状态命令如下：

```
$ ansible all -B 1800 -P 60 -a "/usr/bin/long_running_operation --do-stuff"
```
其中`-B 1800`表示最多运行30分钟(30*60秒)，`-p 60`表示60秒获取一次状态信息。