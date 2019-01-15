## JavaScript前端导入excel文件数据

> 前端通过input选择文件，然后把excel文档里面的数据读取出来，转换成json数据。

### 安装xlsx

- `yarn add xlsx`

### 示例

- html

  ```html
  <div>
      <span>导入</span>
      <input type="file" style={{paddingLeft: 10}}
             onChange={(e) => this.handleImportFile(e.target.files, this)}>
      </input>
  </div>
  ```

- React组件中的handleImportFile方法

  ```js
  handleImportFile = (files, that) => {
          // console.log(files);
          // console.log(that);
          if(!files){
              return
          }
  
          var fileReader = new FileReader();
          var fileName = files[0].name;
  
          fileReader.onload = function(event) {
              // console.log(event);
              try {
                  var data = event.target.result,
                  // 以二进制流方式读取得到整份excel表格对象
                  workbook = XLSX.read(data, {type: 'binary'}),
                  // 存储获取到的数据
                  dataList = [];
              }catch(e){
                  console.log(e);
                  message.error('读取文件失败：' + fileName, 5);
                  return;
              }
              for(var sheet in workbook.Sheets){
                  // console.log(sheet) // 导入sheet的名称，一般就是一个
                  if( workbook.Sheets.hasOwnProperty(sheet)) {
                      
                      dataList = dataList.concat(
                          XLSX.utils.sheet_to_json(workbook.Sheets[sheet]));
                      // console.log(dataList);
                      break; // 如果不止导入一个表格，就注释这行
                  }
              };
              // 判断下传入的值是否正确：
              if ( dataList.length < 1){
                  message.error("传入的数据为空", 5);
                  return;
              };
  
              // 设置导入组件的状态
              that.setState({
                  dataList: dataList, 
                  addTimes: dataList.length});
          }
          fileReader.readAsBinaryString(files[0]);
      }
  ```

- **完整示例：**

```js
/**
 * 导入excel文件示例
 */
import React, {Component} from "react";
import { message } from "antd";
import XLSX from "xlsx";


class ImportExcelFile extends Component{
    constructor(props){
        super(props);
        this.state = {
            dataList: []
        }
    }

    handleImportFile = (files, that) => {
        // console.log(files);
        // console.log(that);
        if(!files){
            return
        }

        var fileReader = new FileReader();
        var fileName = files[0].name;

        fileReader.onload = function(event) {
            // console.log(event);
            try {
                var data = event.target.result,
                // 以二进制流方式读取得到整份excel表格对象
                workbook = XLSX.read(data, {type: 'binary'}),
                // 存储获取到的数据
                dataList = [];
            }catch(e){
                console.log(e);
                message.error('读取文件失败：' + fileName, 5);
                return;
            }
            for(var sheet in workbook.Sheets){
                // console.log(sheet) // 导入sheet的名称，一般就是一个
                if( workbook.Sheets.hasOwnProperty(sheet)) {
                    
                    dataList = dataList.concat(
                        XLSX.utils.sheet_to_json(workbook.Sheets[sheet]));
                    // console.log(dataList);
                    break; // 如果不止导入一个表格，就注释这行
                }
            };
            // 判断下传入的值是否正确：
            if ( dataList.length < 1){
                message.error("传入的数据为空", 5);
                return;
            };

            // 设置导入组件的状态
            that.setState({
                dataList: dataList, 
                addTimes: dataList.length});
        }
        fileReader.readAsBinaryString(files[0]);
    }

    render() {
        let dataElements = this.state.dataList.map((item, index) => {
            // console.log(index, item);
            let value = ""
            for(var key in item) {
                value += `${key}=>${item[key]};`
            }
            return (
                <div key={index}>{value}</div>
            );
        })
        return (
            <div style={{padding: 20, margin: 10, border: "1px solid #dfdfdf"}}>
                <div style={{backgroundColor: "#eee", marginBottom: 20, padding: 10}}>
                    <span>导入</span>
                    <input type="file" style={{paddingLeft: 10}}
                        onChange={(e) => this.handleImportFile(e.target.files, this)}>
                    </input>
                </div>
                <div>
                    <div>导入的数据</div>
                        {dataElements}
                </div>
            </div>
        );
    }
}

export default ImportExcelFile;
```

