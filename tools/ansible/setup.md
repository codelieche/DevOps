## Ansible获取机器信息

> 通过`ansible all -m setup`可以获取到服务器的信息。



### 重要的字段

```
ansible_processor CPU
ansible_processor_cores CPU核心数
ansible_processor_count 物理CPU个数
ansible_processor_threads_per_core CPU线程数

ansible_os_family 操作系统家族
ansible_distribution 操作系统发行版
ansible_distribution_version  操作系统版本


ansible_kernel 内核
ansible_machine 机器位数

ansible_hostname 主机名
ansible_fqdn FQDN
ansible_all_ipv4_addresses 机器IPv4
ansible_dns DNS
ansible_default_ipv4 默认IP
ansible_date_time 时间时区

ansible_interfaces 网络接口


ansible_devices 物理磁盘
ansible_mounts 挂载分区
ansible_memory_mb 内存
ansible_memtotal_mb 总内存

ansible_system_vendor 品牌
ansible_product_name 型号
ansible_product_serial 产品SN
ansible_userspace_bits 机器位数
ansible_userspace_architecture 架构

ansible_machine_id 机器ID
ansible_bios_date 生产时间
```

维保到期时间（默认）= 生产时间 + 3 年

