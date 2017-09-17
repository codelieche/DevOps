## 项目工作流--序列化Model

### Model列表
- `ProjectJobSerializer`: 项目工作流Job的序列化Model
- `ProjectFlowApproveSerializer`: 审批
- `ProjectFlowLogSerializer`: 日志
- `ProjectFlowSerializer`: 项目工作流

> 其中重点就是`ProjectFlowSerializer`中的`create`方法，  
另外还有`ProjectFlowApproveSerializer`中的`update`方法。  
其实其它工作流也重点用到了这两个函数，而且流程，处理方式都差不多。  
注意看注释，即可。



### 代码

> 先引入依赖包。

```python
from rest_framework import serializers
from django.utils import timezone

from account.models import User
from workflow.models.base import Step
from workflow.models.projectflow import ProjectJob, ProjectFlow, ProjectFlowApprove, ProjectFlowLog
from workflow.serializers.workflow import StepSerializer
```

#### ProjectJobSerializer

```python
class ProjectJobSerializer(serializers.ModelSerializer):
    """
    项目工作流 序列化Model
    """
    steps = StepSerializer(many=True, read_only=True)

    def update(self, instance, validated_data):
        """更新ProjectJob对象，主要就是修改下步骤和名称"""
        # 修改的时候PUT过来的steps是个列表，同时传递的是Step对象的id值
        steps = self.context['request'].data.getlist('steps', [])
        validated_data['steps'] = Step.objects.filter(id__in=steps)
        return super(ProjectJobSerializer, self).update(instance, validated_data)

    class Meta:
        model = ProjectJob
        fields = ('id', 'slug', 'name', 'steps', 'ordered', 'can_change')
```


#### ProjectFlowApproveSerializer

```python
class ProjectFlowApproveSerializer(serializers.ModelSerializer):
    """
    项目工作 审批 序列化Model
    """
    # 能审批的用户
    users = serializers.SlugRelatedField(read_only=True, slug_field='username', many=True)
    # User: 一个审批对应一个用户去审批，users中的任意一个点击了这个Approve，那么user值就是这个点击的用户
    user = serializers.SlugRelatedField(read_only=False, slug_field='username', required=False,
                                        queryset=User.objects.all(), allow_null=True)
    # 当前用户(request.user)能否操作当前审批
    can_approve = serializers.SerializerMethodField()

    def get_can_approve(self, obj):
        return obj.can_approve(self.context['request'].user)

    def update(self, instance, validated_data):
        # 第1步：先把validated_data中的user改成request.user
        request = self.context['request']
        user = request.user
        validated_data['user'] = user

        # 权限判断放到view中处理
        jobflow = instance.jobflow

        # 第2步：判断当前状态是否是todo，不是todo就不能操作
        if instance.status == 'todo':
            # 设置为锁定
            instance.status = 'lock'
            instance.user = user

            # 修改jobflow的状态为todo
            if jobflow.status == 'start':
                jobflow.status = 'todo'
                jobflow.save()

        # 第3步：修改状态和内容
        # 审批的时候会传递状态(status)、审批备注内容(content)
        status = validated_data.get('status')
        content = validated_data.get('content')
        if status:
            instance.status = status
            instance.time_end = timezone.now()
        if content:
            instance.content = content
        # 这里就需要对实例保存下了
        instance.save()

        # 如果状态是refuse，那么Approve的save方法中修改jobflow的status
        # 如果状态是agree，那么在approve的序列化model中判断jobflow是否已经是agree，是的话就修改状态
        if status == 'agree':
            # 写入日志：
            message = '{}:{}同意'.format(instance.step, user.username)
            ProjectFlowLog.objects.create(jobflow=jobflow, content=message, type="success")

            # 现在要判断是不是ready，如果是，就需要准备环境了
            # 另外还可以根据Step中的type为job、done做不同的操作
            if instance.type == 'ready':
                # 这里不同job有不同的ready
                message = "开始准备环境"
                ProjectFlowLog.objects.create(jobflow=jobflow, content=message, type="success")
                # 这里调用准备环境的操作，注意写好日志

            # 同意的话，判断jobflow是否都已经同意
            if jobflow.is_agree:
                jobflow.status = "agree"
                jobflow.time_end = timezone.now()
                jobflow.save()
                # 这里要触发一个发站内信的操作
                ProjectFlowLog.objects.create(jobflow=jobflow, content="审批已经通过", type="success")
                # 后面还有日志，比如审批后的操作也要有日志，创建项目部署啊，等等
        elif status == 'refuse':
            # 写入日志
            message = "{}:{}拒绝".format(instance.step, user.username)
            ProjectFlowLog.objects.create(jobflow=jobflow, content=message, type="error")
            jobflow.status = 'refuse'
            jobflow.time_end = timezone.now()
            jobflow.save()

        # 返回修改后的approve对象
        return instance

    class Meta:
        model = ProjectFlowApprove
        fields = ('id', 'step', 'users', 'user', 'content', 'status', 'order',
                  'can_approve', 'time_start', 'time_end', 'type')
        read_only_fields = ('id', 'step', 'users', 'order', 'can_approve')
```

#### ProjectFlowLogSerializer

```python
class ProjectFlowLogSerializer(serializers.ModelSerializer):
    """项目工作流 日志 序列化Model"""

    class Meta:
        model = ProjectFlowLog
        fields = ('id', 'time', 'content', 'type')
```

#### ProjectFlowSerializer

```python
class ProjectFlowSerializer(serializers.ModelSerializer):
    """
    项目工作流 序列化Model
    """
    user = serializers.SlugRelatedField(read_only=True, slug_field='username')

    # 工作流相关的审批
    approves = ProjectFlowApproveSerializer(many=True, read_only=True, required=False)
    # 日志信息
    logs = ProjectFlowLogSerializer(many=True, read_only=True, required=False)

    def create(self, validated_data):
        # 创建ProjectFLow对象
        # 第1步：把当前的用户设置为Flow的申请者
        user = self.context['request'].user
        validated_data['user'] = user

        # 第2步：调用父类的create方法，成功会返回projectflow的对象，传递的数据有误，会直接返回错误页
        projectflow = super(ProjectFlowSerializer, self).create(validated_data)

        # 第3步：保存日志
        message = "{}申请创建项目".format(user.username)
        ProjectFlowLog.objects.create(jobflow=projectflow, content=message, type="success")

        # 第4步：生成审批对象【重点】
        # 4-1: 用户的leader审批

        # 4-2：根据Job的步骤，去生成相应的审批
        # 判断是否需要对steps排序一下
        if projectflow.job.ordered:
            steps = projectflow.job.steps.all().order_by('order', 'id')
        else:
            steps = projectflow.job.steps.all()
        # 添加每个step的Approve对象
        request = self.context['request']
        for step in steps:
            # 根据step的id获取相应的users
            name = 'step_{}'.format(step.id)
            users_str_list = request.data.get(name, [])
            if users_str_list:
                # 如果传入了用户，就使用指定的用户
                user_set = User.objects.filter(username__in=users_str_list)
                # 判断用户是否有这个权限
                users_ok = []
                for u in user_set:
                    if step.can_approve(u):
                        users_ok.append(u)
            else:
                # 如果传入的用户是空，那么就使用step对象中users_all
                users_ok = step.users_all

            # 创建approve【把step对象的name、order和type保存过来】
            approve = ProjectFlowApprove.objects.create(jobflow=projectflow, type=step.type,
                                                        step=step.name, order=step.order)
            # 设置可审批的用户
            approve.users = users_ok

        # 第5步：返回flow对象
        return projectflow

    class Meta:
        model = ProjectFlow
        fields = ('id', 'user', 'description',
                  # 创建项目时要用到的字段
                  'name', 'name_en', 'masters', 'pms', 'developers', 'tests', 'maintain',
                  'approves', 'status', 'logs', 'time_start', 'time_end')
```