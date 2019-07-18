## Filebeat相关配置



#### 一般选项
- `registry_file`:存储文件状态的文件，相对路径，文件所在目录是${path.data}。
- `shutdown_timeout`: Filebeat关闭前等待时间，这个时间用来让已经发送的数据完成发送和接收端恢复确认信息。
- `tags`: 设置标签，可以多个，eg：`tags:["nginx", "web"]`
- `fields`: 可以在fields字段中添加自定义的信息随日志一起输出。


#### Prospector配置
- `type`: 输入的日志类型，默认log,其它还有`stdin`、`redis`、`udp`、`docker`等类型
    - [config filebeat options](https://www.elastic.co/guide/en/beats/filebeat/master/configuration-filebeat-options.html)
- `paths`: 需要收集的日志文件的绝对路径，支持通配符`*`
    - `recursive_glob`参数来递归查找指定目录下所有子目录中的日志文件
- `exclude_lines`: 过滤所有正则表达式匹配的行。
- `include_lines`: Filebeat只收集匹配正则表达式的行。可以多个表达式(列表)。
- `exclude_files`: 忽略的文件
- `tags`: 为收集的每条数据添加标签，一个或者多个。
- `fields`: 在输出的信息中添加额外信息字段。
- `ignore_older`: 过滤在指定时间前被修改的文件
- `close_inactive`: 如果一个文件在指定时间内没更新，那么Filebeat关闭文件句柄，默认5分钟。
- `close_renamed`: 如果文件名被修改了，关闭文件句柄。默认false。
- `close_removed`: 如果文件被删除了，Filebeat将关闭`Harvester`。
- `close_eof`: 如果开启，当Filebeat读取到文件末尾时，文件将很快关闭。默认false
- `close_timeout`: 如果开启，beat将给每个Harvester一个预定的生存期，当指定时间后，无论读取到文件哪个位置，读取都将停止。
- `clean_inactive`: 开启后，beat将删除指定不活跃的时间周期后的文件状态，同时只有在文件被beat忽略的情况下文件状态才能被删除。
- `clean_removed`: 默认开启，开启后无法从磁盘上找到最后一个已知的名称的情况，Filebeat将从`Registry`中清除该文件。


#### Output配置
> 目前Filebeat支持的Output有，`Eleasticsearch`,`Logstash`,`Kafka`,`Redis`,`File`,`Console`等。一般我们会将数据放入`Kafka`，这样可以减小对后端的写入压力。

- 配置Kafka
    1. `hosts`: Kafka Broker地址，用来获取kafka集群元数据
    2. `versions`: 设置Kafka版本信息，默认值是0.8.2.0版本，如果想对每条数据增加写入Kafka的时间戳，则需要将Version设置为**0.10.0.0**版本。
    3. `topic`: 用来发送数据的Kafka Topic名称。
    4. `username`: Kafka设置了认证功能就需要提供username来访问
    5. `password`: Kafka用户密码
    6. `partition`: 数据写入Kafka的每个分区的策略，默认Hash
       - `random`: 随机发送数据到kafka的分区中
       - `round_robin`: 轮询发送数据到kafka的每一个分区中
       - `hash`: 通过对指定字段做hash发送到对应的分区中

    7. `reachable_only`: 默认所有的分区都会接收数据，当一个Partion Leader不可用时，Output可能会变成不可用状态。设置reachable_only为true时，将数据只发送给可用的分区。
    8. `code.format`: 发送数据的格式，默认JSON格式发送，如果日志不是JSON格式的，则可用设置成按元数据格式发送。
    9. `client_id`: 设置client_id用于日志、调试或者认证等，默认为beats。
    10. `compression`: 设置数据输出压缩格式，默认值为gzip,还支持Snappy,LZ4等。
    11. `retry.backoff`: 在Kafka Leader选举期间重试的等待时间
    12. `bulk_max_size`: 在单次Kafka请求中，批量发送的最大事件数量，默认值是2048。
    13. `channel_buffer_size`: 缓存在output管道中的每个Kafka Broker消息数量。
    14. `required_acks`: 设置是否需要等待Kafka返回数据接收确认信息，默认为1.
        - `1`: 需要等待接收的副本返回确认信息
        - `0`: 表示Kafka不返回确认信息，Filebeat持续发送
        - `-1`: 表示需要等待Kafka所有的副本返回确认信息。
