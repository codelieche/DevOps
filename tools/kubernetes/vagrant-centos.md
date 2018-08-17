## 使用Vagrant安装kubernetes

### 参考文档

- [https://www.vagrantup.com/](https://www.vagrantup.com/)
- [Aliyun Mirrors: opsx](https://opsx.alibaba.com/mirror)
- [virtual box](https://www.virtualbox.org/)



### 准备三台Centos

> 先安装好vagrant和virtualbox.



- 初始化目录：`mkdir k8s-centos`
- `vagrant init centos/7`
- 修改vagrant文件：`vim Vagrant`

Vagrant文件内容：

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

boxes = [
    {
		:name => "master",
		:eth1 => "192.168.6.91",
		:mem => "1024",
		:cpu => "1"
	},
    {
		:name => "node01",
		:eth1 => "192.168.6.92",
		:mem => "2048",
		:cpu => "1"
	},
    {
		:name => "node02",
		:eth1 => "192.168.6.93",
		:mem => "2048",
		:cpu => "1"
	}
]

Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"

  boxes.each do |opts|
      config.vm.define opts[:name] do |config|
        config.vm.hostname = opts[:name]
        config.vm.provider "vmware_fusion" do |v|
          v.vmx["memsize"] = opts[:mem]
          v.vmx["numvcpus"] = opts[:cpu]
        end

        config.vm.provider "virtualbox" do |v|
          v.customize ["modifyvm", :id, "--memory", opts[:mem]]
          v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
        end

        config.vm.network :private_network, ip: opts[:eth1]
      end
  end

end
```



### 启动机器

- Vagrant up
- 进入虚拟机：vagran ssh master/node01/node02

这样就准备好三台centos的虚拟机了。且masterIP为：`192.168.6.91`

