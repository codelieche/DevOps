## 关系字段
> Django models中定了了一些列的字段来描述数据库之间的关联。

### ForeignKey
> 多对一关系。

#### 参数

##### on_delete
> 当一个ForeignKey引用的对象被删除时，Django默认模拟SQL的ON DELETE CASCADE的约束行为，并且删除包含该ForeignKey的对象。  
这种行为可以通过on_delete参数来改变。

比如：一个可以为空的`ForeignKey`，在其引用的对象被删除的时候，想把这个外键设置为空：

```
from django.db import models
group = models.ForeignKey(to=Group, null=True, blank=True, verbose_name="分组",
                               on_delete=models.SET_NULL)
```

###### on_delete可以设置的值
- `CASCADE`: 【默认值】级联删除，就是删除外键，引用了这个外键的对象也删除了
- `PROTET`: 抛出ProtectedError以阻止因运用对象的删除
- `SET_NULL`: 把`ForeignKey`设置为`null`, 首先得设置`null = True`才行
- `SET_DEFAULT`: 把外键设置为默认值，此时必须设置这个外键的default参数
- `SET`: 设置外键为传递给`SET()`的值，如果是一个可调用对象，则为调用后的结果
- `DO_NOTHING`: 不采取任何动作，会引发一个`django.db.utils.IntegrityError`错误。

