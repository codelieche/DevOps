## Python操作etcd

### 基本使用

#### 安装python-etcd

```
pip install python-etcd
```

#### 连接etcd

```python
import etcd
client = etcd.Client()
client = etcd.Client(host="127.0.0.1", port=4001)  #默认
client = etcd.Client(host="192.168.1.123", port=2379)
client = etcd.Client(
             host='127.0.0.1',
             port=2379,
             allow_reconnect=True,
             protocol='https',)
```


#### 设置key

```python
client.write("/study/001", "study 001 value")
client.write("/study/002", "study 002 value", ttl=10)
# 只创建不存在的key
client.write("/study/003", "value03", prevExist=False)
```

#### 获取key的值

```python
k1 = client.get("/study/001")
print(k1.key, k1.value)

value = client("/study/001").value
```
递归获取值：

```python
items = client.read("/study", recursive=True, sorted=True)
for item in items.children:
    print(item.key, item.value)
```

#### 删除key

```python
client.delete('/study/003')
# 删除目录
client.delete("/study", dir=True)
client.delete("/study", recursive=True)
```

### 参考文档
- [python-etcd Docs](http://python-etcd.readthedocs.io/)