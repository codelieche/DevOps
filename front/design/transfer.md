## 穿梭框的使用
> 表单中要传递列表，比如，创建用户分组，需要勾选部分用户，或者编辑分组的时候，需要删除一些用户。  
这个时候就可以使用穿梭框，左边是所有用户列表，右边是分组的用户列表。  
左右穿梭，修改分组的用户列表数据。



### GroupForm
文件：`src/components/User/group/Form.js`

```js
/**
 * 用户组 表单Form
 * 需要传递属性（props）
 * 1. data：编辑页会传过来obj
 * 2. type：editor 或者 add，根据这个来确定GroupForm
 */

 import React from 'react';
 import {
     Button,
     Form,
     Input,
     Row,
     Col,
     Transfer
 } from 'antd';

 function hasErrors(fieldsError) {
    //  console.log(fieldsError);
    // console.log(Object.keys(fieldsError).some(field => fieldsError[field]));
    return Object.keys(fieldsError).some(field => fieldsError['field']);
 }

 class BaseForm extends React.Component {
     constructor(props) {
         super(props);
        //  先处理传递过来的data
         var data = this.props.data ? this.props.data: {};
         this.state = {
             sourceData: [],
             data: data,
             transferDataSource: [],
            //  穿梭框选中的key和目标keys
             selectedKeys: [],
            //  右边表单中Target选中的keys
            targetKeys: data.user_set ? data.user_set : []
         }
     }
    
     componentWillMount() {
        //  获取所有用户的列表
        this.fetchAllUserData();
     }

     componentWillReceiveProps(nextProps) {
         // 由于最开始的editor页面穿过来的data是空，后面editro页面重新获取了group数据，重新传递过来
         if(nextProps.data !== this.props.data){
             this.setState({
                 //group的数据
                 data: nextProps.data,
                 // 选中的user数据
                 targetKeys: nextProps.data.user_set
               }
             )
         }
     }

     handleSubmit = (e) => {
         // 提交表单的处理函数
         // Form表单实例化的时候会传递handleSubmit,实际的操作都是调用它的
         // 主要是：editor或add操作
         e.preventDefault();
         this.props.form.validateFields((err, values) => {
             if(!err) {
                 this.props.handleSubmit(values);
             }
         });
     }
     
     fetchAllUserData() {
         // 获取所有用户列表
         const url = 'http://127.0.0.1:8080/api/1.0/account/user/list';
         fetch(url, {credentials: 'include'})
           .then(response => response.json())
             .then(data => {
                 if(data instanceof Array){
                     // 获取的数据是数组才ok
                     this.userall = data;
                     // 生成穿梭框左边的源数据[{key: id, title: username}]
                     let transferDataSource = data.map(item => ({
                         key: item.id,
                         title: item.username
                     }));
                    // 修改状态：设置穿梭框源数据和选中的key的值
                    this.setState({
                        transferDataSource: transferDataSource,
                    });
                 }
             })
              .catch(err => {
                  console.log(err);
              });
        // fetch end
     }

     // 穿梭框
     handleTransferSelectChange = (sourceSelectedKeys, targetSelectedKeys) => {
         // 处理穿梭框选中item的操作
         // 当鼠标点击穿梭框的内容的时候，需要修改下选中的key的列表的值
         this.setState({
             selectedKeys: [...sourceSelectedKeys, ...targetSelectedKeys]
         });
     }

     handleTransferChange = (nextTargetkeys, direction, moveKeys) => {
         // 处理穿梭框左右穿梭的函数
         // 把左边移动到邮编，右边移到左右的时候，主要就是改变右边的targetKeys的值
         this.setState({targetKeys: nextTargetkeys});
     }

     render() {
         // Button提交按钮的名字
         const buttonTitle = this.props.type === 'editor' ? '修改' : '添加';
         // Form的一些内建函数
         const {getFieldDecorator, getFieldsError, getFieldError, isFieldTouched } = this.props.form;
         // Only Show error after a field is touched
         const nameError = isFieldTouched('name') && getFieldError('name');

         // 左侧表单Item的布局设置
         const formItemLayout = {
             labelCol: {
                 xs: {span: 24},
                 sm: {span: 5},
                 md: {span: 5}
             },
            wrapperCol: {
                xs: {span: 24},
                sm: {span: 15},
                md: {span: 14},
            }
         };
        // 穿梭框布局设置
        const transferItemLayout = {
            labelCol: {
                xs: { span: 24 },
                sm: { span: 0 },
                md: { span: 0 },
            },
            wrapperCol: {
                xs: { span: 24, offset: 0 },
                // 注意：sm尺寸设置了偏移，md尺寸的时候默认也会偏移
                sm: { span: 18, offset: 3 },
                md: { span: 16, offset: 4 },
            },
        };

        return (
            <Form onSubmit={this.handleSubmit}>
                <Row>
                    <Col xs={24} sm={24} md={24}>
                        <Form.Item
                          {...formItemLayout}
                          validateStatus={nameError ? 'error' : ''}
                          help={nameError || ''}
                          label='name'
                        >
                            {getFieldDecorator('name',{
                                initialValue: this.state.data.name,
                                rules: [
                                   {required: true, message: 'Please input group name!'}, 
                                ]
                            })(
                                <Input placeholder="name" />
                            )}
                        </Form.Item>
                        <Form.Item
                          {...transferItemLayout}
                        >
                        {getFieldDecorator('user_set', {
                            initialValue: this.state.data.user_set ? this.state.data.user_set : [],
                        })(
                            <Transfer
                                listStyle={{
                                    maxWidth: 300,
                                    width: '43%',
                                    minHeight: 250,
                                    overflow: 'auto',
                                }}
                                dataSource={this.state.transferDataSource}
                                targetKeys={this.state.targetKeys}
                                selectedKeys={this.state.selectedKeys}
                                onChange={this.handleTransferChange}
                                onSelectChange={this.handleTransferSelectChange}
                                titles={['所有用户', '组成员']}
                                showSearch
                                render={item => item.title}
                            />
                        )}
                    </Form.Item>
                    </Col>
                </Row>
                <Row className="center">
                <Form.Item >
                    <Button
                      type='primary'
                      htmlType="submit"
                      disabled={hasErrors(getFieldsError())}
                    >{buttonTitle}</Button>
                </Form.Item>
                </Row>
            </Form>
        );
     }

 }

 export default Form.create()(BaseForm);
 ```