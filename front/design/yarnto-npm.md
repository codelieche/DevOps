## 设置Ant Design按需加载

### 创建项目

先要安装好`create-react-app`和`yarn`

```
$ npm install -g create-react-app yarn
```
创建项目：

```
$ create-react-app devops
```
进入项目添加所要的包：

```
$ yarn add react-router-dom
$ yarn add antd
$ yarn start
```

#### package.json

```json
{
  "name": "devops",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "antd": "^2.11.2",
    "react": "^15.6.1",
    "react-dom": "^15.6.1",
    "react-router-dom": "^4.1.1"
  },
  "devDependencies": {
    "react-scripts": "1.0.10"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test --env=jsdom",
    "eject": "react-scripts eject"
  }
}
```

### 设置antd为按需加载
首先我们使用`eject`命令把内建的配置暴露出来。

```
$ yarn run eject
```

#### 使用babel-pugin-import
> babel-plugin-import 是一个用于按需加载组件代码和样式的 babel 插件.

```
$ yarn add babel-plugin-import --dev
```
修改配置：`config/webpack.config.dev.js`:

```
--- a/config/webpack.config.dev.js
+++ b/config/webpack.config.dev.js
@@ -167,6 +167,10 @@ module.exports = {
         include: paths.appSrc,
         loader: require.resolve('babel-loader'),
         options: {
+          // 添加babel-plugin-import添加配置
+          plugins: [
+            ['import', {libraryName: 'antd', style: 'css'}],
+          ],

           // This is a feature of `babel-loader` for webpack (not Babel itself).
           // It enables caching results in ./node_modules/.cache/babel-loader/
          // directory for faster rebuilds.
          cacheDirectory: true,
        },
      },
```
> 注意，由于 create-react-app eject 之后的配置中没有 .babelrc 文件，所以需要把配置放到 webpack.config.js 或 package.json 的 babel 属性中。



