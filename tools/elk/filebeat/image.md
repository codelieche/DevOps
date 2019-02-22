## filebeat镜像制作

官方镜像：docker.elastic.co/beats/filebeat:6.6.0

### 准备文件

- filebeat.yml

  ```yml
  filebeat.prospectors:
  - type: log
    paths:
      - '${FILES_PATHS:/var/www/logs/**/*.log}'
    exclude_lines: ['${FILEBEAT_EXCLUDE_LINES:DEBUG}']
    include_lines: ['${FILEBEAT_INCLUDE_LINES:\d+.*?\|.*?\|.*?}$']
    ignore_order: "${IGNORE_ORDER_VALUE:1m}"
  fields:
      # 模板名称，根据template，logstash做不同的filter操作
      template: '${FILEBEAT_TEMPLATE:default}'
      # 插入文档的时候，会把project字段提取出来
      project: '${PROJECT:default}'
      podIP: '${PODIP:127.0.0.1}'
      # logstash会根据index写到不同的index
      index: '${FILEBEAT_INDEX:default}'
  output.logstash:
    hosts: ['${LOGSTASH_HOST:logstash.codelieche.com}:${LOGSTASH_PORT:5044}']
  ```

- Dockerfile

  ```dockerfile
  FROM alpine:3.9
  
  ENV FILEBEAT_VERSION=6.6.0
  WORKDIR /app/
  COPY ./filebeat.yml /etc/filebeat.yml
  RUN apk add --update-cache curl bash libc6-compat && \
      rm -rf /var/cache/apk/* && \
      curl https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz -o ./filebeat.tar.gz && \
      tar xzvf filebeat.tar.gz && rm filebeat.tar.gz && \
      mv filebeat-${FILEBEAT_VERSION}-linux-x86_64 filebeat && \
      cp /etc/filebeat.yml /app/filebeat/filebeat.yml
      
  VOLUME /app/filebeat/data
  
  CMD ["/app/filebeat/filebeat","-e", "-c", "/etc/filebeat.yml"]
  ```

### 制作镜像

- 进入dockerfile所在的目录
- 执行构建命令：`docker build . -t filebeat:6.6.0`
- 给镜像打自定义的标签：`docker tag filebeat:6.6.0 registry.codelieche.com/filebeat:6.6.0`
- 推送镜像：`docker push registry.codelieche.com/filebeat:6.6.0`
- 运行容器：`docker run -itd --name filebeat filebeat:6.6.0`
- 进入容器：`docker exec -u 0 -it filebeat /bin/sh` -u 0 以root用户进入容器





