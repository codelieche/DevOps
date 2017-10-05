在没git之前，我们要保存一个文件夹，多版本的时候，常用，复制备份或者SVN。

最简单的多版本，把文件夹备份复制多份。

比如: myapp文件夹，用复制来备份。

```
cp -rf myapp myapp.bak
cp -rf myapp myapp.2014.09.bak
cp -rf myapp myapp.2014.10.bak
```
通过复制的备份，确实简单，但是太不够用了，严重满足不了需求。

分布式版本控制系统(Distributed Version Control System,简称DVCS)，有`Git`、`Mercurial`、`Bazaar`以及`Darcs`等。

## Git的基本使用
Git将仓库分三层，`working Directory`、`Staging Area`、`History`(工作区，暂缓区，版本库history[HEAD]).

- 工作区就是本地的工作目录
- 暂缓区是中间一层暂存修改的抽象层次
- 最终的版本，提交到history 版本库中，也可以说是HEAD头部层。

一般我们在工作区(`workstation`)修改代码，修改完后，把修改或者添加的文件添加(`add`)到暂缓区(`stage`),然后可以把暂缓区修改的提交(`commit`)到版本库中(`history`).

我们也可以把文件从，最高层取出到中间暂缓层，也可以去取出到工作目录中。

### git配置
**设置全局变量:**
- `git config --global user.name codelieche`
- `git config --global user.email admin@codelieche.com`
- `git config --global color.ui true`
- `git config --list`: 查看所有配置


### 创建或者克隆一个仓库
- 创建repository: `git init`
- 克隆一个repository: `git clone repository_url`

### 添加和提交文件
- 进入目录查看状态: `git status`: new file, modified等
- 查看状态也可以用: `git status -s`,状态信息简洁版
- 添加文件: `git add study.py`
- 提交文件: `git commit -m"add study.py"`
- 直接从工作区提交到HEAD: `git commit -am"add new.py"

### 查看文件差别
- 查看工作区与暂缓区的不同: `git diff`
- 查看暂缓区与HEAD中文件的不同: `git diff --staged`
- 查看工作区与HEAD中的不同: `git diff HEAD`,加个参数`git diff --stat HEAD`

### 撤销错误操作
- 撤销add的操作，把HEAD中的文件转到暂缓区: `git reset study.py`
- 撤销工作区的文件修改,把暂缓区的文件转到工作区: `git checkout study.py`
- 直接从HEAD恢复到工作区: `git checkout HEAD study.py`

### 移除和重命名文件
- 在工作区删除文件: `git rm old.py`,提交删除信息: `git commit -m"delete file"`
- 在暂缓区删除文件: `git rm --cached old.py`,用:`git reset old.py也行
- 修改工作区的文件名: `git mv old.py new.py`,提交: `git commit -m"rename"`

### 暂存工作区
> 对本地文件进行了修改，但是突然出现了个bug需要修复。这种情况下，就相当于，先把本地文件都放到抽屉里面暂存着。把HEAD中的有个bug要修的版本拿出去，改吧改吧先。修改后，提交了后，就可以pop出暂存的工作区文件了，记得修复合并冲突。

- 查看状态：`git status -s`
- 暂存工作区：`git stash`
- 查看: `git stash list`
- 把暂存的本地文件取出来: `git stash pop` 后进先出的，如果是多个stash的话

### 创建和删除合并分支
- 列出所有分支(branch): `git branch`
- 创建一个分支: `git branch name` 加个`-b`参数就立刻选中新分支
- 切换分支: `git checkout name`
- 删除分支: `git branch -d name`
- 合并分支到当前分支: `git merge name`

### 常用命令
- `git init`: 在当前目录中创建个仓库(respository)
- `git add fileName`: 把当前目录中的文件添加到仓库中
- `git commit -m"提交信息备注"`: 提交文件到history中
- `git commit --amend -m"..."`: 当刚commit了，想重新提交覆盖上次的提交就用这个
- `git branch`: 查看分支，history->staging->working directory每条脉络就可以算一个分支。
- `git branch 分支名字`: 在当前工作区的基础上创建一个新的分支
- `git ls-files`: 查看仓库中的文件[还可以加其它参数的]
- `git status`: 查看状态，文件是否修改啊，变更啊等状态信息
- `git diff`: 查看当前工作区文件与暂缓区中文件的不同情况
- `git diff [HEAD]commit-id`: 可以查看工作区与指定commit版本的不同
- `git reset --soft commit-id`: 回撤到commit-id的这个版本，history-> stage
- `git reset --hard commit-id`: 回撤到commit-id这儿版本,history -> working directory.
- `git reset --soft ORIG_HEAD`: reset后，还原成reset之前的
- `git show HEAD:filename`: 查看history中文件的内容，HEAD可以是commit id也可以是ORIG_HEAD
- `git remote add origin <url>`: 添加远程仓库
- `git push -u origin`: push到远程仓库
- `git remote set-url --add origin <url2>`: 增加第二个远程仓库地址
- `git push origin:branch-name`: push到远程某个分支
- `git push origin --delete branch-name`: 删除远程分支
- `git branch -d branch-name`: 删除本地分支
- `git branch -b branch-name`: 创建一个分支，并立刻选择
- `git checkout branch-name`: 切换分支
- `git merge branch-name`: 合并某个分支到当前分支
- `git log`: 查看日志信息