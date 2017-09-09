## 通过py-zabbix获取基本的历史记录


### code


```python
import time
from datetime import datetime

from zabbix.api import ZabbixAPI
from django.conf import settings

class ZabbixBaseApi:
    """
    zabbix基础api
    """
    def __init__(self, url=settings.ZABBIX_SERVER, user=settings.ZABBIX_USER,
                 password=settings.ZABBIX_PASSWORD):
        self.zapi = ZabbixAPI(url=url, user=user, password=password)

    def from_ip_get_hostid(self, ip):
        """
        通过ip获取hostid
        :param ip: 服务器的ip
        :return: 返回zabbix中的hostid
        """
        # 先取出这些主机的hostid
        result = self.zapi.host.get(output="extend",
                                    filter={"host": ip})
        if len(result) == 1:
            hostid = result[0]['hostid']
            return hostid
        else:
            return None

    def from_hostid_get_itemid(self, hostid, item):
        """
        通过hostid获取itemid
        :param hostid: 主机id
        :param item: item的的值
        :return: 字符串，数字id
        """
        # 注意这里这里也是只返回单个值

        search_key = item
        # 开始查询获取items
        item_list = self.zapi.item.get(output="extend", hostids=hostid,
                                       search={"key_": search_key})
        # 取出item_list中的itemid
        if len(item_list) == 1:
            return item_list[0]['itemid']
        else:
            return None

    def get_itemid_history(self, itemid, time_start=None,
                           time_end=None, limit=None):
        """
        通过itemid获取历史数据
        :param itemid: itemid是单个值
        :param time_start: 开始时间
        :param time_end: 结束时间
        :param limit: 显示条数
        :return: 返回的是个数组
        [{'ns': '881652491', 'itemid': '81535', 'value': '308', 'clock': '1504860715'}...]
        """
        if isinstance(itemid, list):
            raise ValueError("itemid只能传入字符串，不可以传入列表")
        else:
            itemid_list = [itemid]

        if time_end:
            time_till = time_end
        else:
            time_till = time.mktime(datetime.now().timetuple())
        if time_start:
            time_from = time_start
        else:
            # 60秒 * 60 * h
            # 默认获取24h数据
            time_from = time_till - 60 * 60 * 12
        # 注意默认history是有好几种的，默认是3
        if limit:
            for history in range(0, 8):
                data = self.zapi.history.get(output="extend", history=history,
                                             itemids=itemid_list, limit=limit,
                                             time_from=time_from,
                                             time_till=time_till)
                if data:
                    return data['result']
        else:
            for history in range(0, 8):
                data = self.zapi.history.get(output="extend", history=history,
                                             itemids=itemid_list,
                                             time_from=time_from,
                                             time_till=time_till)
                if data:
                    return data
        return []
```