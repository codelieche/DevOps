## Celery的基本使用



### 基本命令
- 启动celery：`celery - A devops workder -l info`
- 如果要指定进程数：`celery - A devops workder -l info --concurrency=4`


### 重启celery脚本

```shell
#!/bin/bash
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
	  kill $p && echo "杀掉进程 $p"
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