## ansible配置



#### 配置文件位置

- `/etc/ansible/ansible.cfg`
- 用户家目录的：`~/.ansible.cfg`
- 执行ansible所在目录的文件：`./ansible.cfg`

当执行`ansible`命令的时候先在当前目录找`ansible.cfg`，没找到再去home目录寻找，最后才找`/etc/ansible/ansible.cfg`文件。

配置文件示例：https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg

```bash
ansible all -m ping
```

#### 常用配置

> 大部分的配置都集中在defaults配置选项中。

- inventory：主机列表文件

  > 该参数表示自愿清单inventory文件的位置，资源清单就是一些ansible需要连接管理的主机列表
  >
  > 默认是：` /etc/ansible/hosts`

- library：模块目录

  > Ansible的操作动作，无论是本地或远程，都使用一小段代码来执行，这小段代码称为模块。
  >
  > 这个library参数就是指向存放Ansible模块的目录 library = /usr/share/ansible

- forks: 设置并发进程数

- remote_user：执行远程命令的用户，默认是执行ansible命令的当前用户名

  > 如果设置了remote_user，未设置ansible_ssh_user的host就会用这个user去执行。

- default_sudo_user: 设置默认执行sudo命令的用户，可以playbook中重新设置

  > **注意**：老的版本是`sudo_user`

- remote_port: ssh端口，默认是22

- host_key_checking: 设置是否检查SSH主机的秘钥。True/False

- timeout: 设置SSH连接的超时时间，单位秒

- log_path：日志文件路径，默认不记录日志的

- private_key_file: SSH密匙路径，默认：`~/.ssh/id_rsa`



```
[defaults]
; inventory = /etc/ansible/hosts
inventory = ~/ansible/hosts

forks = 5
remote_user = jumperserver
default_sudo_user = root
```

