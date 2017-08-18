## Linux三剑客之--awk

> 在linux中，一切皆文件，而对linux文件的操作，主要是用三个命令：`awk`、`sed`、`grep`（号称linux中的三剑客）。

## awk的基本用法
### 语法格式
  - 格式1：`前置命令 | awk [选项] '[条件]{处理指令}'`
  - 格式2：`awk [选项] '[条件]{处理指令}` 文件...`

> 处理指令如果有多条语句，可以用分号分割，其中`print`是最常用的指令。

### 常用命令选项
- `-F`: 指定分隔符，可省略(默认是空格或者Tab位)
- `-f`: 调用awk脚本进行处理(把处理指令写到文件中，传给-f参数)

### awk内置变量
- `FS`: 保存或设置字段分隔符,eg: `FS=":"`
- `$n`: n是数字，指定分隔的第n个字段，eg：`$1、$5`分别表示第1、5列
- `$0`: 当前读入的整行文本内容
- `NF`: number fields 记录当前处理行的字段个数(列数),用`print $NF`可以打印最后一列的字符串
- `NR`: number rows 记录当前已读入行的数量(行数)
- `FNR`: 保存当前处理行在原文本内的序号(行号)[如果没过滤选项，NR和FNR会相等的]
- `FILENAME`: 当前处理的文件名
- `ENVIRON`: 调用shell环境变量，格式：`ENVIRON["变量名"]`

### awk处理的时机
> 三块：处理每行前、处理每行、每行文本处理后。可以单独使用，也可以同时一起使用。

- `BEGIN{}`: 行处理前(初始化操作)，读入第一行文本之前执行
- `{cmd}`: 逐行处理，逐行读入文本执行相应的处理命令，是最常见编辑指令块
- `END{}`: 行处理完后执行，处理完最后一行文本执行，一般用来输出处理结果

**示例：**统计`/etc/passwd`中包含root的行数：

```
~ cat /etc/passwd | awk 'BEGIN{i = 0}/root/{i++}END{print"包含root的行数为" i}'
包含root的行数为0
```

## awk条件的使用
> 格式：`awk [选项] '[条件]{编辑指令}' 文件...`

可以使用的条件形式有：
- 正则表达式
- 数值/字符串比较
- 逻辑比较
- 运算符

### 使用正则表达式条件
- `/RegExp/`
- `~匹配`， `!~不匹配`：其中`~`是匹配，而`!~`是不匹配后面的规则(~的取反)

```
~ cat /etc/passwd | awk 'BEGIN{i = 0}$0!~/root/{i++}END{print "不包含root的行数为" i}'
不包含root的行数为93
~ cat /etc/passwd | awk 'BEGIN{i = 0}$0~/root/{i++}END{print "包含root的行数为" i}'
包含root的行数为3
```

> 其中$0是指整行文本，可以使用$1-n，来处理n列的值。可以用`$NF`来判断最后一列。

```
➜  shell awk -F: '$0~/bash/{print $NF}' /etc/passwd
/bin/bash
```

### 使用数值比较
> 数值比较：`==`(等于)、`!=`(不等于)、`>`(大于)、`>=`(大于等于)、`<=`(小于等于)、`(<=)`(小于等于)。

- `nl /etc/passwd | awk -F: 'NR%2==1{print $0}'`: 打印奇数行
- `nl /etc/passwd | awk -F: 'NR%2==0{print $0}'`：打印偶数行
- `nl /etc/passwd | awk -F: 'NR<=5{print $0}'`: 打印前5行

**多个条件组合：**
- `&&`: 逻辑与，多个条件都成立才为真
- `||`: 逻辑或，多个条件一个成立就满足

**实例：**
- `nl /etc/passwd | awk -F: 'NR<=5 || NR > 90 {print $0}'`: 打印前5行和90行后面的
- `nl /etc/passwd | awk -F: 'NR>=5 && NR <= 10 {print $0}'`: 打印第5到10行

### 变量的运算
> 运算符：`+`、`-`、`*`、`/`、`%`、`++`、`--`、`+=`、`-=`、`*=`、`/=`。

## awk流程控制

### if分支结构
**注意**：awk其实是有自己的一套语法的，可shell中的if语法是有差异的。  
awk中正则还是if语句与javaScript很类似。

- if单分支：`if(condition){commands}`
- 双分支：`if(codition){指令01}else{指令02}`
- 多分支：`if(条件){指令1}else if(条件2}{指令2}else{指令3}`

```
~ awk -F: 'BEGIN{x=0;y=0}{if($0~/root/){x++}else{y++}}END{print "包含root的行有："x,"不包含root的行有：" ,y}' /etc/passwd
包含root的行有：3 不包含root的行有： 93
```

### while循环结构
- `while`: while(条件){指令}
- `do while`: do{指令}while(条件)
- 它们之间的差异是，do while至少会执行一次

**示例：**
- `awk '{while(NR <= 5){print $0;break}}' /etc/passwd`: 如果没break，哈哈这个语句会一直输出第1行的内容，持续循环下去

### for循环结构
- 语法：`for(初值;条件;步长){处理指令}`,跟javaScript的for相同

```
➜  shell awk 'BEGIN{for(i=0;i<10;i+=2){print i}}'
0
2
4
6
8
```

### 主要控制语句
- `break`: 结束当前的循环体
- `continue`: 终止本次循环，转入下一次循环
- `next`: 跳过当前行，读入下一行文本开始处理
- `exit`: 结束文本读入，跳入END{}执行，如果没有END{}则直接退出awk处理操作

```
nl /etc/passwd | awk 'BEGIN{i=0}NR<=90{next}{print $0;i++}END{print i}'
```

当`NR<90`的时候跳过当前行。
