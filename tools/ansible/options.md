## ansible命令参数

```
ansible <host-pattern> [options]
```

Ansible命令参数

- `-m NAME, --module-name=NAME`:指定执行使用的模块

  > ansible  all -m ping
  >
  > ansible all -m shell -a"date"

- `-v`,`--verbose`:输出更详细的执行过程信息，`-vvv`可以得到所有执行过程信息

  ```
  (env_ansible) ➜  ansible ansible all -v -m shell -a "ls /data"
  Using ~/Documents/workspace/devops/ansible/ansible.cfg as config file
  192.168.1.123 | CHANGED | rc=0 >>
  backup
  logs
  mysql
  www
  ```

- `-i PATH`, `--inventory=PATH`: 指定inventory的路径，默认`/etc/ansible.hosts`

- `-f NUM, --forks=NUM`:并发线程数，默认是5个线程

- `--private-key=PRIVATE_KEY_FILE_PATH`: 指定秘钥文件路径

- `-M NAME, --module-name=DIRECTORY`: 指定模块存放路径

  > 默认：`/usr/share/ansible`, 在配置文件中是设置library.

- `-a "ARGUMENTS",  --args="ARGUMENTS"`: 模块参数：比如：`ansible all -m shell -a"date"`

- `-k,  --ask-pass SSH`: 认证密码

- `-K, --ask-sudo-pass sudo`: 用户的密码(--sudo时使用)

- `-o, --one-line`: 标准输出至一行

- `-s, --sudo`： 相当于LinU型系统下的sudo命令

- `-t DIRECTORY, --tree=DIRECTORY`: 输出信息至DIRECOTORY目录下，结果文件以原创主机名命名

  > (env_ansible) ➜  ansible ansible all -t ./test1 -m shell -a"date"
  > 192.168.1.123 | CHANGED | rc=0 >>
  > Tue Oct  9 16:37:32 CST 2018
  >
  > 192.168.1.124 | CHANGED | rc=0 >>
  > Tue Oct  9 08:39:54 UTC 2018
  >
  > (env_ansible) ➜  ansible tree test1
  > test1
  > ├── 192.168.1.123
  > └── 192.168.1.124

- `-T SECONDS, --timeout=SECONDS`: 指定连接远程主机的最大超时时间(秒)

- `-B NUM, --background=NUM`: 后台执行命令，超过NUM秒后kill正在执行的任务

- `-P NUM, --poll=NUM`: 定期返回后台任务进度

- `-u USERNAME,  --user=USERNAME`: 指定远程主机已USERNAME运行命令

- `-U SUDO_USERNAME, --sudo-user=SUDO_USERNAME`: 使用sudo，相当于Linux下的sudo命令

- `-c CONNECTION, --connection=CONNECTION`: 指定连接方式，可用选项paramiko(ssh), ssh, local。Local方式常用于crontable和kickstarts

- `-I SUBSET, --limit=SUBSET`: 指定运行主机

- `-I ~REGEX, --limit=~REGEX`: 指定运行主机(正则)

- `--list-hosts`: 列出符合条件的主机列表，不执行任何其它命令

  ```
  (env_ansible) ➜  ansible ansible all --list-hosts
    hosts (2):
      192.168.1.123
      192.168.1.124
  ```
