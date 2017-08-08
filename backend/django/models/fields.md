## Django Fields

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

