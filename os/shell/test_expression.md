## shell编程之--test表达式

> 一个Unix应用程序在完成执行后，都会告诉操作系统是否执行成功。  
它是通过exit状态来，传递成功与否的。exit的状态数值范围是0-255，0表示成功，其它数值都表示失败。  

exit状态有2个重要的功能：  
1. 检测和处理错误
2. 可以执行`true/false`测试

> 一个好的脚本，应该在脚本完成的时候设置exit状态，使用`exit 0/1/2`命令是脚本呆着状态值退出。  
我们可以通过`echo $?`查看上次脚本执行的状态。

### test
> `true/false`的判断经常通过`test`和`if`一起配合实现的，通过`man test`可以查看更多test相关的信息。

test语法：
1. test expression
2. `[ expression ]` 注意：`[`, `]`与表达式之间**必须**有空格

### 常用test表达式

| 表达式  | 说明  |
| :------------: | :------------ |
|  -d file | 如果file目录存在返回true  |
|  -e file | 如果file文件存在返回true  |
|  -f file | 如果file文件存在并且是普通文件返回true  |
|  -L file | 如果file是连接文件返回true  |
|  -r file | 如果当前用户对file文件可读，返回true  |
|  -w file | 当前用户对file可写，返回true  |
| -x file  |  当前用户对file有执行权限，返回true |
|  f1 -nt f2 |  f1比f2文件新(根据修改时间),返回true |
|  f1 -ot f2 | f1比f2文件旧，返回true  |
| -z string | 如果string为空，则返回true |
| -n string | 如果string不为空，则返回true |
| str1 = str2 | 如果str1等于str2，则返回true |
| str1 != str2 | 判断str1是否与str2不相等，不相等返回真 |
| value1 -eq value2 | 判断(整数)值1月值2是否相等(相等返回true) |
| v1 -ge v2 | 如果v1大于等于v2，返回真 |
| v1 -gt v2 | 如果v1大于v2，返回真 |
| v1 -le/lt v2 | 判断v1 大于等于/大于 v2 |
| integer1 -ne interger2 | 如果integer1不等于integer2返回真 |
| if test expression | 如果expression为真返回真 |
| if test !expression | 如果expression为假，则返回真 |
| expr1 -a expr2 | 如果expr1和expr2都为真则返回真 |
| expr1 -o expr2 | 如果expr1或expr2位真，则返回真 |

> 在我们实际使用中，常使用双中括号`[[ ]]`，这个是为了防止内部的`[ ]`表达式没正确执行，比如内部express中的变量没有赋值，那么内层的`[ ]`执行失败，相当于这个表达式为false。

**注意：**`-eq`、`-gt`、`-le`、`-ne`这些是用来比较整数值的，如果用来对比字符串，那么会抛出`integer expression expected`错误。而` = `和` != `是可以判断整数或者字符串。

### 组合多个条件
> 组合多个条件，主要就是用`and`和`or`。用法：  
1. test 测试条件1 -a/-o 测试条件2
2. [[ 测试条件1 &&/|| 测试条件2  ]]

注意：`-a`和`-0`是用在`test`中，在`[ ]`中是会报错的；而`&&/||`是用在`[ ]`之中，不可用混了。

**示例：**检查a、b是否位于10-20之间

```shell

#! /bin/sh
a=$1
b=$2
echo "a:${a}  b:${b}"
if [[ $a -gt 10 && $a -lt 20 ]] ; then
   echo "a大于10，小于20"
else
   echo "a不介于10到20之间"
fi

if test $b -gt 10 -a $b -lt 20 ; then
   echo "b大于10，小于20"
else
   echo "b不介于10到20之间"
fi
exit 0;
```
执行结果:

```
➜  shell ./testab.sh 14 26
a:14  b:26
a大于10，小于20
b不介于10到20之间
➜  shell ./testab.sh 14 12
a:14  b:12
a大于10，小于20
b大于10，小于20
```