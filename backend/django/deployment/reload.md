## 项目部署之--reload
- 加载新的静态文件
- 对数据模型重新migrate
- 重启服务
- 重启celery

### 启动celery脚本

```shell
#! /bin/bash
CELERY_TASK='celery -A devops worker -l info'

function start()
{
  # 启动celery
  path='/data/www/devops.codelieche.com'
  if [ -e $path ]; then
    cd "${path}/source"
    # 启动celery
    $(`nohup ${path}/virtualenv/bin/celery -A devops worker -l info >> ../logs/celery.log &`)  && \
    echo "启动celery成功"
  fi
}

function stop()
{
  # 列出celery任务的pid列表
  # 注意：因为list中会列出grep的这个进程，所以awk前面加个条件`/bin\/celery/`正则匹配
  list=`ps aux|grep "$CELERY_TASK"|awk '/bin\/celery/{print $2}'`
  echo $list
  # for循环杀掉celery的进程
  for p in $list
    do
      kill $p && echo "杀掉celery进程 $p"
    done
  return 0
}

if [ -n $1 ]; then
  case $1 in
    "start")
      start
    ;;

    "stop")
      stop
    ;;

    "restart")
      stop
      start
    ;;

    *)
      echo "请输入:start|restart|stop"
    ;;
  esac
 fi
```


### reload.sh脚本

```shell
#!/bin/bash
DJANGODIR=/data/www/devops.codelieche.com

# 重启celery
cd $DJANGODIR
./celery.server restart

cd ${DJANGODIR}/source
cp  -rf ./static/js/* ../static/js/
cp  -rf ./static/css/* ../static/css/
exec ../virtualenv/bin/python manage.py collectstatic --noinput --settings=devops.settings-dev
```


