## 工作流基础Model设计

### 工作流主要模型：

1. `Step`：步骤
2. `Job`：一个工作包含一个或者多个步骤
3. `JobFlow`：申请的工作流，有个Job的外键，然后拓展些其它的信息
4. `Approve`：审批操作，JobFlow实例化后，要多个Approve通过后，才出发某个事件
5. `FlowLog`：JobFlow的日志信息，比如：创建、审批日志、其它操作需要记录的信息

### 模型说明

> 工作流中：Step只是为了利于Job的配置，JobFlow和Approve才是最终的重点。
Job包含多个step，然后拓展自己的Job，比如GitJob。
根据job，生成自己的工作流：eg: GitFlow。

在实例化`GitFlow`的时候，根据前端提交过来的信息，生成`GitFlowApprove`.
最终是通过`Approve`是否全部通过，那当前的`Flow`就已经完成，修改其状态。

在：提交Flow实例的时候，要记录日志，同时还要生成对应的`Approve`对象数组
所有Approve在开始时状态是todo，其中users的所有用户都可以审批操作，
当用户点击了之后，user(操作者)就设置为这个点击的这个用户了，这时候状态改成了lock.
这个用户可以：同意（aggree）或者拒绝（refuse）当前这个审批。

注意生成操作日志:
操作日志：默认的类型是`info`，另外有`success`和`error`。

### 编写Model

```python
from django.db import models
from django.conf import settings
from django.utils.encoding import python_2_unicode_compatible
```

#### Step

```python

@python_2_unicode_compatible
class Step(models.Model):
    """
    步骤Model
    需要添加个can_approve的权限
    """
    # 审批的时候，有些并不需要一申请就给出初始化的环境
    # 当ready这个步骤通过的时候，就可以准备环境了，如果Job是无序的，那么应该在一申请就准备好环境
    # 比如：上线代码，只有当master通过ready的审批后，才去gitlab创建发布分支，测试环境拉取测试代码，准备测试。
    TYPE_CHOICES = (
        ('ready', '准备'),
        ('process', '过程'),
        ('done', '完成')
    )
    name = models.CharField(max_length=50, verbose_name="步骤")
    # 在设计步骤的时候，可以勾选，能操作的分组(分组中的所有用户都能成为可以操作的用户)
    # 当然也可以指定一些用户为这个步骤的【可】操作者
    # 注意，Step的设计是需要给用户赋予对象权限，而不是给用户分配Django的全局权限
    group = models.ForeignKey(to="auth.Group", verbose_name="分组", blank=True, null=True)
    users = models.ManyToManyField(to="account.User", verbose_name="用户", blank=True)
    # 步骤有顺序，从小到大，也可以是无序的
    order = models.IntegerField(verbose_name='顺序', default=1, blank=True)
    # 另外还有特殊情况，比如：每个项目的代码审核，需要对应项目的master去审核
    # 但是所有项目的审核使用一个job，这个时候master审核就不好指定可操作用户，需要特殊处理
    type = models.CharField(max_length=10, verbose_name='类型', default='process',
                            choices=TYPE_CHOICES, blank=True)

    def __str__(self):
        return self.name

    @property
    def users_all(self):
        # users_all是Step的一个属性，获取分组和users中的所有用户
        group_users = self.group.user_set.all()
        users_all = group_users.union(self.users.all())
        return users_all

    def can_approve(self, user):
        """
        判断用户是否能审批此步骤
        :param user: 用户
        :return: True / False
        """
        # 判断超级用户能否审核
        if user.is_superuser and settings.SUPERUSER_CAN_APPROVE_ALL:
            return True

        # 判断用户是否在Step的用户中：是就返回True、不是就返回False
        return self.group.user_set.filter(
            id=user.id).exists() or self.users.filter(id=user.id).exists()

    class Meta:
        verbose_name = "审批步骤"
        verbose_name_plural = verbose_name

        permissions = (
            ('can_approve', '能审批Step'),
        )
```
