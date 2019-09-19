## Ubuntu升级系统内核

### 查看系统信息

- 查看发行版本

  ```bash
  root@ubuntu238:~# cat /etc/issue
  Ubuntu 16.04.4 LTS \n \l
  
  root@ubuntu238:~# lsb_release -a
  No LSB modules are available.
  Distributor ID:	Ubuntu
  Description:	Ubuntu 16.04.4 LTS
  Release:	16.04
  Codename:	xenial
  ```

- 查看内核版本：

  ```bash
  root@ubuntu238:~# uname -sr
  Linux 4.4.0-116-generic
  root@ubuntu238:~# uname -a
  Linux ubuntu238 4.4.0-116-generic #140-Ubuntu SMP Mon Feb 12 21:23:04 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
  ```

  

### 升级内核

- 下载内核：

  http://kernel.ubuntu.com/~kernel-ppa/mainline/

- 下载内核文件：

  这里选择升级为`40.20.17`

  https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.17/

  ```bash
  mkdir kerent;cd kernel
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.17/linux-headers-4.20.17-042017_4.20.17-042017.201903190933_all.deb
  
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.17/linux-headers-4.20.17-042017-generic_4.20.17-042017.201903190933_amd64.deb
  
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.17/linux-image-unsigned-4.20.17-042017-generic_4.20.17-042017.201903190933_amd64.deb
  
  
  # 可以下载下另外几个文件
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.17/linux-headers-4.20.17-042017-lowlatency_4.20.17-042017.201903190933_amd64.deb
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.17/linux-image-unsigned-4.20.17-042017-lowlatency_4.20.17-042017.201903190933_amd64.deb
  wget  https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.17/linux-modules-4.20.17-042017-generic_4.20.17-042017.201903190933_amd64.deb
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.17/linux-modules-4.20.17-042017-lowlatency_4.20.17-042017.201903190933_amd64.deb
  ```

- 查看文件：

  ```bash
  root@ubuntu238:~/kernel# ls
  linux-headers-4.20.17-042017_4.20.17-042017.201903190933_all.deb
  linux-headers-4.20.17-042017-generic_4.20.17-042017.201903190933_amd64.deb
  linux-image-unsigned-4.20.17-042017-generic_4.20.17-042017.201903190933_amd64.deb
  ```

  或者：

  ```bash
  linux-headers-4.20.17-042017_4.20.17-042017.201903190933_all.deb
  linux-headers-4.20.17-042017-generic_4.20.17-042017.201903190933_amd64.deb
  linux-headers-4.20.17-042017-lowlatency_4.20.17-042017.201903190933_amd64.deb
  linux-image-unsigned-4.20.17-042017-generic_4.20.17-042017.201903190933_amd64.deb
  linux-image-unsigned-4.20.17-042017-lowlatency_4.20.17-042017.201903190933_amd64.deb
  linux-modules-4.20.17-042017-generic_4.20.17-042017.201903190933_amd64.deb
  linux-modules-4.20.17-042017-lowlatency_4.20.17-042017.201903190933_amd64.deb
  ```

  

- 安装内核文件：

  ```bash
  dpkg -i *.deb
  ```

- 重启机器：`reboot`

- 查看系统内核：

  ```bash
  root@ubuntu238:~# uname -rs
  Linux 4.20.17-042017-lowlatency
  
  root@ubuntu239:~# uname -rs
  Linux 4.20.17-042017-lowlatency
  
  root@ubuntu240:~# uname -rs
  Linux 4.20.17-042017-lowlatency
  ```

  **到这里内核就升级成功了！**



### 遇到的问题

1. Package libssl1.1 is not installed.

   >  linux-headers-4.20.17-042017-generic depends on libssl1.1 (>= 1.1.0); however:
   >   Package libssl1.1 is not installed.

   **解决方式：**

   ```bash
   root@ubuntu238:~/kernel# apt-get install libssl-dev
   Reading package lists... Done
   Building dependency tree
   Reading state information... Done
   You might want to run 'apt-get -f install' to correct these:
   
   root@ubuntu238:~/kernel# apt-get -f install
   ```

   