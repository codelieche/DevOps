## 项目工作流Model
文件位置： `apps/workflow/models/projectflow.py`。

- `ProjectJob`: 项目工作流的Job，继承`workflow.models.base`中的`Job`;
- `ProjectFlow`: 项目工作流的Flow, `workflow.models.base`中的`Flow`;
- `ProjectFlowApprove`: 项目工作流的审批,`workflow.models.base`中的`Approve`;
- `ProjectFlowLog`: 项目工作流的Log, `workflow.models.base`中的`Log`。

### Model

```python
from django.db import models
from django.utils.encoding import python_2_unicode_compatible
from django.utils.timezone import datetime

from workflow.models.base import Job, JobFlow, Approve, FlowLog
```

#### ProjectJob

```python
@python_2_unicode_compatible
class ProjectJob(Job):
    """
    项目Job Model
    """
    class Meta:
        db_table = "projectflow_job"
        verbose_name = "项目Job"
        verbose_name_plural = verbose_name
```

#### ProjectFlow

```python
@python_2_unicode_compatible
class ProjectFlow(JobFlow):
    """
    项目工作流 Model
    在添加项目创建工作流的时候，我们需要保存的字段信息有：
    JobFlow中已经有的字段：user、status、description、time_start、time_end
    user：申请者，使用request.user
    description: 申请理由描述

    Project相关的字段： name: 项目中文名 name_en: 项目英文名
        masters：项目经理 pms: 产品经理 developers: 开发者 tests: 测试人员
    frame: 项目使用的框架
    """
    name = models.CharField(max_length=200, verbose_name="项目名称", unique=True)
    name_en = models.CharField(max_length=50, verbose_name="项目英文名", unique=True)

    # 用户信息我们用字符串保存，使用逗号分隔
    masters = models.CharField(max_length=200, blank=True, null=True, verbose_name="项目经理")
    developers = models.CharField(max_length=200, blank=True, null=True, verbose_name="开发者")
    pms = models.CharField(max_length=200, blank=True, null=True, verbose_name="产品经理")
    tests = models.CharField(max_length=200, blank=True, null=True, verbose_name="测试人员")
    maintain = models.CharField(max_length=200, blank=True, null=True, verbose_name="维护人员")

    # 项目使用的框架
    frame = models.CharField(max_length=20, blank=True, default='other', verbose_name="框架")

    @property
    def job(self):
        return ProjectJob.get_or_create()

    class Meta:
        db_table = "projectflow_flow"
        verbose_name = "项目工作流"
        verbose_name_plural = verbose_name
```


#### ProjectFlowApprove

```python
@python_2_unicode_compatible
class ProjectFlowApprove(Approve):
    """
    项目工作流 审批
    """
    jobflow = models.ForeignKey(to=ProjectFlow, verbose_name="项目工作流", related_name="approves")

    def save(self, *args, **kwargs):
        # 当保存的时候，需要根据status的值，来判断下当前的jobflow状态是否也要修改下
        # 如果状态refuse，那么在Approve的save方法中修改jobflow的status
        # 如果状态是agree，那么在approve的序列化model中判断jobflow是否已经是agree，是的话就修改状态
        if self.status == 'refuse':
            # 同样也要设置jobflow的状态
            self.jobflow.status = 'refuse'
            self.jobflow.time_end = datetime.now()
            self.jobflow.save(update_fields=('status', 'time_end'))
        return super(ProjectFlowApprove, self).save(*args, **kwargs)

    class Meta:
        db_table = "projectflow_approve"
        verbose_name = "项目工作流审批"
        verbose_name_plural = verbose_name
```

#### ProjectFlowLog

```python
@python_2_unicode_compatible
class ProjectFlowLog(FlowLog):
    """
    项目创建工作流日志
    """
    jobflow = models.ForeignKey(to=ProjectFlow, verbose_name="工作流", related_name="logs")

    class Meta:
        db_table = "projectflow_log"
        verbose_name = "项目创建工作流日志"
        verbose_name_plural = verbose_name
```