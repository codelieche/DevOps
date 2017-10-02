## 监控相关API

### monitor api list

| ID | API列表 |方法| 描述 |
| --- | --- | --- | --- |
| 1 | monitor/data | POST | 获取服务器监控数据 |


### API Detail

#### monitor/data
- url: `/api/1.0/monitor/data`
- 方法：`POST`
- 请求参数

| 名称 | 类型 | 必须 | 描述 | 示例值 |
| --- | --- | --- | --- | --- |
| host | String | 是 | 主机名称(多个以`,`分割) | codeliechedev,192.168.1.123 | 
| data_type | String | 否 | 获取的监控数据类型(cpu【默认】,memory) | cpu、memory |
| time_flag | String | 否 | 时间标致(数字+m,h,d)【默认1h】 | 3m,3h,3d(3分钟，3小时，3天) |
| time_start | String | 否 | 开始时间( 格式：%Y-%m-%d %H:%M:%S) | 2017-09-30 12:30:00 |
| time_end | String | 否 | 结束时间(格式 %Y-%m-%d %H:%M:%S) | 2017-09-30 12:36:00 |

- 注意事项：
    1. 时间标致是通过：time_flag, time_start, time_end控制的
    2. 当time_start传入了的时候，以它为准
    3. 结束时间是默认是当前时间，如果传入了就会以time_end为准
    4. 三个值都不传，会按着`1h`来取时间，取1小时的监控数据
    


