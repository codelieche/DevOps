## react-app-rewired
> 一个对 create-react-app 进行自定义配置的社区解决方案


### 参考文档
- [react-app-rewired](https://github.com/timarney/react-app-rewired)

### 设置antd按需加载

#### 1. 引入react-app-rewired并修改package.json里的启动配置。

```shell
$ yarn add react-app-rewired --dev
```

**修改package里面的scripts命令：**

```git
/* package.json */
"scripts": {
-   "start": "react-scripts start",
+   "start": "react-app-rewired start",
-   "build": "react-scripts build",
+   "build": "react-app-rewired build",
-   "test": "react-scripts test --env=jsdom",
+   "test": "react-app-rewired test --env=jsdom",
}
```

**package.json文件内容：**

```json
{
  "name": "opsfront",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^16.2.0",
    "react-dom": "^16.2.0",
    "react-scripts": "1.0.17"
  },
  "scripts": {
    "start": "react-app-rewired start",
    "build": "react-app-rewired build",
    "test": "react-app-rewired test --env=jsdom",
    "eject": "react-scripts eject"
  },
  "devDependencies": {
    "react-app-rewired": "^1.3.8"
  }
}
```

**创建config-overrides.js**

```js
module.exports = function override(config, env) {
  // do stuff with the webpack config...
  return config;
};
```

#### 2. 使用babel-plugin-import

[babel-plugin-import](https://github.com/ant-design/babel-plugin-import) 是一个用于按需加载组件代码和样式的 babel 插件，现在我们尝试安装它并修改 config-overrides.js 文件。

```
$ yarn add babel-plugin-import --dev
```

```git
+ const { injectBabelPlugin } = require('react-app-rewired');

  module.exports = function override(config, env) {
+   config = injectBabelPlugin(['import', { libraryName: 'antd', libraryDirectory: 'es', style: 'css' }], config);
    return config;
  };
```

#### 3. 使用react-app-rewire-less
> antd官方的样式用的less，而不是sass。但是其写法差不多的，如果想让组件中引入scss的文件，需要用到`sass-loader`，`node-sass`。推荐按照官方的，直接使用less来编写自定义的样式代码。  
antd是支持定制主题的，具体可以查看[customize-theme-cn](https://ant.design/docs/react/customize-theme-cn)

```git
 const { injectBabelPlugin } = require('react-app-rewired');
+ const rewireLess = require('react-app-rewire-less');

  module.exports = function override(config, env) {
-   config = injectBabelPlugin(['import', { libraryName: 'antd', style: 'css' }], config);
+   config = injectBabelPlugin(['import', { libraryName: 'antd', style: true }], config);
+   config = rewireLess.withLoaderOptions({
+     modifyVars: { "@primary-color": "#1DA57A" },
+   })(config, env);
    return config;
  };
```

**config-overrides.js配置改为：**

```js
 const { injectBabelPlugin } = require('react-app-rewired');
const rewireLess = require('react-app-rewire-less');

module.exports = function override(config, env) {
    // do stuff with the webpack config...
    // config = injectBabelPlugin(['import', { libraryName: 'antd', libraryDirectory: 'es', style: true }], config);
    config = injectBabelPlugin(['import', { libraryName: 'antd', style: true }], config);

    config = rewireLess.withLoaderOptions({
        // 修改antd的主色调：antd2.x->3.0: 组件主色由 『#108EE9』 改为 『#1890FF』
        modifyVars: { "@primary-color": "#108EE9" },
    })(config, env);

    return config;
  };
``` 

配置到这里，就可以使用`yarn run start`来运行项目了。



