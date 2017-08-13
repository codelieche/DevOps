## Django数据查询
> 获取Model的数据，主要使用get和filter。

### Filter和get的区别
- filter: 返回复合指定条件的QuerySet,条件不满足返回空列表`[]`
- get: 获取指定复合条件的唯一元素，如果找不到或者找到多个，都会报错异常
    1. 如果没找到会抛出：`DoesNotExist`异常
    2. 如果条件找到了多个值，抛出`MultipleObjectsReturned`异常

### Django ORM常用的函数
- `create()`: 创建对象，eg: `p = Project.objects.create(name="shop123")`
- `all()`: 获取所有的对象, eg: `Project.objects.all()`
- `filter()`: 返回复合指定条件的QuerySet
- `get()`: 获取指定复合条件的唯一元素，复合条件的元素大于1或者没有都会抛出异常
- `exclude()`: 返回不符合指定条件的QuerySet
- `order_by()`: 串连在`QuerySet`之后，针对某个字段进行排序
- `all()`: 返回所有的`QuerySet`
- `first()`: 获取QuerySet中的第1个元素: eg: `Project.objects.first()`
- `last()`: 获取QuerySet中的最后一个元素: 
    - eg: `Project.objects.filter(type="shop").last()`
    
- `exists()`: 用来检查是否存在某条件的记录，通常用在`filter()`后面
- `update()`: 用来快速更新【某些】数据记录中的字段内容
- `save()`: 保存对象，eg: `p.name = "djangoshop"; p.save()`
- `delete()`: 杀出指定的记录
- `aggregate()`: 可以用来计算数据项的聚合函数
- `iexact`: 不区分大小写的条件设置
- `contains/icontains`: 含有某一字符串的对象，如SQL语句中的LIKE和ILIKE
- `in`: 提供一个列表，只要符合列表中的仍和一个值均可以
- `gt/gte/lt/lte`: 大于/大于等于/小于/小于等于
    - `Project.objects.filter(id__in=[1, 3, 5])`: 获取id为1,3,5的project
    - `Project.objects.filter(id__gt=10)`: 获取Project中id大于10的对象
    - `Project.objects.filter(name__icontains="shop")`: 获取Project中name包含shop字段的对象
    


