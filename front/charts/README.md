## 图标展示
> 一图胜千言，在网页布局、展示中，适当的位置加几个图，整体看起来效果就会好很多。  
特别是监控数据，更需要图形的展示，我们选用`echarts`库来展示图形，另外可以考虑`D3.js`

### echarts
> ECharts，一个纯 Javascript 的图表库，可以流畅的运行在 PC 和移动设备上，兼容当前绝大部分浏览器（IE8/9/10/11，Chrome，Firefox，Safari等），底层依赖轻量级的 Canvas 类库 ZRender，提供直观，生动，可交互，可高度个性化定制的数据可视化图表。  

ECharts 提供了常规的折线图，柱状图，散点图，饼图，K线图，用于统计的盒形图，用于地理数据可视化的地图，热力图，线图，用于关系数据可视化的关系图，treemap，多维数据可视化的平行坐标，还有用于 BI 的漏斗图，仪表盘，并且支持图与图之间的混搭。

### echarts-for-react
> 一个简单的 echarts(v3.0) 的 react 封装。在使用中，注意是使用重点是编写`getOption`方法。

```
yarn add echarts-for-react
yarn add echarts
```
把这两个包添加到项目中，注意，要使用`yarn add`来添加，**不要**使用`npm install`。

#### 简单使用

- 直接引入包

```js
import ReactEcharts from 'echarts-for-react';
<ReactEcharts
    option={this.state.option}
/>
```

- 按需加载

```js
// 按需加载的话要引入这些【推荐做法】
import ReactEchartsCore from 'echarts-for-react/lib/core';
import echarts from 'echarts/lib/echarts';
import 'echarts/lib/chart/line';
import 'echarts/lib/component/tooltip';
// 注意要引入legend否则legend会不显示
import 'echarts/lib/component/legend';

<ReactEchartsCore
    echarts={echarts}
    notMerge={true}
    layzyUpdate={true}
    option={this.state.option}
/>
```

### 参考文档
- [echarts官网](http://echarts.baidu.com/)
- [echarts examples](http://echarts.baidu.com/examples.html)
- [echarts 配置手册(option文档)](http://echarts.baidu.com/option.html#title)
- [echarts-for-react](https://github.com/hustcc/echarts-for-react)
