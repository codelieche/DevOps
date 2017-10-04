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

### Monitor.js

```js
/**
 * 服务器监控数据展示
 * 需要传递的属性：
 * 1. host：主机名，不能为空
 * 2. timeFlag: 默认是：1h
 * 3. dataType: 默认是：cpu
 * 4. displayMonitor: 让监控组件display
 * 5. small：是不是小图，默认false, 如果是small那么图形的legend会竖排，否则是横排
 * 6. displayMonitor：开始monitor的div是隐藏的，当获取到了echarts的option后，就需要让div显示
 */

import React from 'react';

// 按需加载的话要引入这些【推荐做法】
import ReactEchartsCore from 'echarts-for-react/lib/core';
import echarts from 'echarts/lib/echarts';
import 'echarts/lib/chart/line';
import 'echarts/lib/component/tooltip';
// 注意要引入legend否则legend会不显示
import 'echarts/lib/component/legend';

export default class HostMonitor extends React.Component {
    constructor(props){
        super(props);
        const timeFlag = this.props.timeFlag ? this.props.timeFlag : '1h',
        dataType = this.props.dataType ? this.props.dataType : 'cpu';
        this.state = {
            dataType: dataType,
            timeFlag: timeFlag,
            monitorData: {},
            option: null
        }
    }

    componentDidMount() {
        if(this.props.host){
            this.fetchMonitorData();
        }
    }

    componentWillReceiveProps(nextProps) {
        // 当新的timeFlag来的时候，要修改下
        if(nextProps.timeFlag !== this.props.timeFlag){
            this.setState({
                timeFlag: nextProps.timeFlag,
            }, this.fetchMonitorData);
        }
        if(nextProps.host !== this.props.host){
            this.setState({
                host: nextProps.host,
            }, this.fetchMonitorData);
        }
    }

    getOption = () => {
        // 暂时只有cpu和memory两种，后面如果有io了，那还需要重新处理
        var y_name = this.state.dataType === 'cpu' ? '%' : 'G';
        var monitor_data = this.state.monitorData;
        // console.log(monitor_data);
        if(monitor_data.status !== "success"){
            return {}
        }
        var data = monitor_data.data;
        var type = monitor_data.type;
        var legend_height;
        if(this.props.small){
            legend_height = data.length * 25;
        }else{
            legend_height = data.length * 12;            
        }
        // var legend_height = 35;
        // console.log(y_name, type, legend_height, data);
        try {
            var x_data = data[0].time;
            var y_data =[], legend_names = [];
            var yAxis_data = [
                {
                    type: 'value',
                    axisTick: {
                        alignWithLable: true,
                    },
                    axisLine: {
                        onZero: false,
                        lineStyle: {
                            // color: colors[1]
                        }
                    },
                    nameLocation: 'end',
                    nameGap: 5,
                    nameTextStyle: {
                        color: '#444',
                        fontSize: 13,
                    },
                    // nameRotate: 45,
                    // 显示网格线
                    splitLine: {show: false},
                    // 坐标轴的分割段数，默认5
                    splitNumber: 3,
                    axisLabel: {
                        textStyle: {
                            //color: colors[0]
                        },
                        // 刻度标签是否朝内，默认朝外false
                        inside: true,
                        formatter: '{value}' + y_name,
                    },
                }
            ]

            // 如果type是mixed
            if(type === 'mixed'){
                // y坐标2
                yAxis_data.push(
                    {
                        type: 'value',
                        axisTick: {
                            alignWithLabel: true,
                        },
                        axisLine: {
                            onZero: false,
                            lineStyle: {
                                // color: colors[1]
                            }
                        },
                        // name: y_name,
                        nameLocation: 'end',
                        nameGap: 5,
                        nameTextStyle: {
                            color: '#444',
                            fontSize: 13,
                        },
                        // nameRotate: 45,
                        // 显示网格线
                        splitLine: { show: false},
                        // 坐标轴的分割段数 默认5
                        splitNumber: 3,
                        axisLabel: {
                            textStyle: {
                                //color: colors[0]
                            },
                            // 刻度标签是否朝内，默认朝外false
                            inside: true,
                            formatter: '{value}' + y_name,
                        },
                    }
                );

            }

            // y轴数据 y_data
            data.map((item) => {
                // console.log(item);
                var yAxisIndex = 0;
                if(type === 'mixed' && item.type === 'zabbix'){
                    yAxisIndex = 1;
                }
                y_data.push({
                    name: item.name,
                    type: 'line',
                    data: item.value,
                    yAxisIndex: yAxisIndex,
                });
                legend_names.push(item.name);
                return null;
            });

            if(! legend_height | legend_height < 35){
                legend_height = 35;
            }
        } catch (error) {
            console.log(error);
            return null;
        }

        // 上面的操作可能有异常，要捕获一下

        var colors = ['#5793f3', '#71D153', '#BA3928', '#FF8012', '#AF31F2'];

        // 设置图标的配置项和数据
        var option = {
            color: colors,
            title: {
                // text: "想你测试图表"
            },
            grid: {
                // top: 50,
                left: '4.5%',
                right: '5.5%',
                bottom: 35,
                top: legend_height,
            },
            tooltip: {
                trigger: 'axis',
                formatter: function(params) {
                    var result = "时间:" + params[0].axisValue;
                    for(var i=0; i<params.length; i++){
                        result += "<br>" + params[i].seriesName + ":" + params[i].data + y_name;
                    }
                    return result;
                },
                axisPointer: {
                    animation: false
                }
            },
            legend: {
                show: true,
                data: legend_names,
                top: 'auto',
                height: 'auto',
                // padding: [5,5,5,10],
                orient: this.props.small ? 'vertical' : 'horizontal',
            },
            xAxis: {
                data: x_data,
                type: 'category',
                name: 't',
                nameGap: 2,
                // nameRotate: "-45",
                splitLine: {
                    show: false,
                },
                min: "dataMin",
                axisLabel: {
                    inside: false,
                    // rotate: 45,
                }
            },
            yAxis: yAxis_data,
            // y轴数据列表
            series: y_data
        };

        // 重点：在设置状态前，先设置下monitor组件display，否则图标显示不出来
        // 没display会出现：Can't get dom width or height错误提示
        this.props.displayMonitor();
        //  把echarts需要的option写到state中
        this.setState({option})
        // console.log(option);

        return option;


    }

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

    render() {
        var EchartsElement;
        if(this.state.option){
            EchartsElement = (
                    <ReactEchartsCore
                        echarts={echarts}
                        notMerge={true}
                        layzyUpdate={true}
                        option={this.state.option}
                    />
            );
        }
        if(! this.props.host){
            return null;
        }
        return (
            <div>
                {EchartsElement}
            </div>
        );
    }
}
```

### 使用示例
文件位置：`./src/components/Monitor/Base/Host.js`.

```js
import MonitorChart from './Monitor';
// ......
<MonitorChart timeFlag={this.state.timeFlag} host={this.state.host}
  dataType={this.state.dataType}
  small={true}
  displayMonitor={this.displayMonitor} />
```

注意：`displayMonitor()`方法主要是让获取了echarts的配置后，再让monitor的div显示出来，开始是隐藏的。

