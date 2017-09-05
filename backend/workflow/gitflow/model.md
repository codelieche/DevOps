## Git代码提交工作流---Model
> 首先我们要编写个单例的类`GitJob`，继承`wrokflow.Job`.  
然后是编写`GitFlow`、`GitFlowApprove`、`GitFlowLog`.

文件位置：`apps/workflow/models/gitflow.py`


### 设计Model

先要引入依赖包：

```python
from django.db import models
from django.utils.timezone import datetime

from workflow.models.base import Job, JobFlow, Approve, FlowLog
```

每个相关的类其实都继承了base.py中的一个类。

#### GitJob

```python
class GitJob(Job):
    """
    Git 代码提交 Job Model
    """

    class Meta(Job.Meta):
        db_table = 'gitflow_job'
        verbose_name = "Git Job(代码提交)"
        verbose_name_plural = verbose_name
```

#### GitFLow

```python
class GitFlow(JobFlow):
    """
    Git 代码提交 工作流
    """

    # 需要勾选提交的项目，同时还需要选择commit的id
    project = models.ForeignKey(to='project.Project', verbose_name="项目")
    commit = models.CharField(max_length=40, verbose_name="提交ID")
    release = models.CharField(max_length=40, verbose_name='发布分支名', blank=True, null=True)

    @property
    def job(self):
        return GitJob.get_or_create()

    class Meta:
        db_table = 'gitflow_flow'
        verbose_name = "Git Job Flow(代码提交)"
        verbose_name_plural = verbose_name
```

#### GitFlowApprove

```python
class GitFlowApprove(Approve):
    """
    Git Flow Approve Model
    """
    jobflow = models.ForeignKey(to=GitFlow, verbose_name="工作流", related_name='approves')

    def save(self, *args, **kwargs):
        # 当保存的时候，需要根据status的值，来判断下当前的jobflow状态是否也要修改下
        # 如果状态refuse，那么在Approve的save方法中修改jobflow的status
        # 如果状态是agree，那么在approve的序列化model中判断jobflow是否已经是agree，是的话就修改状态
        if self.status == 'refuse':
            # 同样也要设置jobflow的状态
            self.jobflow.status = 'refuse'
            self.jobflow.time_end = datetime.now()
            self.jobflow.save(update_fields=('status', 'time_end'))
        return super(GitFlowApprove, self).save(*args, **kwargs)

    class Meta:
        db_table = 'gitflow_approve'
        verbose_name = "Git Flow Approve"
        verbose_name_plural = verbose_name
```

#### GitFlowLog

```python
class GitFlowLog(FlowLog):
    """
    Git FLow Log Model
    """
    jobflow = models.ForeignKey(to=GitFlow, verbose_name="工作流", related_name='logs')

    class Meta:
        db_table = 'gitflow_log'
        verbose_name = "Git Flow Log"
        verbose_name_plural = verbose_name
```
