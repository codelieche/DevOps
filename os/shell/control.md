## shell流程控制

> 脚本程序包含了一系列的命令，一行一行的开始执行直到结束。  
但是大部分程序的结构不是一行一行往下执行的，中间需要加入一些逻辑判断，更具不同情况，执行不同的动作。

shell中控制相关的关键字有：`if`,`exit`,`for`,`while`,`until`,`case`,`break`,`continue`.

### if语句
> if语句主要有三种形式

#### 第一种：if ... fi

```shell

# 条件为真执行：条件为假不做任何事情
if condition ; then
    commands
if
```

#### 第二种：if ... else ... fi

```shell

# 条件为真执行cmd01；条件为假执行cmd02
if condition ; then
    cmd01
else
    cmd02
fi
```

#### 第三种：if ... elif ... else ... fi

```shell

# 条件1位真时执行cmd01；条件2为真的时候执行cmd02；其它情况执行cmd03
if condition01 ; then
    cmd01
elif condition02 ; then
    cmd02
else
    cmd03
fi
```

示例：

```shell

#! /bin/sh
if test -z "$1" ; then
    echo "请选择您喜欢的操作系统：windows/linux/macOS"
	exit 1;
fi

echo "您输入的是：$1"

if test $1 = windows ; then
    echo "你喜欢windows"
elif [[ $1 = linux ]] ; then
    echo "linux is very good!"
elif [[ $1 = macos ]] ; then
    echo "MacOS很好用"
else
    echo "您输入的不是windows/linux/macos，而是$1"
fi
```

### case语句
> case表达式可以用来匹配一个给定的字符串，而不是数字哦(别和C语言中有switch ... case混淆)。

case语句格式：

```
case value in
   匹配模式) 执行语句 ;;
esac
```

**注意**: 执行语句后加两个分号`;;`,最后一个匹配模式我们一般用`*`（匹配任何东西），而且推荐最后都加入这个通配符。

示例：

```shell

#! /bin/sh
# 输入windows/linux/macos

if test -z "$1" ; then
    echo "请传递一个参数!"
	exit 1;
fi

echo "您输入的\$1是: $1"

case $1 in
    windows) echo "微软操作系统";;
	linux) echo "Linux is good！";;
	macos) echo "MacOS很好用！";;
	*) echo "你输入的是其它哦: $1";;
esac
```

### 循环控制
> 循环是只要条件成立，那么就会返回的执行，直到条件不满足，跳出循环。  
shell的循环有两种：一是while(until)；另外一个是for循环。

#### while循环

> 先来个示例：

```shell

#! /bin/sh
echo $1
if [[ -n $1 && $1 -ge 1 ]] ; then
    num=$1
else
    echo "请输入大于1的数值"
	exit 1
fi

while [ $num -ge 1 ] ; do
    echo "现在num是：${num}"
	# num=`expr $num - 1`
	# let "num=$num - 1"
	(( num-=1 ))
    # num=$[$num - 1]
done
```
在循环体中，让num减一，其中用到了4中整数运算的方式。  
执行代码：

```
➜  shell ./whiledemo.sh 5
5
现在num是：5
现在num是：4
现在num是：3
现在num是：2
现在num是：1
```

#### for循环
我们先用`seq`生成个序列：`seq 5`(与`seq 1 5`等价)。

```shell

for i in $( seq 1 5 ); do
    echo "i is: $i"
done

# for i in $( ls $PWD )
for i in `ls $PWD`
do
    echo $i
done
```
**说明：**

```
反引号``和 $()的用法是一样的.  
在执行一条命令时，会先将其中的 ``或$()中的语句当作命令执行一次，然后再将结果加入到原命令中重新执行.  
eg: echo `pwd`; echo pwd; echo $(pwd)
```

#### until循环
> while循环的条件测试是测真值[true就继续执行]，until循环则是测假值[直到true就不循环了]。

until循环的语法：

```
until 条件测试
do
 执行命令
done
```

**示例：**

```shell

#! /bin/sh
num=1

until [ $num -gt 5 ]
# until test $num -gt 5
do
    echo "num is ${num}"
	num=$[$num + 1]
done
echo "程序运行完毕"
```