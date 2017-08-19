## Ant.Design之--头部与侧边栏

这篇文章是接着上一篇[Ant.Design之--布局](./layout.html)，对Header和Sider区域做一些修改。

### 效果图

![](/assets/front/ant_design_header_sider.png)

### Header

#### 1. 添加Header.js

文件位置：`src/components/Base/Header.js`

```js
 import React from 'react';
 import '../../styles/Header.css';

 export default class Header extends React.Component {
     render() {
         return (
            <div className="logo">
                <a href="http://www.codelieche.com">
                    <img src="http://www.codelieche.com/static/images/logo.svg" alt="首页" />
                </a>
            </div>
         );
     }
 }
```

#### 2. 编写Header.css

文件位置：`src/styles/Header.css`  
 ant.design自带的Header背景颜色是`#404040`, 高度和行高默认是`64px`。

```css
 /*网站头部样式  */
.ant-layout-header.header {
    /*网站头部样式  */
     background-color: #333744; 
    height: 50px;
    line-height: 50px;
    padding-left: 10px;
}

.ant-layout-header.header .logo{
    /*设置头部logo样式  */
    padding-top: 8px;
}
.ant-layout-header.header .logo img{
    /*设置logo图片样式  */
    width: 100px;
    height: auto;
}
```

* 默认的`Layout.Header`组件，自带的class是`.ant-layout-header`
* 需在`Layout.Header`使用的时候指定`className`属性为`header`这样上面的样式才会生效。
* 修改样式背景色为`#333744`，设置高和行高为`50px`。

  #### 3. 修改Home.js

  主要修改事项：

* 引入`Header`组件

* 给`Layout.Header`添加样式`header`
* 把`Header`组件放到`Layout.Header`中。

  ```git
  diff --git a/src/components/Home.js b/src/components/Home.js
  --- a/src/components/Home.js
  +++ b/src/components/Home.js
  @@ -11,15 +11,17 @@ import {

  import UserDetail from './User/Detail';
  import '../styles/Base.css';
  +import Header from './Base/Header';

  const {Content, Sider} = Layout;

  export default class Home extends React.Component {
    render() {
        return (
           <Layout style={{ height: "100vh", overflow: 'auto'}}>
  -                <Layout.Header>
  -                    头部内容
  +                <Layout.Header className="header">
  +                    <Header />
               </Layout.Header>
  ```

### Sider

侧边栏：`Layout.Sider`

#### 主要api

| 参数 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| collapsible | 是否可收起 | boolean | false |
| defaultCollapsed | 是否默认收起 | boolean | fasle |
| reverseArrow | 翻转折叠提示箭头的方向，当Sider在右边时可以使用 | boolean | false |
| collapsed | 当前收起状态 | boolean | - |
| onCollapse | 展开-收起时的回调函数，有点击trigger以及响应式反馈两种方式可以触发 | 函数\(collapsed, type\) | - |
| trigger | 自定义trigger，设置为`null`时隐藏trigger | string/ReactNode | - |
| width | 宽度 | number/string | 200 |
| collapsedWidth | 收缩宽度，设置为0会出现特殊`trigger` | number | 64 |
| breakpoint | 触发响应式布局的断点 | \(xs,sm,md,lg,xl\) | - |
| style | 指定样式 | object | - |
| className | 容器className | string | - |

#### 给Sider添加收起/展开功能

文件：`src/components/Home.js`

**1. 初始化this.state.collapsed**

```js
constructor(props){
    super(props);
    this.state = {
        collapsed: false,
    }
}
```

**2. 把状态值绑定到Sider属性上, 添加个触发开关的div元素**

```
<
  Sider
  collapsed={this.state.collapsed}
>
    <div onClick={this.toggle.bind(this)} className="sider-toggle">
        <Icon type={this.state.collapsed ? "menu-unfold" : "menu-fold"} />
    </div>
</Sider>
```

** 3. 编写tooggle事件**

```js
toggle = () => {
    //  侧边栏收起开关事件
    this.setState(prevState => ({
        collapsed: !prevState.collapsed,
    }));
}
```

* 只要`div.sider-toggle`元素点击，就会触发`toggle`事件
* `toggle`事件把组件`collapsed`状态值取反
* `div.sider-toggle`中的`icon`类型也根据`collapsed`的值而不同。

** 4. 编写样式**

文件：`src/styles/Sider.css`  
侧边栏`Layout.Sider`组件默认会添加css类是`ant-layout-sider`，默认的背景色是：`#404040`。  
所以需要在我们还需要在实例化`Layout.Sider`组件的时候添加`className="sider"`方便后续编写样式。

```css
/*侧边栏样式  */
.ant-layout-sider.sider {
    /*侧边栏样式  */
    background-color: #333744;
    overflow: auto;
}
.sider-toggle {
    /*侧边栏开关组件样式  */
    text-align: center;
    background-color: #4A5064;
    height: 35px;
    width: 100%;
}
.sider-toggle i {
    /*侧边栏开关里面 icon样式  */
    font-size: 16px;
    line-height: 35px;
    color: #FFF;
}
```

#### 给Sider添加自动收起事件

> 由于我们是用状态值`this.state.collapsed`来保存Sider的收起/展开状态的。  
> 如果给Sider添加自动触发收起事件，需要设置`breakpoint`和`onCollapse`.

**1. 编写onCollapse函数**

```js
onCollapse = (collapsed) => {
     // Sider的onCollapse事件
     this.setState({collapsed});
}
```

**2. 绑定到Sider上**

```js
<Sider
   collapsed={this.state.collapsed}
   className="sider"
   trigger={null}
   breakpoint="sm"
   onCollapse={this.onCollapse}
>
```

这样我们调整浏览器宽度，当宽度`<768px`就会收起侧边栏，`>=768px`就会展开侧边栏。

### Home.js

文件位置：`src/components/Home.js`  
最后我们看下Home.js的代码。

```js
/**
 * 布局Home页面
 */

import React from 'react';

import {
    Layout,
    Icon,
} from 'antd';

import UserDetail from './User/Detail';
import Header from './Base/Header';
import '../styles/Base.css';
// 引入侧边栏样式
import '../styles/Sider.css';

const {Content, Sider} = Layout;


 export default class Home extends React.Component {
     constructor(props){
         super(props);
         this.state = {
             collapsed: false,
         }
     }

     toggle = () => {
        //  侧边栏收起开关事件
        this.setState(prevState => ({
            collapsed: !prevState.collapsed,
        }));
     }

     onCollapse = (collapsed) => {
         // Sider的onCollapse事件
         this.setState({collapsed});
     }

     render() {
         return (
            <Layout style={{ height: "100vh", overflow: 'auto'}}>
                <Layout.Header className="header">
                    <Header />
                </Layout.Header>
                <Layout>
                    <Sider
                        collapsed={this.state.collapsed}
                        className="sider"
                        trigger={null}
                        breakpoint="sm"
                        onCollapse={this.onCollapse}
                    >
                        <div onClick={this.toggle.bind(this)} className="sider-toggle">
                            <Icon type={this.state.collapsed ? "menu-unfold" : "menu-fold"} />
                        </div>
                    </Sider>
                    <Layout style={{maxHeight: "100vh", overflow: "auto"}}>
                        <Content className="container">
                            <UserDetail />
                        </Content> 
                        <Layout.Footer>
                            Footer内容
                        </Layout.Footer>
                    </Layout>
                </Layout>
             </Layout>
        );
     }
 }
```

下一篇就是：编写侧边栏的导航栏。
