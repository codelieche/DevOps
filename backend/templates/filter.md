## Django模版过滤器

> Django模版中有很多过滤器，可以直接使用

### 常用的过滤器

- `safe`:标记字符串为安全的，不需要转译html标签字符 
- `escape`: 把字符串中的HTML标签变成显示用的字符串(也就是转译了)
- `wordcount`: 计算字数 
- `date`: 设置日期的显示格式 
- `default`: 如果没有值，就使用默认值 
- `default_if_none`: 如果值为None设置默认值 
- `center、ljust、rjust`: 为字符串内容加上指定空格后：居中,左,右对齐 
- `capfirst`: 为字符串首字母大写 
- `length`: 返回列表数据的长度 
- `length_is`: 判断数据是否为指定长度 
- `first`: 只去列表数据中的第一个 
- `last`: 去列表数据中的最后一个 
