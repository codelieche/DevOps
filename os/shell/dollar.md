## shell编程之--$

> 学过php的都知道$符号是变量符号，把$符号加上字符串，那么这个字符串就是一个变量名或者对象名。  
而在shell中$符号有很多的特殊用法。

### shell中$的特殊用法
- `$$`: shell本身的PID(Process ID)进程ID
- `$!`: shell最后运行的后台进程PID
- `$?`: 最后运行的命令的结束代码(exit 0/1/2),0是正常，其它是错误
- `$-`: 使用set命令设定的Flag一览
- 参数相关
    - `$0`: shell脚本本身的文件名
    - `$1~$n`: 添加到shell的各参数，$1是第1个参数,$2是第2个参数...
    - `$#`: 添加到shell的参数个数
    - `$*`: 所有参数列表：eg：`"$*"`: 以`"$1 $2 ...$n"`的形式输出所有参数
    - `$@`: 所有参数列表：eg: `"$@"`: 以`"$1" "$2" ... "$n"`的形式输出所有参数

**示例:**

```shell
#! /bin/sh
echo "当前脚本是：$0"
echo "脚本传入参数的个数是：$#"
echo "参数分别是：$*"
echo "$@"

echo "第1个参数是：$1"
echo "当前进程是：$$"

echo '展示$*和$@的差异'
echo '==== $* ====='

for i in "$*"
do
    echo $i
done

echo "==== \$@ ====="

for i in "$@"
do
    echo $i
done
echo "测试\$*和\$@差异结束"
```

**执行程序：**

```
➜  shell ./demo01.sh abc ddd ok good shell
当前脚本是：./demo01.sh
脚本传入参数的个数是：5
参数分别是：abc ddd ok good shell
abc ddd ok good shell
第1个参数是：abc
当前进程是：88315
展示$*和$@的差异
==== $* =====
abc ddd ok good shell
==== $@ =====
abc
ddd
ok
good
shell
测试$*和$@差异结束
```