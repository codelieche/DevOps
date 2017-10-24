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
    
### QuerySet

#### 1. 获取SQL语句

```python
from project.models import Project

projects = Project.objects.all()
print(projects.query)
```

输出的结果：

```sql
SELECT `project`.`id`, `project`.`name`, `project`.`name_en`, `project`.`develop_deployment_id`, `project`.`test_deployment_id`, `project`.`product_deployment_id`, `project`.`jira_key`, `project`.`config_files`, `project`.`deleted`, `project`.`description` FROM `project`
```

#### 2. 根据某个字段排序
在设计模型，开始的时候，如果字段排序用的多，可以设置成整数型，同时添加好索引。  
**但是**：如果某个字段（eg:status）设置的是字符型，想要根据某个排序，怎么弄呢？  

> MemberFlow，是申请项目成员的工作流，它有个字段`status`，它的值有：`start`,`todo`,`cancel`,`doing`,`refuse`,`error`,`agree`,`success`,`done`。  
我们想根据：(`start`, `todo`, `doing`,`agree`,`success`,`done`,`error`,`refuse`,`cancel`)排序。

    
```python
from django.db.models import Case, When, Value, IntegerField

from workflow.models.member import MemberFlow

flows = MemberFlow.objects.filter(deleted=False).annotate(custom_order=Case(
                                                When(status='start', then=Value(1)),
                                                When(status='todo', then=Value(2)),
                                                When(status='doing', then=Value(3)),
                                                When(status='agree', then=Value(4)),
                                                When(status='success', then=Value(6)),
                                                When(status='done', then=Value(6)),
                                                When(status='error', then=Value(6)),
                                                When(status='refuse', then=Value(8)),
                                                When(status='cancel', then=Value(8)),
                                                output_field=IntegerField(),
                                            )
                                        ).order_by('custom_order', '-id')
 print(flows.query)
 ```
 
 这里设置了`done`和`erro`是相同权重值，相同值的，根据`id`倒序排列。  
 查看sql【下面语句是根据start,todo,doing排序的】：
 
 ```sql
SELECT `member_flow`.`id`, `member_flow`.`user_id`, `member_flow`.`status`, `member_flow`.`deleted`, 
CASE WHEN `member_flow`.`status` = start THEN 1 WHEN `member_flow`.`status` = todo THEN 2 
WHEN `member_flow`.`status` = doing THEN 3 ELSE NULL END AS `custom_order` FROM `member_flow` 
WHERE `member_flow`.`deleted` = False ORDER BY `custom_order` ASC, `member_flow`.`id` DESC
 ```