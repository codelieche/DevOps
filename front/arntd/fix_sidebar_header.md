## 固定侧边栏和头部布局

### 代码
> 文件：`src/components/Home.js`.

```js
import React from 'react';

import {
    Layout,
    Icon,
} from 'antd';
import {
    Route,
} from 'react-router-dom';

import Header from './Base/Header';
import Nav from './Base/Nav';
import Footer from './Base/Footer';

import AssetIndex from './Asset/Index';
import HostList from './Asset/Host/List';

import CheckLogined from './Utils/auth';

const {Sider, Content} = Layout;

export default class Home extends React.Component {
    constructor(props){
        super(props);
        this.state = {
            collapsed: false,
        };
        console.log(this.props);
    }
    componentWillMount(){
        // 组件将要mount前先检查下用户是否登陆了
        if(this.props.history.action === "PUSH"){
            // 不需要检查是否登陆
        }else{
            CheckLogined(this.props);
        }
    }
    toggle = () => {
        this.setState(prevState => ({
            collapsed: !prevState.collapsed,
            defaultOpenKey: this.props.defaultOpenKey ? this.props.defaultOpenKey : null,
        }));
    }
    onCollapse = (collapsed) => {
        this.setState({ collapsed });
    }
    render() {
        return (
            <Layout style={{ height: '100vh', overflow: 'auto' }}>
                <Layout.Header className="header">
                    <Header/>
                </Layout.Header>
                <Layout>
                    <Sider
                        trigger={null}
                        collapsible 
                        collapsed={this.state.collapsed}
                        onCollapse={this.onCollapse}
                        className="sider"
                        breakpoint="sm"
                    >
                        <div onClick={this.toggle.bind(this)} className="sider-toggle">
                            <Icon type={this.state.collapsed ? "menu-unfold":"menu-fold"} />
                        </div>
                        <Nav collapsed={this.state.collapsed} defaultOpenKey={this.props.defaultOpenKey} />
                    </Sider>
                    <Layout style={{ maxHeight: '100vh', overflow: 'auto' }}>
                        <Content className="container">
                            <Route path='/asset' component={AssetIndex} location={this.props.location}/>
                            <Route path="/asset/host/list"  component={HostList} />
                        </Content>
                        <Layout.Footer>
                            <Footer />
                        </Layout.Footer>
                    </Layout>
                </Layout>
            </Layout>
        );
    }
}
```

### 重点说明
- 设置最外层布局的样式

```
<Layout style={{ height: '100vh', overflow: 'auto' }}>
```

- 设置右侧主体内容布局的样式

```
<Layout style={{ maxHeight: '100vh', overflow: 'auto' }}>
```

