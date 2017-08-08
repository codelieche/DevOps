## Django 数据库迁移
> 两大命令：  
1. python manage.py makemigrations [appname]
2. python manage.py migrate [appname]
appname参数可选，不填就是全部的app。


### fake操作
> 当在开发过程中，设计好了model，但是有些字段又要改。 
如果使用`makemigrations`和`migrate`两个命令，那么会生成大量的migrations文件。  
这个时候可以使用`migrate migrate --fake app 000x`

> 比如： appname应用了004后。对Model添加了新的字段，migrate 0005后，发现这个字段错了，那就先还原成004的migrate状态。删掉004后面的migrations文件。修改新的字段后，再次执行makemigrations,再重新migrate即可。

`--fake`操作会去数据库的`django_migrations`表中删除相关app执行migrate的记录，回滚到004，那么0005及后面的数据会被删除。
