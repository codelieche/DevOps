### Ansible Synchronize

> 使用rsync模块，系统必须安装rsync包，否则无法使用这个模块。

#### 1. 推送文件
> 我们把`/etc/ansible/hosts`传送到服务器的`/data/www`目录下面。

```json
 ~ ansible web -m synchronize -a 'src=/etc/ansible/hosts dest=/data/www/'
192.168.1.106 | FAILED! => {
    "changed": false,
    "cmd": "/usr/bin/rsync --delay-updates -F --compress --archive --rsh=/usr/bin/ssh -S none -o StrictHostKeyChecking=no --out-format=<<CHANGED>>%i %n%L /etc/ansible/hosts admin@192.168.1.106:/data/www/",
    "failed": true,
    "msg": "bash: rsync: command not found\nrsync: connection unexpectedly closed (0 bytes received so far) [sender]\nrsync error: remote command not found (code 127) at /BuildRoot/Library/Caches/com.apple.xbs/Sources/rsync/rsync-51/rsync/io.c(453) [sender=2.6.9]\n",
    "rc": 127
}
```

出现错误的原因是，服务器上没安装`rsync`,安装好`rsync`后，再试。

```json
ansible web -m synchronize -a 'src=/etc/ansible/hosts dest=/data/www/'
192.168.1.106 | SUCCESS => {
    "changed": true,
    "cmd": "/usr/bin/rsync --delay-updates -F --compress --archive --rsh=/usr/bin/ssh -S none -o StrictHostKeyChecking=no --out-format=<<CHANGED>>%i %n%L /etc/ansible/hosts admin@192.168.1.106:/data/www/",
    "msg": "<f+++++++ hosts\n",
    "rc": 0,
    "stdout_lines": [
        "<f+++++++ hosts"
    ]
}
```
查看上传的文件：

```
 ~ ansible web -a 'cat /data/www/hosts'
192.168.1.106 | SUCCESS | rc=0 >>
[web]
192.168.1.106 ansible_ssh_user=admin
```

#### 2. 拉取文件
> 我们想把服务器上的:`/data/www/codelieche.com/logs/`目录中的文件拷贝到本地的`/data/logs/ansible`下，与推送文件不同的是，需要设置`mode=pull`.

**2-1. 查看服务器文件**

```
ansible web -a 'ls /data/www/codelieche.com/logs'
192.168.1.106 | SUCCESS | rc=0 >>
access.log
error.log
gunicorn.access.log
gunicorn.error.log
supervisor.logs
```

**2-2. 拉取文件**

```json
➜  ~ tree /data/logs/ansible
/data/logs/ansible
└── ansible.log

➜ ~ ansible web -m synchronize -a 'mode=pull src=/data/www/codelieche.com/logs/ dest=/data/logs/ansible/'
192.168.1.106 | SUCCESS => {
    "changed": true,
    "cmd": "/usr/bin/rsync --delay-updates -F --compress --archive --rsh=/usr/bin/ssh -S none -o StrictHostKeyChecking=no --out-format=<<CHANGED>>%i %n%L admin@192.168.1.106:/data/www/codelieche.com/logs /data/logs/ansible/",
    "msg": "cd+++++++ logs/\n>f+++++++ logs/access.log\n>f+++++++ logs/error.log\n>f+++++++ logs/gunicorn.access.log\n>f+++++++ logs/gunicorn.error.log\n>f+++++++ logs/supervisor.logs\n",
    "rc": 0,
    "stdout_lines": [
        "cd+++++++ logs/",
        ">f+++++++ logs/access.log",
        ">f+++++++ logs/error.log",
        ">f+++++++ logs/gunicorn.access.log",
        ">f+++++++ logs/gunicorn.error.log",
        ">f+++++++ logs/supervisor.logs"
    ]
}

➜  ~ tree /data/logs/ansible
/data/logs/ansible
├── access.log
├── ansible.log
├── error.log
├── gunicorn.access.log
├── gunicorn.error.log
└── supervisor.logs
```

#### 3. Synchronize选项说明
通过`ansible-doc synchronize`可以查看帮助文档。

- `archive`: 是否采用归档模式同步，即以源文件相同属性同步到目标地址`(Choices: yes, no)[Default: yes]`
- `checksum`: 是否校验`(Choices: yes, no)[Default: no]`
- `compress`: 开启压缩，默认为开启`(Choices: yes, no)[Default: yes]`
- `copy_links`: 同步的时候是否复制连接 `(Choices: yes, no)[Default: no]`
- `delete`: 删除源中没有而目标存在的文件（即推送为主）【yes/no(默认)】
- `dest=`: 目标地址
- `dest_port`: 目标接受的端口，配置文件中的`ansible_ssh_port`优先级高于`dest_port`
- `dirs`: 以非递归的方式传输目录【yes/no(默认)】
- `existing_only`: 接收方只接收它有的文件【yes/no(默认)】
- `group`: Preserve group【yes/no(默认与archive同)】
- `links`: Copy symlinks as symlinks【yes/no(默认与archive同)】
- `mode`: 模式，rsync同步的方式【push(默认)/pull】,拉取文件要设置mode=pull
- `owner`: 设置所有者(仅super用户可操作)【yes/no 默认同archive】
- `recursive`: 是否递归【yes/no(默认与archive同)】
- `rsync_opts`: 使用rsync的参数
- `rsync_path`: 服务器的路径，指定rsync命令来在远程服务器上运行。zhege 参考rsync命令的`--rsync-path`参数，`--rsync-path=PATH`: 指定远程服务器上的rsync命令所在的路径信息
- `rsync_timeout`: 指定rsync操作的IP超时时间，和rsync命令的--timeout参数效果一样
- `set_remote_user`: put user@ for the remote paths. If you have a custom ssh config to define the remote user for a host that does not match the inventory user, you should set this parameter to "no".
- `src=`: 源，同步的数据源
- `times`: Preserve modification times (Choices: yes, no)[Default: the value of the archive option]
- `use_ssh_args`: Use the ssh_args specified in ansible.cfg (Choices: yes, no)[Default: no]
- `verify_host`: Verify destination host key. [Default: False]
