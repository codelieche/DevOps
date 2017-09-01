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

#### Job

```python
@python_2_unicode_compatible
class Job(models.Model):
    """
    审批工作
    每个Job由一个或者多个Step组成
    """
    slug = models.SlugField(max_length=20, verbose_name="网址", unique=True)
    name = models.CharField(max_length=100, verbose_name="工作")
    steps = models.ManyToManyField(to=Step, verbose_name="步骤", blank=True)
    # 是否是有序的
    ordered = models.BooleanField(verbose_name="是否有序", default=False, blank=True)
    can_change = models.BooleanField(verbose_name="能修改", default=False, blank=True)

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        self.pk = 1
        super(Job, self).save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        pass

    @classmethod
    def get_or_create(cls):
        obj, created = cls.objects.get_or_create(pk=1)
        return obj

    class Meta:
        abstract = True
        verbose_name = "工作"
        verbose_name_plural = verbose_name
```

#### JobFlow

```python
@python_2_unicode_compatible
class JobFlow(models.Model):
    """
    工作流
    当用户发起了Job流程，就创建这个实例，然后由系统去分发Approve对象
    注意： 不仅仅可以添加Job中的所有step的approve对象，也可以自定义的去添加approve对象
    """
    FLOW_STATUS_CHOICES = (
        ('start', "开始"),
        ('todo', "待审"),
        ('cancel', "取消"),
        ("doing", "执行中"),
        ('refuse', "拒绝"),
        ('end', "结束"),
        ('done', "完成")
    )
    # job = models.ForeignKey(to=Job, verbose_name="工作")
    user = models.ForeignKey(to="account.User", verbose_name="发起者", blank=True)
    status = models.CharField(max_length=10, verbose_name="状态", choices=FLOW_STATUS_CHOICES,
                              default="start", blank=True)
    description = models.CharField(max_length=256, verbose_name="描述", blank=True)
    time_start = models.DateTimeField(auto_now_add=True, verbose_name="开始时间", blank=True)
    time_end = models.DateTimeField(verbose_name="结束时间", blank=True, null=True)

    def __str__(self):
        return "JobFlow:{}".format(self.pk)

    @property
    def is_agree(self):
        """判断当前工作流是否全部通过"""
        # 第1步：先获取到所有的approve
        approve_list = self.approves.all()
        # 需要判断下当前的approve_list长度是否为0，如果为0，应该算异常还是提示错误【todo】

        # 第2步：判断所有的aprove对象，如果全部是通过，那么就是同意状态了
        for approve in approve_list:
            if not approve.is_aggree:
                return False
        # 所有的approve都是通过，那么当前工作流也是通过了
        return True

    class Meta:
        abstract = True
        verbose_name = "工作流"
        verbose_name_plural = verbose_name
```

#### Approve

```python
@python_2_unicode_compatible
class Approve(models.Model):
    """
    审批
    Approve对象主要是来自Job的每个Step对象
    但是有时候需要自定义的approve
    """
    APPROVE_STATUS_CHOICES = (
        ('todo', "待审"),
        ('lock', "锁住"),
        ('change', '返回修改'),
        ('refuse', "拒绝"),
        ('agree', "同意")
    )
    TYPE_CHOICES = (
        ('ready', '准备'),
        ('process', '过程'),
        ('done', '完成')
    )
    # jobflow = models.ForeignKey(to=JobFlow, verbose_name="工作流")
    # 步骤，不保存成外键，而是使用step的name字段【在生成approve的时候，需要校验一下，users是否合法】
    step = models.CharField(max_length=50, verbose_name="步骤")
    users = models.ManyToManyField(to="account.User", verbose_name="可操作的用户",
                                   related_name="can_approve_users")
    # 当可操作的用户中的任何一个，点击了，那么就只能这个用户操作了
    # 这个时候需要设置user的值，这个用户也可以解锁操作，重新设置为todo，即解锁了
    user = models.ForeignKey(to="account.User", verbose_name="操作者", blank=True, null=True)
    # 审批的时候需要填写内容
    content = models.CharField(max_length=100, verbose_name="审批内容", blank=True, null=True)
    # 只有当job的can_change是True，才可以设置为change的状态【是当前这个审批步骤修改，前面通过的不再重新审批】
    status = models.CharField(max_length=10, verbose_name="状态", choices=APPROVE_STATUS_CHOICES,
                              default="todo", blank=True)
    # 因为step不用外键了，所以order在approve中也需要保存一下
    order = models.IntegerField(verbose_name='顺序', default=1, blank=True)
    # step中有type字段，这个字段也需要保存到Approve中
    type = models.CharField(max_length=10, verbose_name='类型', default='process',
                            choices=TYPE_CHOICES, blank=True)
    # 当status完成(refuse/agree)后把能审批的users多对多数据删掉，没必要保存了
    time_start = models.DateTimeField(verbose_name="开始时间", blank=True, auto_now_add=True)
    time_end = models.DateTimeField(verbose_name="结束时间", blank=True, null=True)

    def can_approve(self, user):
        """
        判断用户是否能审批此对象
        :param user: User对象
        :return: True / False
        """
        if self.users.filter(username=user.username).exists():
            return True
        else:
            # 如果当前用户不在users中，就判断user是否是超级用户
            if user.is_superuser and settings.SUPERUSER_CAN_APPROVE_ALL:
                return True
            else:
                return False

    # 如果当前用户不在

    def __str__(self):
        return "Approve:{}".format(self.pk)

    def save(self, *args, **kwargs):
        # 保存的时候，如果job的can_change才可以设置状态为change
        if self.status == 'change' and not self.jobfow.job.can_change:
            raise ValueError("不能设置为status的状态")
        return super(Approve, self).save(*args, **kwargs)

    @property
    def is_aggree(self):
        """判断当前审批对象，是否已经同意"""
        if self.status == 'agree':
            return True
        else:
            return False

    class Meta:
        abstract = True
        verbose_name = "审批"
        verbose_name_plural = verbose_name
```

#### FlowLog

```python
@python_2_unicode_compatible
class FlowLog(models.Model):
    """
    工作流日志
    """
    type_CHOICES = (
        ('error', '错误'),
        ('success', '成功'),
        ('info', '信息')
    )
    time = models.DateTimeField(auto_now_add=True, verbose_name="添加时间", blank=True)
    # jobflow = models.ForeignKey(to=JobFlow, verbose_name="工作流")
    content = models.CharField(max_length=256, verbose_name="日志内容")
    type = models.CharField(max_length=10, verbose_name='日志类型', default='info', blank=True)

    def __str__(self):
        return "FlowLog:{}".format(self.pk)

    class Meta:
        abstract = True
        verbose_name = "工作流日志"
        verbose_name_plural = verbose_name
```

