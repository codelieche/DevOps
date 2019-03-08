## 更改apiserver的证书

> 使用kubeadmn部署的集群，默认的证书是1年。

发现问题：执行：`kubectl get nodes`出现错误：

```bash
root@master01:~# kubectl get nodes
Unable to connect to the server: x509: certificate has expired or is not yet valid
```

赶紧查看证书相关日期：

先进入/etc/kubernetes/pki目录

```bash
root@master01:/etc/kubernetes/pki# openssl x509 -in apiserver.crt -dates
notBefore=Mar  8 03:49:29 2018 GMT
notAfter=Mar  7 05:44:27 2029 GMT

root@master01:/etc/kubernetes/pki# openssl x509 -in apiserver.crt -noout -text |grep 'Not '
            Not Before: Mar  8 03:49:29 2018 GMT
            Not After : Mar  7 05:44:27 2019 GMT
```



### 替换apiserver的证书

#### 1. 备份老的证书和配置

```bash
root@master01:/etc/kubernetes/pki# cd /etc/kubernetes/
root@master01:/etc/kubernetes# ls
admin.conf  config.yaml  controller-manager.conf  kubelet.conf  manifests  pki  scheduler.conf
root@master01:/etc/kubernetes# mkdir ./pki_20190308
root@master01:/etc/kubernetes# mkdir ./conf_20190308
root@master01:/etc/kubernetes# mv pki/apiserver* pki/front-proxy-client.* ./pki_20190308/
root@master01:/etc/kubernetes# mv ./admin.conf kubelet.conf controller-manager.conf ./scheduler.conf ./conf_20190308/
root@master01:/etc/kubernetes# ls
conf_20190308  config.yaml  manifests  pki  pki_20190308
```



#### 2. 创建新的证书

这里集群的apiserver的ip是 192.168.1.123

```bash
root@master01:/etc/kubernetes# kubeadm alpha phase certs apiserver --apiserver-advertise-address 192.168.1.123
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [master01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.123]
root@master01:/etc/kubernetes# kubeadm alpha phase certs apiserver-kubelet-client
[certificates] Generated apiserver-kubelet-client certificate and key.
root@master01:/etc/kubernetes# kubeadm alpha phase certs front-proxy-client
[certificates] Generated front-proxy-client certificate and key.
```



#### 3. 创建新的配置文件

```bash
root@master01:/etc/kubernetes# kubeadm alpha phase kubeconfig all --apiserver-advertise-address 192.168.1.123
[kubeconfig] Wrote KubeConfig file to disk: "admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "scheduler.conf"
root@master01:/etc/kubernetes# ls
admin.conf  conf_20190308  config.yaml  controller-manager.conf  kubelet.conf  manifests  pki  pki_20190308  scheduler.conf
root@master01:/etc/kubernetes# ls pki
apiserver.crt  apiserver-kubelet-client.crt  ca.crt  front-proxy-ca.crt  front-proxy-client.crt  sa.key
apiserver.key  apiserver-kubelet-client.key  ca.key  front-proxy-ca.key  front-proxy-client.key  sa.pub
```

查看新的证书日期：

```bash
root@master01:/etc/kubernetes# openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text |grep ' Not '
            Not Before: Mar  8 03:49:29 2018 GMT
            Not After : Mar  7 11:39:35 2020 GMT
```

证书已经延期了。



#### 4. 替换config文件

```bash
mv $HOME/.kube/config $HOME/.kube/config.20190308
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
sudo chmod 777 $HOME/.kube/config
```

查看：

```bash
root@master01:/etc/kubernetes# ls -al ~/.kube/config
-rwxrwxrwx 1 root root 5451 Mar  8 04:43 /root/.kube/config
```



#### 5. 重启服务

需要重启的服务: `kube-apiserver`, `kube-controller-manager`, `kube-scheduler`容器。

```bash
docker ps | grep "kube-apiserver\|kube-control\|kube-schedu" | grep -v "pause" | awk '{print $1}' | xargs docker restart
```



#### 6. 把相关文件复制到其它master

```bash
root@master01:/etc/kubernetes# scp pki/* root@192.168.1.124:/etc/kubernetes/pki/
apiserver.crt
root@master01:/etc/kubernetes# scp admin.conf kubelet.conf controller-manager.conf scheduler.conf root@192.168.1.124:/etc/kubernetes/
```



#### 7. 最后重启master节点的docker：

```bash
docker ps | grep "kube-apiserver\|kube-control\|kube-schedu" | grep -v "pause" | awk '{print $1}' | xargs docker restart
```

