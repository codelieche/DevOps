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

**2-1. 下列出文件**

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



