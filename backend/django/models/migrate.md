## Django 数据库迁移

### Django与数据库的关系

> 在默认情况下，Django的数据库是以Model的方式来操作的，也就是在程序中不直接操作数据库和数据表，  
> 而是以class类先创建好Model，然后通过对Model的操作达到操作数据库的目的。  
> 这样的好处是：把程序和数据库之间的关系以中介层作为连接的接口，以后如果需要更换数据库系统，可不更改程序的部分。

### 在Django要使用数据库时候的步骤：

1. 在models.py中定义需要使用的类\(需要继承models.Model\)
2. 设置每一个类中的变量，即数据表中的每一个字段
3. 使用`python manage.py makemigrations app`创建数据库和Django间的中间文件
4. 使用`python manage.py migrate`同步更新数据库的内容
5. 在程序中使用Python的方法操作所定义的数据类，等于是在操作数据库中的数据表。

> 两大命令：  
> 1. python manage.py makemigrations \[appname\]  
> 2. python manage.py migrate \[appname\]  
> appname参数可选，不填就是全部的app。
>
> python manage.py sqlmigrate appname 000x: 查看000x文件的sql语句。

### fake操作

> 当在开发过程中，设计好了model，但是有些字段又要改。   
> 如果使用`makemigrations`和`migrate`两个命令，那么会生成大量的migrations文件。  
> 这个时候可以使用`migrate migrate --fake app 000x`
>
> 比如： appname应用了004后。对Model添加了新的字段，migrate 0005后，发现这个字段错了，那就先还原成004的migrate状态。删掉004后面的migrations文件。修改新的字段后，再次执行makemigrations,再重新migrate即可。

`--fake`操作会去数据库`django_migrations`表中删除相关app执行migrate的记录。  
回滚到004，那么0005及后面的数据会被删除。

