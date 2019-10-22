## 问题：分片unassigned状态



### 集群健康状况

> https://www.elastic.co/guide/en/elasticsearch/guide/master/cluster-health.html

- 查看集群状态

  

#### 集群状态

- `gree`: 绿色，健康的状态：所有的主分片和副本都可用

- `yellow`: 黄色：所有的主分片可用，但是部分副本分片不可用

- `red`: 红色：部分主分片不可用

  **查看集群状态：**

  ```bash
  curl 192.168.1.123:9200/_cluster/health?pretty=true -u elastic:changeme
  {
    "cluster_name" : "codeliechees",
    "status" : "yellow",
    "timed_out" : false,
    "number_of_nodes" : 3,
    "number_of_data_nodes" : 3,
    "active_primary_shards" : 586,
    "active_shards" : 1053,
    "relocating_shards" : 0,
    "initializing_shards" : 2,
    "unassigned_shards" : 117,
    "delayed_unassigned_shards" : 0,
    "number_of_pending_tasks" : 0,
    "number_of_in_flight_fetch" : 0,
    "task_max_waiting_in_queue_millis" : 0,
    "active_shards_percent_as_number" : 89.84641638225256
  }
  ```

#### index状态

- 查看接口：`GET _cat/indices`或者`GET _cat/indices?v`



#### 分片状态

- 查看接口：`GET _cat/shards?v`

  ```bash
  curl 192.168.1.123:9200/_cat/shards?v -u elastic:changeme
  # ....
  packetbeat-6.6.1-2019.10.19        3     p      STARTED      59051087     25gb 192.168.1.203 192.168.1.203
  # .....
  filebeat-2019.10.04                2     r      UNASSIGNED
  ```

  **注意到有些分片是`unassigned`的状态**

  - `p` ，`primary`: 主分片
  - `r`, `replica`: 副分片

- 查看所有分片的状态

  ```bash
  GET _cat/shards?h=index,shard,prirep,state,unassigned.reason
  ```

  示例：

  ```bash
  curl 192.168.1.123:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason -u elastic:changeme | grep UNASSIGNED
  filebeat-2019.10.02                1 r UNASSIGNED   ALLOCATION_FAILED
  filebeat-2019.10.02                2 r UNASSIGNED   ALLOCATION_FAILED
  # .....
  packetbeat-6.1.0-2019.10.22        4 r UNASSIGNED   NODE_LEFT
  # ....
  log-default-2019.03.25             1 p STARTED      
  log-default-2019.03.25             1 r UNASSIGNED   ALLOCATION_FAILED
  log-default-2019.03.25             3 p STARTED      
  log-default-2019.03.25             3 r UNASSIGNED   ALLOCATION_FAILED
  log-default-2019.03.25             4 r STARTED      
  log-default-2019.03.25             4 p STARTED      
  log-default-2019.03.25             2 p STARTED      
  log-default-2019.03.25             2 r STARTED      
  log-default-2019.03.25             0 r STARTED      
  log-default-2019.03.25             0 p STARTED  
  ```

  

- 查看unassigned的原因：

  ```bash
  GET /_cluster/allocation/explain
  ```

  示例见附录1。



### unassigned(未分配)

> 一般情况下，当集群的某个节点重启了，集群状态会从红色 --> 黄色 --> 绿色。
>
> 但是偶尔会出现变成黄色，就没法继续了。

#### 出现unassigned的原因种类

- `INDEX_CREATED`：由于创建索引的API导致unassigned
- `CLUSTER_RECOVERED` ：由于完全集群恢复导致unassigned
- `INDEX_REOPENED `：由于打开open或关闭close一个索引导致unassigned
- `DANGLING_INDEX_IMPORTED` ：由于导入dangling索引的结果导致unassigned
- `NEW_INDEX_RESTORED` ：由于恢复到新索引导致unassigned
- `EXISTING_INDEX_RESTORED `：由于恢复到已关闭的索引导致unassigned
- `REPLICA_ADDED`：由于显式添加副本分片导致unassigned
- `ALLOCATION_FAILED` ：由于分片分配失败导致unassigned
- `NODE_LEFT` ：由于承载该分片的节点离开集群导致unassigned
- `REINITIALIZED` ：由于当分片从开始移动到初始化时导致unassigned（例如，使用影子shadow副本分片）
- `REROUTE_CANCELLED` ：作为显式取消重新路由命令的结果取消分配
- `REALLOCATED_REPLICA` ：确定更好的副本位置被标定使用，导致现有的副本分配被取消，出现unassigned



#### 修复unassigned

-  **修复ALLOCATION_FAILED状态的分片**

  - 先查看问题分片

    ```bash
    curl 192.168.1.123:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason -u elastic:changeme | grep log-default
    
    log-default-2019.04.21             1 p STARTED
    log-default-2019.04.21             1 r STARTED
    log-default-2019.04.21             2 p STARTED
    log-default-2019.04.21             2 r UNASSIGNED ALLOCATION_FAILED
    log-default-2019.04.21             3 p STARTED
    log-default-2019.04.21             3 r UNASSIGNED ALLOCATION_FAILED
    log-default-2019.04.21             4 p STARTED
    log-default-2019.04.21             4 r STARTED
    log-default-2019.04.21             0 r STARTED
    log-default-2019.04.21             0 p STARTED
    
    log-default-2019.03.25             1 p STARTED
    log-default-2019.03.25             1 r UNASSIGNED ALLOCATION_FAILED
    log-default-2019.03.25             2 p STARTED
    log-default-2019.03.25             2 r STARTED
    log-default-2019.03.25             3 p STARTED
    log-default-2019.03.25             3 r UNASSIGNED ALLOCATION_FAILED
    log-default-2019.03.25             4 r STARTED
    log-default-2019.03.25             4 p STARTED
    log-default-2019.03.25             0 r STARTED
    log-default-2019.03.25             0 p STARTED
    
    log-default-2019.03.23             1 r STARTED
    log-default-2019.03.23             1 p STARTED
    log-default-2019.03.23             2 p STARTED
    log-default-2019.03.23             2 r UNASSIGNED ALLOCATION_FAILED
    log-default-2019.03.23             3 r STARTED
    log-default-2019.03.23             3 p STARTED
    log-default-2019.03.23             4 p STARTED
    log-default-2019.03.23             4 r UNASSIGNED ALLOCATION_FAILED
    log-default-2019.03.23             0 p STARTED
    log-default-2019.03.23             0 r STARTED
    ```

    **得到信息：**

    - `log-default-2019.04.21`的`2`和`3`号分片的副本状态是`unassigned`

    - index为`log-default-2019.03.25 `的`1`和`3`号分片的副本状态是`unassigned`

  - **解决方式1: 设置副本数为0**

    ```bash
    PUT /log-default-2019.04.21/_settings
    {
      "number_of_replicas": 0
    }
    ```

    得到结果：

    ```json
    {
      "acknowledged" : true
    }
    
    ```

    再次查看分片：

    ```bash
    curl 192.168.1.123:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason -u elastic:changeme | grep log-default-2019.04.21
    
    log-default-2019.04.21             1 p STARTED
    log-default-2019.04.21             2 p STARTED
    log-default-2019.04.21             3 p STARTED
    log-default-2019.04.21             4 p STARTED
    log-default-2019.04.21             0 p STARTED
    ```

    **注意：**这种方式不可取，不推荐。

    当然可以再次设置其副本为1：

    ```bash
    PUT /log-default-2019.04.21/_settings
    {
      "number_of_replicas": 1
    }
    ```

    再次查看分片：

    ```bash
    log-default-2019.04.21             1 p STARTED
    log-default-2019.04.21             1 r STARTED
    log-default-2019.04.21             2 p STARTED
    log-default-2019.04.21             2 r STARTED
    log-default-2019.04.21             3 p STARTED
    log-default-2019.04.21             3 r STARTED
    log-default-2019.04.21             4 p STARTED
    log-default-2019.04.21             4 r STARTED
    log-default-2019.04.21             0 p STARTED
    log-default-2019.04.21             0 r STARTED
    ```

    - 通过脚本处理：

      ```bash
      #!/bin/bash
      indices=`curl 192.168.1.201:9200/_cat/indices -u elastic:changeme | grep yellow |awk '{print $3}'`
      
      echo `date`
      for i in $indices
      do
        echo $i
        # 修改副本为0
        curl -XPUT "http://192.168.1.201:9200/${i}/_settings" -u elastic:changeme -H 'Content-Type: application/json' -d'{"number_of_replicas": 0}'
      
        sleep 1
        curl -XPUT "http://192.168.1.201:9200/${i}/_settings" -u elastic:changeme -H 'Content-Type: application/json' -d'{"number_of_replicas": 1}'
        echo ""
      done
      ```

    - 再次查看集群状态：

      ```bash
      GET _cluster/health?pretty
      
      ```

      

  - **解决方式2：**reroute

    ```bash
    POST /_cluster/reroute
    {
      "commands": [
        {
          "allocate_replica": {
            "index": "log-default-2019.03.25",
            "shard": 1,
            "node": "192.168.1.203"
          }
        },
        {
          "allocate_replica": {
            "index": "log-default-2019.03.25",
            "shard": 3,
            "node": "192.168.1.202"
          }
        }
      ]
    }
    ```

    `allocate_replica`是重新分配，另外还有`move`和`cancel`。

    执行出现错误：

    > allocation awareness is not enabled, set cluster setting [cluster.routing.allocation.awareness.attributes] to enable it

    - 查看集群配置：

      ```bash
      GET /_settings?pretty
      GET /log-default-2019.03.25/_settings
      ```

      



### 附录

#### 1. 查看unassigned原因

```bash
curl 192.168.1.123:9200/_cluster/allocation/explain?pretty -u elastic:changeme

{
  "index" : "filebeat-2019.10.07",
  "shard" : 3,
  "primary" : false,
  "current_state" : "unassigned",
  "unassigned_info" : {
    "reason" : "ALLOCATION_FAILED",
    "at" : "2019-10-10T11:35:12.606Z",
    "failed_allocation_attempts" : 5,
    "details" : "failed shard on node [d0wVQXAxS6-qy_b7eBm-5g]: failed to create shard, failure IllegalStateException[environment is not locked]; nested: NoSuchFileException[/data/elasticsearch/data/nodes/0/node.lock]; ",
    "last_allocation_status" : "no_attempt"
  },
  "can_allocate" : "no",
  "allocate_explanation" : "cannot allocate because allocation is not permitted to any of the nodes",
  "node_allocation_decisions" : [
    {
      "node_id" : "Tp9RA3Q9T4auAGZju8LCBg",
      "node_name" : "192.168.1.201",
      "transport_address" : "192.168.1.201:9300",
      "node_attributes" : {
        "ml.machine_memory" : "16657432576",
        "ml.max_open_jobs" : "20",
        "xpack.installed" : "true",
        "ml.enabled" : "true"
      },
      "node_decision" : "no",
      "deciders" : [
        {
          "decider" : "max_retry",
          "decision" : "NO",
          "explanation" : "shard has exceeded the maximum number of retries [5] on failed allocation attempts - manually call [/_cluster/reroute?retry_failed=true] to retry, [unassigned_info[[reason=ALLOCATION_FAILED], at[2019-10-10T11:35:12.606Z], failed_attempts[5], delayed=false, details[failed shard on node [d0wVQXAxS6-qy_b7eBm-5g]: failed to create shard, failure IllegalStateException[environment is not locked]; nested: NoSuchFileException[/data/elasticsearch/data/nodes/0/node.lock]; ], allocation_status[no_attempt]]]"
        },
        {
          "decider" : "throttling",
          "decision" : "THROTTLE",
          "explanation" : "reached the limit of incoming shard recoveries [2], cluster setting [cluster.routing.allocation.node_concurrent_incoming_recoveries=2] (can also be set via [cluster.routing.allocation.node_concurrent_recoveries])"
        }
      ]
    },
    {
      "node_id" : "X-KfhnzGQ4CSAy9A1vTC8w",
      "node_name" : "192.168.1.202",
      "transport_address" : "192.168.1.202:9300",
      "node_attributes" : {
        "ml.machine_memory" : "16657432576",
        "ml.max_open_jobs" : "20",
        "xpack.installed" : "true",
        "ml.enabled" : "true"
      },
      "node_decision" : "no",
      "deciders" : [
        {
          "decider" : "max_retry",
          "decision" : "NO",
          "explanation" : "shard has exceeded the maximum number of retries [5] on failed allocation attempts - manually call [/_cluster/reroute?retry_failed=true] to retry, [unassigned_info[[reason=ALLOCATION_FAILED], at[2019-10-10T11:35:12.606Z], failed_attempts[5], delayed=false, details[failed shard on node [d0wVQXAxS6-qy_b7eBm-5g]: failed to create shard, failure IllegalStateException[environment is not locked]; nested: NoSuchFileException[/data/elasticsearch/data/nodes/0/node.lock]; ], allocation_status[no_attempt]]]"
        }
      ]
    },
    {
      "node_id" : "hj-G-2vCS8OovSqFTLI0qg",
      "node_name" : "192.168.1.203",
      "transport_address" : "192.168.1.203:9300",
      "node_attributes" : {
        "ml.machine_memory" : "16657432576",
        "ml.max_open_jobs" : "20",
        "xpack.installed" : "true",
        "ml.enabled" : "true"
      },
      "node_decision" : "no",
      "deciders" : [
        {
          "decider" : "max_retry",
          "decision" : "NO",
          "explanation" : "shard has exceeded the maximum number of retries [5] on failed allocation attempts - manually call [/_cluster/reroute?retry_failed=true] to retry, [unassigned_info[[reason=ALLOCATION_FAILED], at[2019-10-10T11:35:12.606Z], failed_attempts[5], delayed=false, details[failed shard on node [d0wVQXAxS6-qy_b7eBm-5g]: failed to create shard, failure IllegalStateException[environment is not locked]; nested: NoSuchFileException[/data/elasticsearch/data/nodes/0/node.lock]; ], allocation_status[no_attempt]]]"
        },
        {
          "decider" : "same_shard",
          "decision" : "NO",
          "explanation" : "the shard cannot be allocated to the same node on which a copy of the shard already exists [[filebeat-2019.10.07][3], node[hj-G-2vCS8OovSqFTLI0qg], [P], s[STARTED], a[id=wvBb97QZSSCVL1enaaSJcA]]"
        }
      ]
    }
  ]
}
```

