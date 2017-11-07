## filtering

### 简单示例
> 以用户消息列表为例

```python
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter

class MessageListView(generics.ListAPIView):
    """
    用户消息列表View
    """
    queryset = Message.objects.filter(deleted=False)
    serializer_class = UserMessageSerializer
    # 权限控制
    permission_classes = (IsAuthenticated,)

    # 搜索和过滤
    filter_backends = (SearchFilter, DjangoFilterBackend)
    filter_fields = ('scope', 'unread')
    search_fields = ('title', 'content')
    
        def get_queryset(self):
        # 1. 先获取到用户
        user = self.request.user

        # 2. 获取到用户的消息
        queryset = Message.objects.filter(user=user, deleted=False)
        queryset = queryset.order_by('-time_added')
        return queryset
```

### 参考文档
- [filtering docs](http://www.django-rest-framework.org/api-guide/filtering/)