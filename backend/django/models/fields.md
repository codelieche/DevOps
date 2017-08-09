## Django Fields

### 常用字段

| 字段 | 重点参数 | 说明 |
| --- | --- | --- | 
| BigIntegerField |  | 64位的大整数 |
| BooleanField |  | 布尔值，只有True/False两种(数据表中保存的是1/0) |
| CharField | max_length: 指定可接受的最大字符串长度 | 用来存储较短数据的字符串，通常用于单行的文字数据 |
| DateField | auto_now: 每次对象被储存时都会自动更新当前日期.<br/>auto_now_add: 只在对象被创建时才加入当前日期 | 日期格式，可用datetime.date <br/>默认值：datetime.date.today,timezone.now |
| DateTimeField | 同上(只是是时间日期型) | 日期时间格式，对应datetime.datetime |
| DecimalField | max_digits: 可接受的最大位数 <br /> decimal_places: 在所有为数中，小数占几个位数 | 定点小数数值数据，适用于Python的Decimal模块的实例(财务相关需要精确的数值) |
| EmailField | max_length: 最长字数 | 可接受电子邮件地址格式的字段 |
| FloatField |  | 浮点数字段 |
| IntegerField | | 整数字段，是通用性最高的整数格式 |
| PostiveIntegerField |  | 正整数字段 |
| SlugField | max_length: 最大字符长度 | 和CharField一样，通常用来作为网址的一部分 |
| TextField |  | 长文字格式，一般用在HTML的Textarea输入项目中 |
| URLField | max_length: 最大字符长度 | 和CharField一样，特别用来记录完整的URL网址 |

### models.Model各个字段常用的属性
- `null`: 此字段是否接受存储为NULL(针对数据库而言的)，默认值是False
- `blank`: 此字段是否接受存储空白内容(验证表单而言的)，默认值是False
- `choices`: 以选项的方式作为此字段的候选值(只有固定内容的数据可以选用，一般用tuple类型)
- `default`: 字段的默认值
- `help_text`: 字段的求助信息
- `primary_key`: 把此字段设置为数据表中的主键KEY，默认值False,如果class中没主键，Django会自动创建个名字为id的自增主键
- `unique`: 设置此字段是否为唯一值，默认值是`False`
- `verbose_name`: 给字段命名一个可读性更好的名字

### 时间日期相关字段
> 时间日期相关字段有：`models.DateFiled`、`models.DateTimeField`.


**auto_now 与 auto_now_add的区别**
> 很多时候我们需要model的时间是自动设置的，比如：文章创建时间，文章更新时间。  

如果设置为`True`:  
- `auto_now_add`：为添加时的时间、更新对象时不会有变动
- `auto_now`: 无论添加还是修改，都会更新下最新一次`save()`操作时的时间

** 设置默认值 **
使用datetime:

```python
import datetime

from django.db import models

date_added = models.DateField(verbose_name="添加日期", blank=True, default=datetime.date.today)
```

使用timezone:

```python

from django.db import models
from django.utils import timezone

time_added = models.DateTimeField(verbose_name="添加时间", blank=True, default=timezone.now)
```

