## Django Model Logging
> Django Admin中管理员对对象修改，都会有条记录(数据库django_admin_log中)。  
有时候我们编写了api，当用户对数据修改或者删除，我们也想记录些日志。

### Django中的LogEntry

```python
 from django.contrib.admin.models import LogEntry
 ```
 
 #### django.contrib.admin.models源码
 
 ```
 from __future__ import unicode_literals

import json

from django.conf import settings
from django.contrib.admin.utils import quote
# ContentType有id,app_label, model字段，对应数据库中的表django_content_type
from django.contrib.contenttypes.models import ContentType
from django.db import models
from django.urls import NoReverseMatch, reverse
from django.utils import timezone
from django.utils.encoding import force_text, python_2_unicode_compatible
from django.utils.text import get_text_list
from django.utils.translation import ugettext, ugettext_lazy as _

# 定义常量，日志类型： 1：增加，2：修改，3：删除
ADDITION = 1
CHANGE = 2
DELETION = 3


class LogEntryManager(models.Manager):
    use_in_migrations = True

    def log_action(self, user_id, content_type_id, object_id, object_repr, action_flag, change_message=''):
        """
        :param user_id: 用户的id
        :param content_type_id: 模型在ContentType的序号
        :param object_id：对象的id
        :param object_repr：可读性的对象名称(__str__返回的值，py2是__unicode__)
        :param action_flag: 行为标记，1是添加，2是修改，3是删除
        :param change_message: 要记录的日志内容       
        """
        if isinstance(change_message, list):
            change_message = json.dumps(change_message)
        
        # self.model可以返回管理器处自己的Model，也就是LogEntry
        return self.model.objects.create(
            user_id=user_id,
            content_type_id=content_type_id,
            object_id=force_text(object_id),
            object_repr=object_repr[:200],
            action_flag=action_flag,
            change_message=change_message,
        )


@python_2_unicode_compatible
class LogEntry(models.Model):
    # 操作时间
    action_time = models.DateTimeField(
        _('action time'),
        default=timezone.now,
        editable=False,
    )
    # 操作用户
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        models.CASCADE,
        verbose_name=_('user'),
    )
    # ContentType的外键
    content_type = models.ForeignKey(
        ContentType,
        models.SET_NULL,
        verbose_name=_('content type'),
        blank=True, null=True,
    )
    # 对象的ID
    object_id = models.TextField(_('object id'), blank=True, null=True)
    # Translators: 'repr' means representation (https://docs.python.org/3/library/functions.html#repr)
    # 对象__str__的返回值
    object_repr = models.CharField(_('object repr'), max_length=200)
    # 操作标志
    action_flag = models.PositiveSmallIntegerField(_('action flag'))
    # change_message is either a string or a JSON structure
    # 修改日志，是个字符串或者json结构的字符串
    change_message = models.TextField(_('change message'), blank=True)
    
    # 使用自定义的Manager
    objects = LogEntryManager()

    class Meta:
        verbose_name = _('log entry')
        verbose_name_plural = _('log entries')
        db_table = 'django_admin_log'
        ordering = ('-action_time',)

    def __repr__(self):
        return force_text(self.action_time)

    def __str__(self):
        if self.is_addition():
            return ugettext('Added "%(object)s".') % {'object': self.object_repr}
        elif self.is_change():
            return ugettext('Changed "%(object)s" - %(changes)s') % {
                'object': self.object_repr,
                'changes': self.get_change_message(),
            }
        elif self.is_deletion():
            return ugettext('Deleted "%(object)s."') % {'object': self.object_repr}

        return ugettext('LogEntry Object')

    def is_addition(self):
        return self.action_flag == ADDITION

    def is_change(self):
        return self.action_flag == CHANGE

    def is_deletion(self):
        return self.action_flag == DELETION

    def get_change_message(self):
        """
        If self.change_message is a JSON structure, interpret it as a change
        string, properly translated.
        """
        if self.change_message and self.change_message[0] == '[':
            try:
                change_message = json.loads(self.change_message)
            except ValueError:
                return self.change_message
            messages = []
            for sub_message in change_message:
                if 'added' in sub_message:
                    if sub_message['added']:
                        sub_message['added']['name'] = ugettext(sub_message['added']['name'])
                        messages.append(ugettext('Added {name} "{object}".').format(**sub_message['added']))
                    else:
                        messages.append(ugettext('Added.'))

                elif 'changed' in sub_message:
                    sub_message['changed']['fields'] = get_text_list(
                        sub_message['changed']['fields'], ugettext('and')
                    )
                    if 'name' in sub_message['changed']:
                        sub_message['changed']['name'] = ugettext(sub_message['changed']['name'])
                        messages.append(ugettext('Changed {fields} for {name} "{object}".').format(
                            **sub_message['changed']
                        ))
                    else:
                        messages.append(ugettext('Changed {fields}.').format(**sub_message['changed']))

                elif 'deleted' in sub_message:
                    sub_message['deleted']['name'] = ugettext(sub_message['deleted']['name'])
                    messages.append(ugettext('Deleted {name} "{object}".').format(**sub_message['deleted']))

            change_message = ' '.join(msg[0].upper() + msg[1:] for msg in messages)
            return change_message or ugettext('No fields changed.')
        else:
            return self.change_message

    def get_edited_object(self):
        "Returns the edited object represented by this log entry"
        return self.content_type.get_object_for_this_type(pk=self.object_id)

    def get_admin_url(self):
        """
        Returns the admin URL to edit the object represented by this log entry.
        """
        if self.content_type and self.object_id:
            url_name = 'admin:%s_%s_change' % (self.content_type.app_label, self.content_type.model)
            try:
                return reverse(url_name, args=(quote(self.object_id),))
            except NoReverseMatch:
                pass
        return None
```