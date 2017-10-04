## 服务器监控数据展示组件
> 文件位置：`./src/components/Monitor/Base/Monitor.js`

### 需要传递的属性：
1. host：主机名，不能为空
2. timeFlag: 默认是：1h
3. dataType: 默认是：cpu
4. displayMonitor: 让监控组件display
5. small：是不是小图，默认false, 如果是small那么图形的legend会竖排，否则是横排
6. displayMonitor：开始monitor的div是隐藏的，当获取到了echarts的option后，就需要让div显示

### 获取监控数据的api
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


> 我们主要是传递3个值，`host`、`data_type`、`time_flag`.

#### fetch获取监控数据
> 注意：这个fetchMonitorData是在React Component组件中。  

```
fetchMonitorData = () => {
        // 从服务器获取监控数据
        var url = 'http://127.0.0.1:8080/api/1.0/monitor/data';
        const host = this.props.host;
        // console.log(host);
        if(! host){
            // 主机是不可以为空的
            // console.log("为空");
            return;
        }
        return fetch(url, {
            method: 'POST',
            credentials: 'include',
            headers: {"Content-Type": "application/json", 'Accept': 'application/json'},
            body: JSON.stringify({data_type: this.state.dataType, time_flag: this.state.timeFlag, host: host })
        })
          .then(response => response.json())
            .then(responseData => {
                // console.log(responseData);
                this.setState({
                    monitorData: responseData,
                }, this.getOption)
            })
              .catch(err => console.log(err));
    }
```

在setState方法中设置了`monitorData`数据后，我们再调用`this.getOption`方法，获取`echarts`所需要的配置选项。

