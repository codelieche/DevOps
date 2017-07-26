## React Router Link传递数据

### 传递params

> 通过url传递参数。

* 首先要导入Link和Route

```js
import {
    Route,
    Link,
} from 'react-router-dom';
```

* 使用Link

  ```
  <Link to="/asset/group/75">Detail</Link>
  ```

  * 配置路由

  `<Route exat path='/asset/group/:id' component={GroupDetail} />`
 

  * 在GroupDetail中接收id

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

  * 设置Link的location


 ```html
 <Link to=`{``{`pathname: "/asset/group/75", state:{data: "传递数据"}}}>Detail</Link>
 ```

  * 接收数据
    > 还是在响应的组件中接收数据。  
    > 注意：通过Link传递过的state，是在`this.props.location.state`中。

  ```js
  componentDidMount() {
    if(this.props.location.state){
        this.setState({
            groupDetail: this.props.location.state.data,
        });
    }
  }
  ```

### 传递search

> Link传递search参数：

```js
<Link to={{
  pathname: '/user/login',
  search: '?next=/asset/group/next',
  state: { data: "传递数据" }
}}/>
```

> 或者使用react的props.history.push跳转页面。

```js
 export function CheckLogined({history,match, location}) {
    // 首先get访问，判断是否成功登陆了
    // 如果登陆了的，就返回true，没登陆的话就跳转到/user/login页面
    const url = "http://127.0.0.1:8080/api/1.0/account/login";
    fetch(url, {credentials: 'include'})
      .then(response => response.json())
        .then(data => {
            if(data.logined){
                return true;
            }else{
                history.push("/user/login?next=" + location.pathname);
            }
        });
 }
```

> 获取search数据

```js
if(data.status === 'success'){
    // 获取next的url
    // 首先获取search参数：?next=/
    const params = new URLSearchParams(this.props.location.search);
    // 获取next的值
    let next = params.get("next");
    // 如果next为null或者next为/user/login那么就跳转去首页
    if(!next || next === "/user/login"){next = "/"}
    // 跳转去首页
        this.props.history.push(next);
    }
})
```



