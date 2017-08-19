## Ant Design之--布局

> 在设计网页时，首先要确定整体的布局结构。比如：`Header`,`Sider`,`Content`,`Footer`.

**注意事项:**

* 如果没设置按需加载，需要在js入口加入antd的css样式：`import 'antd/dist/antd.css';`
* 也可以在css中引入antd的样式：`@import '~antd/dist/antd.css';`
* 推荐设置antd按需加载

### 组件概述

> 下面说的组件都是`ant.design`的布局组件，可直接使用，但是一般需要做些自定义。

* `Layout`: 布局容器，其下可以嵌套`Header`,`Sider`,`Content`,`Footer`或`Layout`自身，layout可以放在任何父容器中。
* `Header`: 顶部布局，自带默认样式，其下可以嵌套任何元素，只能放在`Layout`中。
* `Sider`: 侧边栏，自带默认样式和基本功能，其下可嵌套任何元素，只能放在`Layout`中。
* `Content`: 内容部分，自带默认样式，其下可嵌套仍和元素，只能放在`Layout`中。
* `Footer`: 底部布局，自带默认样式，其下可嵌套仍和元素，只能放在`Layout`中。

#### Layout
布局容器

| 参数 | 说明 | 类型 | 默认值 |
| --- | --- | --- |  --- |
| style | 指定样式 | object | - |
| className | 容器className | string | - |

> 注意：其布局，使用的是flex实现的，老的浏览器不兼容。

### 网站布局

引入模块：

```js
import {
    Layout,
} from 'antd';

// 引入css的样式
import 'antd/dist/antd.css';

const {Content, Sider} = Layout;
```

#### 布局效果

![](/assets/front/ant_design_layout_simple.png)

#### 简单布局

> 网站布局的骨架，上下两块：上：Header；下：左边的Sider + 右边的【Content + Footer】

文件Home.js：`src/components/Home.js`

```js
 export default class Home extends React.Component {
     render() {
         return (
            <Layout>
                <Layout.Header>
                    头部内容
                </Layout.Header>
                <Layout>
                    <Sider>
                        Side
                    </Sider>
                    <Layout>
                        <Content> 
                            右侧内容
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

#### 固定Header和Sider布局

> 让头部和左边的侧边栏，固定。右边的主题内容部分，滑动的时候，Header和Sider不滑动，且整体高度为100%.

```js
 export default class Home extends React.Component {
     render() {
         return (
            <Layout style={{ height: "100vh", overflow: 'auto'}}>
                <Layout.Header>
                    头部内容
                </Layout.Header>
                <Layout>
                    <Sider style={{backgroundColor: '#ccc'}}>
                        <p style={{height: 500}}>Side</p>
                    </Sider>
                    <Layout style={{maxHeight: "100vh", overflow: "auto"}}>
                        <Content>
                            <p style={{height: 400, backgroundColor: '#fff'}}>右侧内容</p>
                            <p style={{height: 400, backgroundColor: '#EEE'}}>右侧内容</p>
                            <p style={{height: 400, backgroundColor: '#FFF'}}>右侧内容</p>
                            <p style={{height: 400, backgroundColor: '#444'}}>右侧内容</p>
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

#### 右侧Content布局

> 网页内容，主要是显示在右侧的Content中。  
> 我们为Content设置个css选择器`container`, 然后网页主题内容放在container中。  
> `container`中有`div.content`,`content`中有上面的面包屑导航`div.nav`和下面的主题内容区`div.main`。

**1. 编写Detail.js内容**

示例：`src/components/User/Detail.js`

```js
import React from 'react';

import {
    Breadcrumb
} from 'antd';

export default class UserDetail extends React.Component {
    render() {
        return (
            <div className="content">
                {/*面包屑开始  */}
                <Breadcrumb className="nav">
                    <Breadcrumb.Item>
                        <a href="/">首页</a>
                    </Breadcrumb.Item>
                    <Breadcrumb.Item>
                        <a href="/user/list">用户列表</a>
                    </Breadcrumb.Item>
                    <Breadcrumb.Item>详情页</Breadcrumb.Item>
                </Breadcrumb>
                {/*面包屑 end  */}

                <div className="main">
                    <p>右侧内容</p>
                    <p style={{height: 400, backgroundColor: '#FFF'}}>右侧内容</p>
                    <p style={{height: 400, backgroundColor: '#EEE'}}>右侧内容</p>
                    <p style={{height: 400, backgroundColor: '#444'}}>右侧内容</p>
                </div>
            </div>
        );
    }
}
```

* 给Breadcrumb添加了`nav`样式
* UserDetail最外层的div添加`content`样式
* 主要内容是放在content里面的`div.main`中间
* 在`React.js`中给元素添加`class`要使用`className`赋值.

**2. 添加样式文件Base.css**

文件：`src/styles/Base.css`

```css
.container {
    /*设置右侧主体布局内容样式  */
    font-size: 14px;
}

.container .content {
    /*右侧内容样式  */
    background-color: #FFF;
}

.container .content .nav{
    /*右侧内容 顶部的导航  */
    padding: 10px 20px;
    background-color: #eee;
}

.container .content .main {
    /*右侧内容 主体内容区样式  */
    padding: 10px 20px;
}
```

**3. 修改Home.js**

把`UserDetail`组件渲染到`Home.js`的`Content`中。

```git
diff --git a/src/components/Home.js b/src/components/Home.js

--- a/src/components/Home.js
+++ b/src/components/Home.js
@@ -2,13 +2,16 @@
  * 布局Home页面
  */

+import UserDetail from './User/Detail';
+import '../styles/Base.css';
+
 const {Content, Sider} = Layout;

  export default class Home extends React.Component {
@@ -23,11 +26,8 @@ const {Content, Sider} = Layout;
                         <p style={{height: 500}}>Side</p>
                     </Sider>
                     <Layout style={{maxHeight: "100vh", overflow: "auto"}}>
-                        <Content>
-                            <p style={{height: 400, backgroundColor: '#fff'}}>右侧内容</p>
-                            <p style={{height: 400, backgroundColor: '#EEE'}}>右侧内容</p>
-                            <p style={{height: 400, backgroundColor: '#FFF'}}>右侧内容</p>
-                            <p style={{height: 400, backgroundColor: '#444'}}>右侧内容</p>
+                        <Content className="container">
+                            <UserDetail />
                         </Content>
                         <Layout.Footer>
```