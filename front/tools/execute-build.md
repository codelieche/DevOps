## 执行打包操作
> 前端代码写好后需要打包到后端项目。并且替换其中的js。

### 手工操作步骤
1. 进入前端项目代码目录：`cd /data/www/front`
2. 查看下以前老的js文件: `ls ./build/static/js`
3. 执行构建命令：`yarn run build`
4. 查看新的js文件：`ls ./build/static/js`
5. 用sed替换url：`gsed -i 's/http:\/\/127.0.0.1:8080\//\//g`
6. 删除后端中老的js文件：`rm /data/www/backend/static/js/main.old.js`
7. 把新的js文件复制到后端: `cp ./build/static/js/main.new.js /data/www/backend/static/js/`
8. 把后端中模板引用的js替换掉：
```bash
gsed -i 's/main.old.js/main.new.js/g' /data/www/backend/templates/index.html
```

### 脚本
**文件名：**`run-build.sh`

```bash
#!/bin/bash
echo "构建js，然后替换js文件开始执行"

# 前端项目  和 后端项目 
FRONT_CODE_DIR='/data/www/front/'
BACKEND_CODE_DIR='/data/www/backend'

# 进入前端项目根目录
cd $FRONT_CODE_DIR

# 获取到老的js文件
OLD_JS_FILE=`ls build/static/js | egrep "main.*js$"`
echo "    老的js文件：" $OLD_JS_FILE
# 执行构建和替换url
npm run build && gsed -i 's/http:\/\/127.0.0.1:8080\//\//g' build/static/js/main*js

# 获取到新的js文件
NEW_JS_FILE=`ls build/static/js | egrep "main.*js$"`
echo "    新的js文件: " $NEW_JS_FILE

# 删除后端老的js文件
rm -rf "${BACKEND_CODE_DIR}/static/js/${OLD_JS_FILE}" && echo "    删除老的js文件成功"
# 复制新的js到后端
cp -rf "build/static/js/${NEW_JS_FILE}" ${BACKEND_CODE_DIR}/static/js/ && echo "    复制新的文件成功"

# 替换index.html中的js文件
params="s/${OLD_JS_FILE}/${NEW_JS_FILE}/g"
echo "    替换参数：${params}"
gsed -i $params ${BACKEND_CODE_DIR}/templates/index.html && echo "执行sed替换：${params}成功" || echo "替换失败"
echo "执行完毕！"
```

给脚本添加执行权限：`chmod +x ./run-build.sh`

**执行：**

```
(env_devops) ➜  source git:(develop) ./run-build.sh
构建js，然后替换js文件开始执行
    老的js文件： main.f62d2034.js
    新的js文件:  main.65364ec2.js
    删除老的js文件成功
    复制新的文件成功
    替换参数：s/main.f62d2034.js/main.65364ec2.js/g
执行sed替换：s/main.f62d2034.js/main.65364ec2.js/g成功
```
