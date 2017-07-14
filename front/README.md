## 前端开发

### 技术栈

* 前端框架: [React.js](https://facebook.github.io/react/)
* UI库：[ant design](https://ant.design/docs/react/introduce-cn)

## 基本使用
### 环境准备
- `Node.js`:[https://nodejs.org/](https://nodejs.org/)
- `npm`:
- `yarn`: `sudo npm install -g yarn`
- `create-react-app`:通过`sudo npm install -g create-react-app`安装


开发环境版本：
```
✗ node --version
v8.1.1
✗ npm --version
5.0.3
✗ create-react-app --version
1.3.1
```

### 基本命令
> 进入项目后，就可以执行命令了
- `yarn install`: 安装package.json中需要的包【请一定使用yarn安装】
- `yarn start`: 启动项目，默认启动服务：`http://localhost:3000/`（端口被占用，会+1）
- `npm run build`或者`yarn run build`: 创建打包后的js代码文件，文件位置：`./build`中
- `build`中注意，其中的配置:`config/webpack.config.prod.js`

### 创建项目
创建项目只需要传入目录名即可：`create-react-app OpsMindFront`