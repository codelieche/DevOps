## 表单数据校验

> Ant Design的Form组件中的数据校验应用到了[async-validator](https://github.com/yiminghe/async-validator)

### Ant Design Form简单使用

```js
import React from 'react';
import '../../styles/scss/user.scss';
import {
    Form,
    Icon,
    Input,
    Button,
} from 'antd';
const FormItem = Form.Item;

class Login extends React.Component {
    handleSubmit = (e) => {
        e.preventDefault();
        this.props.form.validateFields((err, values) => {
        if (!err) {
            // POST登陆账号
            // ....  
        });
    }

    render() {
        const { getFieldDecorator } = this.props.form;
        return (
            <Form onSubmit={this.handleSubmit} className="login-form">
                <FormItem>
                    {getFieldDecorator('username', {
                        rules: [{ required: true, message: 'Please input your username!' }],
                    })(
                        <Input prefix={<Icon type="user" />} placeholder="Username" />
                    )}
                </FormItem>
                <FormItem>
                    {getFieldDecorator('password', {
                        rules: [{ required: true, message: 'Please input your Password!' }],
                    })(
                        <Input prefix={<Icon type="lock" />} size='large' type="password" placeholder="Password" />
                    )}
                </FormItem>
                <FormItem>
                  <Button type="primary" htmlType="submit" >Log in</Button>
                </FormItem>
            </Form>
        );
    }
}
Login = Form.create()(Login);
export default Login;
```

#### 重点操作

* 首先编写好Login,然后再用`Form.create())Login)`重新封装了下
* render中重点用到了： `getFieldDecorator`来对规则的处理

#### getFieldDecorator

> 在render中先使用这个：

```js
const { getFieldDecorator } = this.props.form;
```

> 设置Form.Item

```js
<Form.Item>
    {getFieldDecorator('username', {
         rules: [{ required: true, message: 'Please input your username!' }],
    })(
        <Input prefix={<Icon type="user" style={{ fontSize: 16 }} />} placeholder="Username" />
    )}
</Form.Item>
```

> 其中可以设置`valuePropName`、`initialValue`、`trigger`、`rules`等，重点就是设置rules。

### 字段规则

#### Type

* `string`: 【默认】
* `number`: 数字
* `boolean`:
* `method`: 内容必须是个function
* `regexp`: 内容需要是一个正则的对象
* `integer`:
* `float`:
* `array`:
* `enum`: 枚举类型，结合`enum: ['a', 'b', 'c']`
* `date`:
* `url`:
* `hex`:
* `email`:
  > 其中常用的是`string`,`number`,`email`,`date`,`url`,`enum`.

#### Required

表单中这个字段是否必须填写

#### Message

提示信息

#### Pattern

填写正则判断，比如设置用户名是abc开头的

```js
rules: [{required: true, message: 'Please input group name!', pattern: /^abc.*?$/}],
```

#### Length

* `len`: 指定长度，太长或者少了都会通不过验证
* `min`: 最低长度
* `max`: 最大长度
  > 比如：password字段，长度为8-12。

```js
rules: [{required: true, message: 'Please input password!', min: 8, max: 12}],
```

#### Enumerable

> 有时候这个字段我们要限定内容，比如：设置type字段为`host`,`domain`,`other`.其它的值不通过。

```js
getFieldDecorator('type', {
        initialValue: 'other',
        rules: [{required: true, message: 'Please choices type!', type: 'enum', enum: ['host', 'domain', 'other']}],
    })(
        <Select>
            <Select.Option value="host">主机</Select.Option>
            <Select.Option value="domain">域名</Select.Option>
            <Select.Option value="other">其它</Select.Option>
        </Select>
)}
```

#### 编写多个规则

> 在getFieldDecorator中的rules是个数组，不同规则可以设置不同的提示消息。

```js
{getFieldDecorator('name', {
    initialValue: 'name',
    rules: [
       {required: true, message: 'Please input group name!'},
       {message: '最大长度是40', max: 40},
       {message: '名字需要全部是小写字母!', pattern: /^[a-z]+$/}],
    })(
    <Input placeholder="name" />
)}
```



