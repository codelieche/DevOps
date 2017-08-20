## Ant.Design之--导航菜单

> antd自带的Menu已经很好了，但是导航想自定义。

### 准备文件

* `src/components/Base/nav.js`: 导航菜单组件
* `src/compoennts/Base/nav-data.js`: 导航菜单数据放这里
* `src/styles/Nav.css`: 导航菜单的样式

### 编写简单Nav

先编写简单的Nav，最后才是通过数据渲染导航菜单。

#### 简单导航菜单效果图

![](/assets/front/nav_menu_simple.png)

#### 1. 编写简单nav

* `menu-left`: Nav的最外层class
* `sub-menu`: 每一块菜单元素class【里面有一级菜单+二级菜单】
  1. `sub-menu-title`: 一级菜单标题元素class
  2. `nav-menu-item`: 二级菜单元素的class
  3. `nav-menu-title`: 二级菜单标题【包含有icon和span】
  4. `title`: 一级二级菜单的标题class

```js
import React from 'react';
import {
    Icon,
} from 'antd';
import '../../styles/Nav.css';

export default class Nav extends React.Component {
    render() {
        return (
            <div className="menu-left">
                <div className="sub-menu" key="asset">
                    <div className="sub-menu-title">
                        <Icon type="bank" />
                        <span className="title">一级导航1</span>
                    </div>
                    <ul className="nav-menu">
                        <li className="nav-menu-item" key={1}>
                            <a className="nav-menu-title">
                                <Icon type="right" />
                                <span className="title">二级导航1</span>
                            </a>
                        </li>
                        <li className="nav-menu-item" key={2}>
                            <a className="nav-menu-title">
                                <Icon type="right" />
                                <span className="title">二级导航2</span>
                            </a>
                        </li>
                    </ul>
                </div>

                <div className="sub-menu active" key="user">
                    <div className="sub-menu-title">
                        <Icon type="bank" />
                        <span className="title">一级导航2</span>
                    </div>
                    <ul className="nav-menu">
                        <li className="nav-menu-item" key={1}>
                            <a className="nav-menu-title">
                                <Icon type="right" />
                                <span className="title">二级导航3</span>
                            </a>
                        </li>
                        <li className="nav-menu-item" key={2}>
                            <a className="nav-menu-title active">
                                <Icon type="right" />
                                <span className="title">二级导航4</span>
                            </a>
                        </li>
                        <li className="nav-menu-item" key={3}>
                            <a className="nav-menu-title">
                                <Icon type="right" />
                                <span className="title">二级导航5</span>
                            </a>
                        </li>
                    </ul>
                </div>

            </div>
        );
    }
}
```

#### 2.编写样式nav.css

```css
/*导航菜单样式  */
.menu-left {
    /*侧边栏 导航菜单样式  */
    color: #F8F8F8;
    width: 100%;
}
.menu-left i {
    /*菜单icon样式  */
    font-size: 15px;
    color: #F8F8F8;
    line-height: 40px;
}

.menu-left .tilte{
    /*导航菜单 标题样式  */
    padding-left: 7px;
    font-size: 13px;
}

.menu-left .sub-menu {
    /*左边导航 子Menu样式  */
    display: block;
    width: 100%;
}

.menu-left .sub-menu-title {
    /*一级标题样式  */
    height: 40px;
    padding-left: 22px;
    position: relative;
}

.menu-left .sub-menu-title .tilte {
    /*一级标题标题样式  */
    line-height: 40px;
}

.menu-left .sub-menu-title:hover {
    /*一级导航 鼠标移动上去时候的样式  */
    background-color: #00c1de;
}

.menu-left .nav-menu{
    /*一级导航中的ul.nav-menu  */
    /*ul 中的li放的就是二级菜单  */
    /*二级菜单，默认不展开  */
    display: none;
    width: 100%;
}
.menu-left .sub-menu.active  .nav-menu{
    /*当一级菜单有active的时候 二级菜单展开  */
    display: block;
}

.menu-left .sub-menu .nav-menu .nav-menu-item {
    /*设置二级菜单样式  */
    height: 40px;
}

.menu-left .sub-menu .nav-menu .nav-menu-item a {
    /*二级菜单a连接的样式  */
    padding-left: 44px;
    display: block;
    color: #F8F8F8;
    line-height: 40px;
    background-color: #424858;
    text-decoration: none;
}
.menu-left .sub-menu .nav-menu .nav-menu-item a:hover{
    /*设置二级菜单a链接鼠标移上去时候的样式  */
    background-color: #4A5064;
}
.menu-left .sub-menu .nav-menu .nav-menu-item a.active{
    /*设置二级菜单a链接 有active时候的样式  */
    background-color: #00c1de;
}

.menu-left .sub-menu .nav-menu .nav-menu-item i{
    /*二级菜单 标题中 icon样式  */
    font-size: 13px;
}

/* 设置sider缩小的时候最小宽度 */
.ant-layout-sider-children{
    min-width: 64px;
    /* 导航side缩放后放大，宽度变成185px了，或者取消设置.side的overflow:auto */
    overflow: hidden;
}

/*侧边栏是可以缩小的  */
/*当侧边栏缩小的时候  导航菜单样式也需要做适当调整  */
.menu-left.menu-small {
    /*侧边栏收起的时候 给menu-left加个class menu-small  */
}
.menu-left.menu-small .title {
    /*当是小菜单的时候，一级二级菜单的title应该不显示  */
    display: none;
}

.menu-left.menu-small .sub-menu{
    display: block;
}
.menu-left.menu-small .nav-menu .nav-menu-item a{
    /*a链接开始是与左边距离44px，现在减少一半  */
    padding-left: 22px;
}


/*设置一级标题右侧的小尖角符号  */
.menu-left .sub-menu.active .sub-menu-title .title::after{
    /*当一级标题是active的时候，让右侧的尖角符号转动180度  */
    transform: rotate(180deg) scale(0.75);
}

.menu-left .sub-menu .sub-menu-title .title::after{
    /* title 后面的尖角符号 */
    line-height: 40px;
    font-family: "anticon" !important;
    font-style: normal;
    vertical-align: baseline;
    text-align: center;
    text-transform: none;
    text-rendering: auto;
    position: absolute;
    -webkit-transition: -webkit-transform .3s;
    transition: -webkit-transform .3s;
    -o-transition: transform .3s;
    transition: transform .3s;
    transition: transform .3s, -webkit-transform .3s;
    content: "\E61D";
    right: 16px;
    top: 0;
    display: inline-block;
    font-size: 12px;
    font-size: 8px \9;
    -webkit-transform: scale(0.66666667) rotate(0deg);
    -ms-transform: scale(0.66666667) rotate(0deg);
    transform: scale(0.66666667) rotate(0deg);
    -ms-filter: "progid:DXImageTransform.Microsoft.Matrix(sizingMethod='auto expand', M11=1, M12=0, M21=0, M22=1)";
    zoom: 1;
}
```

#### 3. 给Nav添加动态事件

1. 当侧边栏收起来的时候，我们给`menu-left`加个`menu-small`的class
2. 当一级菜单`sub-menu-title`点击的时候，我们让它的二级菜单`nav-menu`展开，也就是给`sub-menu`加上`active`属性。

##### 3-1：侧边栏收起的时候加上menu-small

我们Nav组件是在Home.js中用到的，我们给Nav传递一个属性`collapsed`。  
如果`collapsed`是`true`表示侧边栏收起，我们导航菜单使用`menu-left menu-small`的样式;  
如果`collapsed`是`false`表示侧边栏展开，我们导航菜单使用`menu-left`的样式。

**第一步：在Home组件中Nav实例化时传递**`collapsed`**属性**

```js
<Nav collapsed={this.state.collapsed} />
```

**第二步：Nav中接收属性设置为自身状态**

```js
constructor(props){
    super(props);
    this.state = {
        collapsed: this.props.collapsed ? this.props.collapsed : false,
    }
}
```

在div中使用动态的className：

```js
<div className={this.state.collapsed ? "menu-left menu-small" : "menu-left"}>
```

**第三步：编写Nav的componentWillReceiveProps事件**

```js
componentWillReceiveProps(nextProps){
    if(this.props.collapsed !== nextProps.collapsed){
        this.setState({
            collapsed: nextProps.collapsed,
        });
    }
}
```

##### 3-2：给一级菜单动态添加active
1. 给Nav组件传递个`defaultOpenKey`
2. 在constructor中设置状态值`openSubMenuIndex`
3. 给一级菜单的标题添加`subMenuOnClick`事件
4. 动态设置`sub-menu`的`active`样式

```git
diff --git a/src/components/Base/Nav.js b/src/components/Base/Nav.js
index 41a7cc9..47fdf8a 100644
--- a/src/components/Base/Nav.js
+++ b/src/components/Base/Nav.js
@@ -12,21 +12,39 @@ export default class Nav extends React.Component {
         super(props);
         this.state = {
             collapsed: this.props.collapsed ? this.props.collapsed : false,
+            // 默认打开的一级菜单key
+            openSubMenuIndex: this.props.defaultOpenKey ? this.props.defaultOpenKey : null,
         }
+        this.subMenuOnClick = this.subMenuOnClick.bind(this);
     }

     componentWillReceiveProps(nextProps){
         if(this.props.collapsed !== nextProps.collapsed){
             this.setState({
                 collapsed: nextProps.collapsed,
+                openSubMenuIndex: nextProps.defaultOpenKey
+            });
+        }
+    }
+
+    subMenuOnClick(key) {
+        // 设置当前展开的subMenu
+        // console.log(key);
+        if(this.state.openSubMenuIndex === key){
+            this.setState({
+                openSubMenuIndex: null,
+            });
+        }else{
+            this.setState({
+                openSubMenuIndex: key,
             });
         }
     }
     render() {
         return (
             <div className={this.state.collapsed ? "menu-left menu-small" : "menu-left"}>
-                <div className="sub-menu" key="asset">
-                    <div className="sub-menu-title">
+                <div className={this.state.openSubMenuIndex === "asset" ? "sub-menu active" : "sub-menu"}  key="asset">
+                    <div className="sub-menu-title" onClick={() => this.subMenuOnClick("asset")}>
                         <Icon type="bank" />
                         <span className="title">一级导航1</span>
                     </div>
@@ -46,8 +64,8 @@ export default class Nav extends React.Component {
                     </ul>
                 </div>

-                <div className="sub-menu active" key="user">
-                    <div className="sub-menu-title">
+                <div className={this.state.openSubMenuIndex === "user" ? "sub-menu active" : "sub-menu"} key="user">
+                    <div className="sub-menu-title" onClick={() => this.subMenuOnClick("user")}>
                         <Icon type="bank" />
                         <span className="title">一级导航2</span>
                     </div>
diff --git a/src/components/Home.js b/src/components/Home.js
index 6a32a51..26457b6 100644
--- a/src/components/Home.js
+++ b/src/components/Home.js
@@ -56,7 +56,7 @@ const {Content, Sider} = Layout;
                         <div onClick={this.toggle.bind(this)} className="sider-toggle">
                             <Icon type={this.state.collapsed ? "menu-unfold" : "menu-fold"} />
                         </div>
-                        <Nav collapsed={this.state.collapsed} />
+                        <Nav collapsed={this.state.collapsed} defaultOpenKey="user" />
                     </Sider>
                     <Layout style={{maxHeight: "100vh", overflow: "auto"}}>
                         <Content className="container">
```

### 根据数据渲染Nav

#### nav-data.js

* `icon`：是导航菜单前面的图标
* `key`: 同级别需要是唯一的
* `title`: 导航条的标题
* `subs`: 一级菜单下面二级菜单列表

```js
var navData = [
    {icon: 'bank',key: 'asset',title: '资产',
        subs : [
            {slug: '/asset/group', icon: 'right', title: 'Group'},
            {slug: '/asset/host', icon: 'right', title: 'Host'},
            { slug: '/asset/domain', icon: 'right', title: 'Domain'}
        ]
    },
    {icon: 'tool', key: 'operation', title: '操作中心',
        subs : [
            {slug: '/operation/crontable', icon: 'right', title: '计划任务'},
            {slug: '/operation/execute', icon: 'right', title: '批量命令'},
            {slug: '/operation/file', icon: 'right', title: '文件上传下载'}
        ]
    },
    {
        icon: 'user', key: 'user', title: '用户中心',
        subs : [
            {slug: '/user/group', icon: 'usergroup-add', title: '分组'},
            {slug: '/user/login', icon: 'user', title: '登陆'},
            {slug: '/user/logout', icon: 'logout', title: '退出'}
        ]
    }
]
export default navData;
```

#### 渲染导航菜单
1. 先动态生成最外层的className
2. 根据双方收起/展开渲染不同的导航元素(收起的时候，标题改成提示框)


**1. 先引入navData,和Tooltip**

```js
import {
    Icon,
    Tooltip
} from 'antd';

import navData from './nav-data';
```

**2. 重写render函数**

```js
render() {
    // 先申明导航菜单元素，最外层的导航菜单class
    var navElements, navLeftClass;
    if(this.state.collapsed){
        // 当侧边栏收起的时候
        navLeftClass = "menu-left menu-small";
        // 根据navData渲染导航菜单元素
        navElements = navData.map((item, index) => {
            // 先生成二级menu元素
            var navMenuItems = item.subs.map((v, i) => {
                return (
                    <Tooltip title={v.title} placement="right" key={i}>
                        <li className="nav-menu-item">
                            <a href={v.slug}>
                                <Icon type={v.icon} />
                            </a>
                        </li>
                    </Tooltip>
                );
            });
            // 再生成一级菜单元素
            var subMenuClass = "sub-menu";
            if(this.state.openSubMenuIndex === item.key){
                subMenuClass = "sub-menu active";
            }
            // 返回一级菜单元素(内嵌二级菜单元素)
            return (
                <div className={subMenuClass} key={index}>
                    <Tooltip title={item.title} placement="right" overlayStyle={{opacity:1}}>
                        <div className="sub-menu-title" onClick={() => {this.subMenuOnClick(item.key)}}>
                            <Icon type={item.icon} />
                        </div>
                    </Tooltip>
                    {/*二级菜单列表  */}
                    <ul className="nav-menu">
                        {navMenuItems}
                    </ul>
                </div>
            );

        });
    }else{
        // 当侧边栏是展开的时候，不用Tooltip，而使用title了
        navLeftClass = "menu-left";
        navElements = navData.map((item, index) => {
            // 生成二级子菜单
            var navMenuItems = item.subs.map((v, i) => {
                return (
                    <li className="nav-menu-item" key={i}>
                        <a href={v.slug}>
                            <Icon type={v.icon} />
                            <span className="title">{v.title}</span>
                        </a>
                    </li>
                );
            });

            // 再生成一级菜单
            var subMenuClass = "sub-menu";
            if(this.state.openSubMenuIndex === item.key){
                // 当展开的菜单key  与当前菜单的key相同，加上active的class
                subMenuClass = "sub-menu active";
            }

            return (
                <div className={subMenuClass} key={index}>
                    <div className="sub-menu-title" onClick={() => this.subMenuOnClick(item.key)}>
                        <Icon type={item.icon} />
                        <span className="title">{item.title}</span>
                    </div>
                    {/*二级菜单  */}
                    <ul className="nav-menu">
                        {navMenuItems}
                    </ul>
                </div>
            );
        });
    }

    return (
        <div className={navLeftClass}>
            {navElements}
        </div>
    );
}
```
