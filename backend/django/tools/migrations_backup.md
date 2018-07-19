## 备份Django的migrations文件

> 在开发代码中，有时候我们不把migrations文件加入到代码版本库中。

### 目录说明：
- 项目根目录为project, 代码放在project/source中。
- app都在`project/source/apps`中
- 备份的migrations文件放在：`project/backup/apps/日期/`

### 相关操作

**1. 列出migrations文件**
工作目录：`cd project/source/apps`
列出migrations的py文件：排除`__init__.py`

```bash
cd project/source/apps
ls **/migrations/0*.py
```

**2. 获取migrations py文件的目录**

```bash
dirname account/migrations/0001_initial.py
# account/migrations
```

**3. 获取当前日期**

```bash
date "+%Y%m%d"
# 20190719
```

**4. 创建备份的目录，把py文件复制过去**

```bash
# 得到备份日期
bakdate=`date "+%Y%m%d"`
I="xxx/xxx/xxx/xxx.py"
dir1=`dirname $I`;
# 得到目标目录和目标文件名
targetDir="../../backup/apps/${bakdate}/${dir}"
targetFile="../../backup/apps/${bakdate}/${I}"
# 复制文件
cp -rf $I $targetFile
```

**5. 文件的压缩与解压**

```bash
# 压缩
# tar -zvcf apps.tar.gz ./20180719/
# 解压
# backup tar -zxf ./apps.tar.gz 
```

