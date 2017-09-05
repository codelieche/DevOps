## GitFlow序列化Model

### 编写序列化Model
文件位置：`apps/workflow/serializers/gitflow.py`

```python
from rest_framework import serializers
from django.utils import timezone

from account.models import User
from project.models import Project
from workflow.models.base import Step
from workflow.models.gitflow import GitJob, GitFlow, GitFlowApprove, GitFlowLog
from workflow.serializers.workflow import StepSerializer
```

#### GitJobSerializer

```python
class GitJobSerializer(serializers.ModelSerializer):
    """
    Job Model Serializer
    """
    steps = StepSerializer(many=True, read_only=True)

    def update(self, instance, validated_data):
        # 获取到前端传过来的steps列表，然后修改validated_data的steps值
        steps = self.context['request'].data.getlist('steps', [])
        validated_data['steps'] = Step.objects.filter(id__in=steps)
        return super(GitJobSerializer, self).update(instance, validated_data)

    class Meta:
        model = GitJob
        fields = ('id', 'slug', 'name', 'steps', 'ordered', 'can_change')
```

#### GitFlowApproveSerializer

class GitFlowApproveSerializer(serializers.ModelSerializer):
    """
    Git Flow Approve Model Serializer
    """
    users = serializers.SlugRelatedField(read_only=True, slug_field='username', many=True)
    # queryset字段，填写User.objects.all()范围太大了，要缩小到当前approve的users
    user = serializers.SlugRelatedField(read_only=False, slug_field='username', required=False,
                                        queryset=User.objects.all(), allow_null=True)
                                        # queryset=User.objects.filter(username__in=users))
    can_approve = serializers.SerializerMethodField()

    def get_can_approve(self, obj):
        return obj.can_approve(self.context['request'].user)

    def update(self, instance, validated_data):
        # 第1步：先把validated_data中的数据改成request.user
        request = self.context['request']
        user = request.user
        validated_data['user'] = user

        # 权限判断放到viw中处理
        jobflow = instance.jobflow

        # 第2步：判断当前状态是否是todo，不是todo就不能操作
        if instance.status == 'todo':
            # 设置为锁定
            instance.status = 'lock'
            instance.user = request.user

            # 修改jobflow的状态为todo

            if jobflow.status == 'start':
                jobflow.status = 'todo'
                jobflow.save()

        # 第3步：修改状态和内容
        status = validated_data.get('status')
        content = validated_data.get('content')
        if status:
            instance.status = status
            instance.time_end = timezone.now()
        if content:
            instance.content = content
        instance.save()

        # 如果状态refuse，那么在Approve的save方法中修改jobflow的status
        # 如果状态是agree，那么在approve的序列化model中判断jobflow是否已经是agree，是的话就修改状态
        if status == 'agree':
            # 写入日志：
            message = '{}:{}同意'.format(instance.step, user.username)
            GitFlowLog.objects.create(jobflow=jobflow, content=message, type='success')
            # 现在判断是不是ready，如果是，就需要准备环境了
            if instance.type == 'ready':
                message = '开始准备环境'
                GitFlowLog.objects.create(jobflow=jobflow, content=message, type='success')
                # 这里是调用准备环境的操作！

            # 同意的话，判断jobflow是否都已经同意
            if jobflow.is_agree:
                jobflow.status = 'agree'
                jobflow.time_end = timezone.now()
                jobflow.save()
                # 这里要触发一个发站内信的内容
                GitFlowLog.objects.create(jobflow=jobflow, content="审批已经通过", type='success')
                # 后面还有日志，比如审批后的操作也需要日志的
        elif status == 'refuse':
            # 写入日志：
            message = '{}:{}拒绝'.format(instance.step, user.username)
            GitFlowLog.objects.create(jobflow=instance.jobflow, content=message, type='error')
            jobflow.status = 'refuse'
            jobflow.time_end = timezone.now()
            jobflow.save()
        # 修改approve对象
        return instance

    class Meta:
        model = GitFlowApprove
        fields = ('id', 'step', 'users', 'user', 'content', 'status', 'order',
                  'can_approve', 'time_start', 'time_end', 'type')
        read_only_fields = ('id', 'step', 'users', 'order', 'can_approve')
```

#### GitFlowSerializer

```python
class GitFlowLogSerializer(serializers.ModelSerializer):
    """
    Git Flow Log Model Serializer
    """
    class Meta:
        model = GitFlowLog
        fields = ('id', 'time', 'content', 'type')
```


#### GitFlowSerializer

```python
class GitFlowSerializer(serializers.ModelSerializer):
    """
    Git 代码提交工作流  Serializer Model
    """
    user = serializers.SlugRelatedField(read_only=True, slug_field='username')
    project = serializers.SlugRelatedField(read_only=False, slug_field='name_en',
                                           queryset=Project.objects.all())
    # job = GitJobSerializer(read_only=True)
    approves = GitFlowApproveSerializer(many=True, read_only=True, required=False)
    # 日志信息
    logs = GitFlowLogSerializer(many=True, read_only=True, required=False)

    def create(self, validated_data):
        # 创建GitFlow对象
        # 第1步：把当前的用户设置为Flow的申请者
        user = self.context['request'].user
        validated_data['user'] = user

        # 第2步：调用父类的create方法，成功会返回gitflow的对象，传递的数据有错，会直接返回错误页
        gitflow = super(GitFlowSerializer, self).create(validated_data)

        # 第3步：保存日志
        message = "{}:申请工作流成功".format(user.username)
        GitFlowLog.objects.create(jobflow=gitflow, content=message, type='success')

        # 第4步： 生成审批对象
        # 4-1：生成，项目负责人审批【这个是ready步骤】
        # 由于users是多对多，需要先生成了approve，再设置其users
        approve = GitFlowApprove.objects.create(jobflow=gitflow, step='项目负责人审批',
                                                type='ready', order=0)
        approve.users = gitflow.project.masters.all()

        # 4-2: 根据Job的步骤，去生成相应的审批
        # 判断是否需要对steps排序一下根据order
        if gitflow.job.ordered:
            steps = gitflow.job.steps.all().order_by('order', 'id')
        else:
            steps = gitflow.job.steps.all()
        request = self.context['request']
        for step in steps:
            # 根据step的id获取相应的users
            name = 'step_{}'.format(step.id)
            users_str_list = request.data.get(name)
            users_set = User.objects.filter(username__in=users_str_list)
            # 判断用户是否有这个权限
            users_ok = []
            for u in users_set:
                if step.can_approve(u):
                    users_ok.append(u)
            # 创建approve【把step对象的name、order和type保存过来】
            approve = GitFlowApprove.objects.create(jobflow=gitflow, type=step.type,
                                                    step=step.name, order=step.order)
            # 设置可审批的用户
            approve.users = users_ok

        # 第5步：返回gitflow对象
        return gitflow

    class Meta:
        model = GitFlow
        fields = ('id', 'user', 'project', 'commit', 'release',
                  'approves', 'status', 'logs', 'time_start', 'time_end')
 ```