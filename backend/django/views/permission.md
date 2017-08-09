## Django权限控制
> Django用User、Group和Permission完成权限机制。  
将属于Model的某个权限(permission)赋予user或group。

### 权限控制示例(博客)

比如：有个博客系统，文章模型（Post），用户(User)、分组(Group: 管理员、编辑、作者、读者)。
- `Model`: Post；
- `User`：u1、u2、u3；
- `Group`：admin, editor, author, reader

> 如果用户u1对模型(Post)有可写的权限，那么u1能修改Post的所有实例(objects).  
分组(group)的权限也是一样，如果分组editor拥有Post的可写权限，那么属于分组editor的所有用户，都能修改Post的所有实例。

**备注**：  
这种权限机制，能解决一些简单的应用场景，但是大部分的应用场景，需要更细分的权限机制。  
比如：博客系统，管理员、编辑、作者、读者四个分组。  
- 管理员和编辑拥有查看、修改和删除所有文章的权限(可以用Django的全局权限控制)。 
- 而作者也需要拥有修改、删除自己文章的权限，但是不能删除和修改别人的(需要对象权限`Object permission`)
- 读者只有阅读权限(这个好控制)。

而在面对上面的场景，如果用户不是管理员和编辑，我们可以通过判断`request.user`与文章的`user`是否相同，是就可以编辑删除文章，不是的话就没权限。  
这样做虽然也ok，但是最好是引入更细的权限控制机制：对象权限(`object permission`)  
object permission可以使用第三方app[django-guardian](https://github.com/django-guardian/django-guardian)。

> 比如有三篇文章p1,p2,p3，如果把p1的可写权限赋予了用户u1，那么u1可以修改p1对象，而对p2、p3无法修改。  
对group也是如此，如果把p2的可写权限赋予了分组g1，那么g1中的所有用户都拥有了修改p2的权限了，但是无法修改p1、p3.  
结合Django自带的权限机制和object permission，博客系统中坐着的权限控制就很好处理了（系统全局上不允许author分组编辑文字，但是对属于作者的文章，赋予编辑权限即可）

### Django的权限项
当我们编写model的时候，Django默认会创建三个权限：
- `add model`: 添加对象权限
- `change model`: 修改对象权限
- `delete model`: 删除对象权限
> 比如：文章Post模型定义好后，会自动创建三个permission：add_post、change_post和delete_post。

这些权限都是用django的permission对象存储的，在对应的数据表`auth_permission`中。  
我们可以自定义权限，在Meta中定义：

```python
from django.db import models

class Post(models.Model):
    title = models.CharField(max_length=128, verbose_name="标题")
    slug = models.SlugField(max_length=100, verbose_name="网址")
    body = models.TextField(verbose_name="内容")
    
    class Meta:
        verbose_name = "文章"
        verbose_name_plural = verbose_name
        permissions = (
            ("view_post", "能查看文章"),
            ("can_note_post", "能回复文章")
        )
```

**注意:**  
> permission总是与model对应的，如果一个对象不是model的实力，那么我们无法为它创建或分配权限。


