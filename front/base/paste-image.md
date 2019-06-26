## 通过剪切板粘贴图片



### html示例

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>粘贴板图片处理</title>
</head>
<body>
    <div style="margin: auto; text-align: center; background: #00c1de; min-height: 500px; padding: 40px;">
        <img src="" id="image-paste">
    </div>
</body>
<script>
    function handlerPasteEvent(event) {
        console.log(event);
        if(event.clipboardData || event.originalEvent){
            // chrome有些老版本中是 event.originalEvent
            var clipboardData = (event.clipboardData || event.originalEvent.clipboardData);

            if(clipboardData.items){
                let items = clipboardData.items;
                for(var i = 0; i < items.length; i++){
                    console.log(items[i]);
                    if(items[i].type.indexOf("image") >= 0){
                        // 是个图片哦
                        let imageFile = items[i].getAsFile();
                        imageFile.uid = `parse-upload-${Math.round(Math.random()*10000000)}`;
                        let imageUrl = URL.createObjectURL(imageFile);
                        console.log(imageFile, imageUrl)
                        // console.log(typeof imageFile);
                        var imageElement = document.getElementById("image-paste");
                        imageElement.src = imageUrl;
                        break;
                    }
                }
            }
        }
    }
    document.addEventListener("paste", handlerPasteEvent);
</script>
</html>
```



### React组件示例

```js
class BaseImageUpload extends Component {
    constructor(props){
        super(props);
        this.state = {
            // 上传的图片文件列表
            fileList: [],
            // 上传的临时图片
            uploadImageUrl: null,
        }
    }

    componentDidMount() {
        // 检查添加权限
        this.fetchCheckPermission("task.add_plan");
        this.fetchPlatformListData();
        this.fetchTaskCodeListData();

        // 添加监听粘贴事件
        this.addPasteEventListener();
    }

    handlerPasteEvent = (event) => {
        // console.log(event);
        if(event.clipboardData || event.originalEvent){
            // chrome有些老版本中是 event.originalEvent
            var clipboardData = (event.clipboardData || event.originalEvent.clipboardData);

            if(clipboardData.items){
                let items = clipboardData.items;
                for(var i = 0; i < items.length; i++){
                    // console.log(items[i]);
                    if(items[i].type.indexOf("image") >= 0){
                        // 是个图片哦
                        let imageFile = items[i].getAsFile();
                        imageFile.uid = `${Math.round(Math.random()*10000000)}`;
                        let imageUrl = URL.createObjectURL(imageFile);
                        // console.log(imageFile, imageUrl)
                        // console.log(typeof imageFile);
                        this.setState({
                            fileList: [imageFile],
                            uploadImageUrl: imageUrl
                        });
                        break;
                    }
                }
            }
        }
    }

    addPasteEventListener = () => {
        document.addEventListener("paste", this.handlerPasteEvent);
    }

    componentWillUnmount () {
        document.removeEventListener("paste", this.handlerPasteEvent);
    }

  render(){
    let imageElement = "上传的图片";
      if(this.state.uploadImageUrl){
            imageElement = (
                <img style={{maxWidth: "100%", height: "auto"}} 
                  src={this.state.uploadImageUrl} alt="图片" />
            );
        }
        
			return (
      	<div>
           {imageElement}
        </div>
      );
  }
}
```



