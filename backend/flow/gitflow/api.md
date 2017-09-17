## git工作流--api

### api列表

#### Step相关api
- `/api/1.0/flow/step/create`: POST添加步骤api
    1. `name`: 步骤名
    2. `group`: 这个步骤可以审批的组(name字段，不是id)
    3. `users`: Account.models.User的username字段，列表
    4. `order`: 步骤序号
    
- `/api/1.0/flow/step/1`: GET获取步骤的详情
- `/api/1.0/flow/step/1`: PUT修改步骤对象，参数与POST创建相同

#### Git代码提交api
- `/api/1.0/flow/job/gitjob`: GET获取gitjob的详情
- `/api/1.0/flow/job/gitjob`: PUT修改gitjob，主要是修改name和steps
    - 参数：`slug`: GitJob的slug字段
    - `name`: GitJob的name字段
    - `steps`: 步骤
    - `ordered`: 是否有序true / false
    

#### Approve
- `/api/1.0/flow/gitflow/approve/1`: PUT审批    
