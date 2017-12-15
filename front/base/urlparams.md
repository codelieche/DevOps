## URLSearchParams

### 基本使用
> 打开浏览器在开发者工具中直接使用。

```js
var url = '?next=/user/info&q=search'
var p = new URLSearchParams(url)

p.get('next')
// /user/info
p.get('q')
// search
```

### 写个自定义的URLSearchParams
> 由于在一些老的浏览器中，不支持URLSearchParams功能，所以需要自己写一个。

**UrlParam.js**

```js
/**
 * URL Params处理
 * URLSearchParams只有新的浏览器才支持，所以需要自己写一个
 * 这样可以做到浏览器的兼容
 */

class SelfURLSearchParams {
    constructor(url){
        this.url = url;
        this.params = this.parse(url);
    }

    get =  (key) => {
        return this.params[key];
    }

    set = (key, value) => {
        this.params[key] = value;
    }

    parse = (str) => {
        if (typeof str !== 'string') {
          return {};
        }

        // 如果字符串是以？开头的，那么我们需要处理下
        if(str[0] === '?'){
            str = str.slice(1,);
        }

        return decodeURI(str).split('&').map(param => {
          const tmp = param.split('=');
          const key = tmp[0];
          let value = tmp[1] || true;
          if (typeof value === 'string' && isNaN(Number(value)) === false) {
            value = Number(value);
          }
          // 这里返回的是map函数的返回
          return { key, value };
        }).reduce((params, item) => {
            // map函数返回了一个数组，然后用reuce来处理
            // 最开始params是个空对象{}
            const { key, value } = item;
            if (typeof params[key] === 'undefined') {
                params[key] = value;
            }else {
                // 如果某个key传了多次，那么其value将会是个数组
                params[key] = Array.isArray(params[key]) ? params[key] : [params[key]];
                params[key].push(value);
            }
          // parse函数的返回结果
          return params;
        }, {});
      }

}

var URLSearchParamsClass = SelfURLSearchParams;
if(window.URLSearchParams){
    // URLSearchParamsClass = URLSearchParams;
    console.log("浏览器支持:URLSearchParams");
    console.log(window.URLSearchParams);
}else{
    console.log("浏览器不支持URLSearchParams");
}

export default URLSearchParamsClass;
```

### 参考文档
- [URLSearchParams](https://developer.mozilla.org/zh-CN/docs/Web/API/URLSearchParams)