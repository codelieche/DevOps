## React Router Link传递数据

### 传递params
> 通过url传递参数。

- 首先要导入Link和Route

```js
import {
    Route,
    Link,
} from 'react-router-dom';
```

- 使用Link

 ```
 <Link to="/asset/group/75">Detail</Link>
 ``` 
 
 - 配置路由
 
 ```
 <Route exat path='/asset/group/:id' component={GroupDetail} />
 ```
 
 - 在GroupDetail中接收id
 
 ```js
 class GroupDetail extends React.Component {
    constructor(props) {
        super(props);
        // 获取相应的详情数据：
        this.state = {
            groupId: this.props.match.params.id,
        }
    }
}
 ```
 
 ### 传递state
 
 - 设置Link的location
 
 ```
 <Link to={{pathname: "/asset/group/75", state:{data: "传递数据"}}}>Detail</Link>
 ```
 
 - 接收数据
 > 还是在响应的组件中接收数据。  
 注意：通过Link传递过的state，是在`this.props.location.state`中。
 
 ```js
 componentDidMount() {
    if(this.props.location.state){
        this.setState({
            groupDetail: this.props.location.state.data,
        });
    }
}
```

 
 